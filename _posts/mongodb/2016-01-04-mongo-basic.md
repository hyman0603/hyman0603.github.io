---
layout: post
title: "Mongodb基础知识总结"
subtitle: "Mongodb基础知识小结-学而时习之!"
header-img: "img/in-post/eliot-horowitz.png"
category: "mongodb"
tags: [mongodb]
---
>最好的自己，因为你即你选择。这些年，我一直坚持的一个信念是，改变不了大环境，就改变小环境，做自己力所能及的事情。你不能决定太阳几点升起，但可以决定自己几点起床。--《自由在高处》

# 一.基本概念

## 1.1 文档

**文档是mongodb中数据的基本单元，类似于关系型数据库的行**。

关于文档的键的说明：

- 键是字符串，任意的UTF-8字符
- 键不能包括`\0`(空字符串)，表示键的结尾
- 键不能包括`.`,`$`等特殊字符，它们都是mongodb保留字

**mongodb区分类型和大小写**

	{"foo": 3} != {"foo": "3"} != {"Foo": 3}

**mongodb不能有重复的键**

	{"foo": 3, "bar": 4, "foo": 100}   // 非法

**文档中键值对是有序的**
	
	{"x":1, "y":2} != {"y":2, "x":1}


## 1.2 集合

集合(collection)可以看做动态模式(dynamic schema， 意味着里面的文档是各式各样的)的表, 是一组文档。关于文档的命名与集合的命名**基本一致**，但是还包括如下：

- 与文档命名基本一致
- 不能以`system.`开头，因为这是系统保留的前缀，如system.users存储用户信息，system.namespaces存储集合信息等

集合还能包括**子集合**，以`.`来分割，如blog集合，下blog.users和blog.posts集合，**子集合没有啥特殊属性，往往作为一个管理和定义等，但是推荐使用。** 如：

- GridFS, 用子集合存储文件的元数据，这样就能与文件内容块很好的隔离开
- 驱动程序的语法糖，如shell中，db.blog表示blog集合，db.blog.users表示博客用户子集合。

## 1.3 数据库

多个集合就组成了数据库，数据库可以有多个，对应0或多个集合，每个数据库都是独立的，有独立的权限。

数据库的命名**与集合类似**，除此之外要注意，**区分大小写，最好小写命名，不超过64个字节。**


要注意：**数据库最终会成为文件系统的一个文件，而数据库名就对应的是文件名，文件怎么命名的数据库就应该怎么命名。**

## 1.4 基础配置和管理

运行`mongod`命令启动该服务，默认数据目录是/data/db;默认端口`27017`

运行`mongo`则启动mongodb shell,该shell是**一个Javascript解释器，可以运行js程序。**

启动时，shell默认连接test数据库，并将数据库连接赋值给全局变量`db`.

	// 查看当前数据库
	> db
	test

	// 切换数据库
	> use foo
	switched to db foo
	> db
	foo

	//访问集合:db.yourCollection
	//集合操作:db.yourCollection.xxx

查看帮助：

	> db.help() // 数据库帮助
	DB methods:
		db.adminCommand(nameOrDocument) - switches to 'admin' db, and runs command [ just calls db.runCommand(...) ]
		db.auth(username, password)
		db.cloneDatabase(fromhost)
 
	> db.foo.help() //集合帮助
	DBCollection help
		db.foo.find().help() - show DBCursor help
		db.foo.count()

	> db.foo.find //查看函数级别


# 二.数据类型

## 2.1 基础数据类型
类JSON, 而JSON的基础数据类型为：`null`,布尔值，数字，字符串，数组和对象。往往能处理大多数情况，但JSON的局限在于：

- 没有日期类型
- 只有一种数字类型，无法区分浮点数和整数
- 无法表示通用类型如正则或函数

**mongodb保留了JSON基本键值对特性，添加了其他数据类型：**

- null: 表示空值或不存在的字段， `{"x":null}`
- 布尔值：true和false
- 数值：默认64位浮点数， {"x": 3.14},对于整型在shell中可使用js的NumberInt(4位),NumberLong(8位)，如：{"x":NumberInt("3")}
- 字符串：UTF-8字符串
- 日期：存储为自新纪元以来进过的毫秒数，不存储时区， {"x": new Date()}
- 正则表达式：与Js正则语法类似，{"x": /foo/i}
- 数组
- 内嵌文档
- 对象id： {"x": ObjectId()}
- 二进制数据
- 代码：仅内部使用

# 三.CRUD

## 3.1 插入文档

`insert`命令，会自动添加一个`_id`键。

	> db.foo.insert({"bar": "baz"})
	WriteResult({ "nInserted" : 1 })

	> i = {"name": "beginman", "age": 24}
	{ "name" : "beginman", "age" : 24 }
	
	> db.foo.insert(i)
	WriteResult({ "nInserted" : 1 })
	
	> db.foo.save(i)
	WriteResult({ "nInserted" : 1 })


如果批量插入则以列表形式：

	>> db.foo.insert([{"v1": 100}, {"v2": 200}, {"v3": 300}])

还可以[用`Bulk` 插入多个文档](http://docs.mongoing.com/manual/tutorial/insert-documents.html#insert-multiple-documents-with-bulk)

## 3.2 删除文档

db.foo.remove({}): 空的查询文档`{}`删除foo集合中所有文档，但不会删除集合本身，也不会删除集合元信息。

db.foo.remove({"name": "fang"}) 删除指定集合。

如果要清空整个集合用`db.drop()`直接删除集合会比较快。

要想删除单个文档，可以调用 remove() 方法，然后把 justOne 参数设置为 true 或 `.`。

	db.inventory.remove( { type : "food" }, 1 )


## 3.3 更新文档

MongoDB 使用 `update()` 和 `save()` 方法来更新集合中的文档.

### 3.3.1 update() 方法

	db.collection.update(
	   <query>,
	   <update>,
	   {
	     upsert: <boolean>,
	     multi: <boolean>,
	     writeConcern: <document>
	   }
	)

参数说明：

- query : update的查询条件，类似sql update查询内where后面的。
- update : update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sql update查询内set后面的
- upsert : 可选，这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
- multi : 可选，mongodb 默认是false,只更新找到的第一条记录，如果这个参数为true,就把按条件查出来多条记录全部更新。
- writeConcern :可选，抛出异常的级别。

### 3.3.2 save() 方法
save() 方法通过传入的文档来替换已有文档。语法格式如下：

	db.collection.save(
	   <document>,
	   {
	     writeConcern: <document>
	   }
	)

参数说明：

- document : 文档数据。
- writeConcern :可选，抛出异常的级别。


### 3.3.3 $set修改器

`$set`指定一个字段的值，如果该字段不存在则创建，存在则修改。如下：


	> db.foo.find({"name": "beginman"})
	{ "_id" : ObjectId("5689ec760c45f69abd830053"), "name" : "beginman", "age" : 25 }
	{ "_id" : ObjectId("5689ec810c45f69abd830054"), "name" : "beginman", "age" : 24 }

	//批量修改
	> db.foo.update({"name": "beginman"}, {"$set": {"age": 25}}, {"multi": 1})
	WriteResult({ "nMatched" : 2, "nUpserted" : 0, "nModified" : 1 })
	
	//修改内嵌文档
	> db.foo.find({_id: ObjectId("568a05450c45f69abd830057")}).pretty()
	{
		"_id" : ObjectId("568a05450c45f69abd830057"),
		"name" : "beginman",
		"age" : 24,
		"read" : {
			"title" : "Python CookBook",
			"star" : "☆☆☆☆☆"
		}
	}
	> db.foo.update({_id: ObjectId("568a05450c45f69abd830057")}, {"$set": {"read.title": "Redis In Action"}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
	> db.foo.find({_id: ObjectId("568a05450c45f69abd830057")}).pretty()
	{
		"_id" : ObjectId("568a05450c45f69abd830057"),
		"name" : "beginman",
		"age" : 24,
		"read" : {
			"title" : "Redis In Action",
			"star" : "☆☆☆☆☆"
		}
	}


**`$unset`:删除指定的键**

	> db.foo.update({"name": "beginman"}, {"$unset": {"age": 1}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
	> db.foo.find({"name": "beginman"})
	{ "_id" : ObjectId("5689ec760c45f69abd830053"), "name" : "beginman" }
	{ "_id" : ObjectId("5689ec810c45f69abd830054"), "name" : "beginman", "age" : 25 }

### 3.3.4 $inc递增递减
`$inc`用于增加数值，如果不存在则创建。

	> db.foo.update({"name": "beginman"}, {"$inc": {"view": 0}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

	> db.foo.find({"name": "beginman"})
	{ "_id" : ObjectId("5689ec810c45f69abd830054"), "name" : "beginman", "age" : 25, "view" : 0 }
	{ "_id" : ObjectId("568a05450c45f69abd830057"), "name" : "beginman", "age" : 24, "read" : { "title" : "Redis In Action", "star" : "☆☆☆☆☆" } }

如果递减数值，则`$inc`后面应该是负数。

### 3.3.5 $push向数组添加元素
如果数组已经存在则`$push`向其尾部添加元素，不存在则创建。

	> db.foo.find({"name": "Jack"}).pretty()
	{
		"_id" : ObjectId("568a08ae0c45f69abd830058"),
		"name" : "Jack",
		"age" : 26,
		"read" : [
			{
				"title" : "Python CookBook",
				"star" : "☆☆☆☆☆"
			}
		]
	}

	//添加读书
	> db.foo.update(
		{"name": "Jack"}, 
		{"$push": {"read": {"title": "Redis In Action", "star": "☆☆☆"}}}
	)
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

	> db.foo.find({"name": "Jack"}).pretty()
	{
		"_id" : ObjectId("568a08ae0c45f69abd830058"),
		"name" : "Jack",
		"age" : 26,
		"read" : [
			{
				"title" : "Python CookBook",
				"star" : "☆☆☆☆☆"
			},
			{
				"title" : "Redis In Action",
				"star" : "☆☆☆"
			}
		]
	}

这是`$push`的基本用法，还可以配合**`$each`(用来循环)，实现批量push.**

	//添加成绩
	> db.foo.update(
		{"name": "Jack"}, 
		{"$push": {"scores": 
					{"$each": [{"math": 98.8}, 
								{"english":100}, 
								{"C/C++": 99.3}]}
					}
		}
	)

	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
	> db.foo.find({"name": "Jack"}).pretty()
	{
		"_id" : ObjectId("568a08ae0c45f69abd830058"),
		"name" : "Jack",
		"age" : 26,
		"read" : [
			{
				"title" : "Python CookBook",
				"star" : "☆☆☆☆☆"
			},
			{
				"title" : "Redis In Action",
				"star" : "☆☆☆"
			}
		],
		"scores" : [
			{
				"math" : 98.8
			},
			{
				"english" : 100
			},
			{
				"C/C++" : 99.3
			}
		]
	}

**如果希望数组长度是固定的，则可用`$slice`限定长度**：

	> db.foo.update({"name": "Rose"},
	... {"$push": {"top10": {
	...     "$each": ["England", "Beijing", "SanYa"],
	...     "$slice": -2}}})


	> db.foo.find({"name": "Rose"})
	{ "_id" : ObjectId("568a0d700c45f69abd830059"), "name" : "Rose", "top10" : [ "Beijing", "SanYa" ] }


`$slice`后面必须是负整数，限制数组只包括最后加入的2个元素。

### 3.3.6 将数组作为数据集使用

关于数组操作可参考[**Array Update Operators¶**](https://docs.mongodb.org/v3.0/reference/operator/update-array/)

**插入元素：**

有时候为了保证数组元素的唯一性，使用`$ne`(not equal), [参考文档详细](https://docs.mongodb.org/v3.0/reference/operator/query/ne/),`$ne`语法如下：

	{field: {$ne: value} }
	//$ne selects the documents where the value of the field is not equal (i.e. !=) to the specified value. 
	//This includes documents that do not contain the field.

etc:

	db.foo.find( { age: { $ne: 24 } } )

如果对于数组则可以用`$addToSet`,"$addToSet"也可用来插入数组元素，与"$push"不同的是，当要插入的元素在数组中已经存在时，"$addToSet"就不会再次插入。可以用来避免重复。

**删除元素：**

可以使用:

- `$pop`(Removes the first or last item of an array., [文档地址](https://docs.mongodb.org/v3.0/reference/operator/update/pop/#up._S_pop))
- `$pullAll`(Removes all matching values from an array.,[文档地址](https://docs.mongodb.org/v3.0/reference/operator/update/pullAll/#up._S_pullAll))
- `$pull`(Removes all array elements that match a specified query.[文档地址](https://docs.mongodb.org/v3.0/reference/operator/update/pull/#up._S_pull))

`$pop`操作：{"$pop": {"arrayKey": 1}}:

	> db.foo.find({"_id": 1})
	{ "_id" : 1, "scores" : [ 8, 9, 10 ] }

	// -1从数组头部删除
	> db.foo.update({"_id": 1}, {$pop: {"scores": -1}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

	> db.foo.find({"_id": 1})
	{ "_id" : 1, "scores" : [ 9, 10 ] }

	// 1从数组末尾删除
	> db.foo.update({"_id": 1}, {$pop: {"scores": 1}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

	> db.foo.find({"_id": 1})
	{ "_id" : 1, "scores" : [ 9 ] }
	> 

`$push`删除指定元素, `$pushAll`删除全部指定元素

	> db.foo.find({"_id": 2})
	{ "_id" : 2, "learn" : [ "java", "python", "c", "js", "go", "java" ] }

	//删除c
	> db.foo.update({"_id": 2}, {"$pull": {"learn": "c"}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

	> db.foo.find({"_id": 2})
	{ "_id" : 2, "learn" : [ "java", "python", "js", "go", "java" ] }

	//删除js和go
	> db.foo.update({"_id": 2}, {"$pullAll": {"learn": ["js", "go"]}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
	> db.foo.find({"_id": 2})
	{ "_id" : 2, "learn" : [ "java", "python", "java" ] }

	//删除java
	> db.foo.update({"_id": 2}, {"$pull": {"learn": "java"}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
	> db.foo.find({"_id": 2})
	{ "_id" : 2, "learn" : [ "python" ] }


**基于位置的数组修改器**

如果数组有多个值，我们只想对其中一部分进行修改，则**可通过位置或者定位操作符("$")**

基于位置：arrayName.index.key, 如对元素0上增加10个投票(comments.0.vote)

	> db.foo.find({"book": "python cookbook"}).pretty()
	{
		"_id" : ObjectId("568a17b90c45f69abd83005b"),
		"book" : "python cookbook",
		"comments" : [
			{
				"name" : "Jack",
				"vote" : 1,
				"content" : "good"
			},
			{
				"name" : "Rose",
				"vote" : 3,
				"content" : "very well"
			}
		]
	}

	> db.foo.update({"book": "python cookbook"}, {"$inc": {"comments.0.vote": 10}})
	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
	
	> db.foo.find({"book": "python cookbook"}).pretty()
	{
		"_id" : ObjectId("568a17b90c45f69abd83005b"),
		"book" : "python cookbook",
		"comments" : [
			{
				"name" : "Jack",
				"vote" : 11,
				"content" : "good"
			},
			{
				"name" : "Rose",
				"vote" : 3,
				"content" : "very well"
			}
		]
	}

但是一般情况下需要查询一遍才知道数组的下标，对于不知道下标的情况最好使用定位操作符`$`,基于定位操作符`$`可更新只匹配上的元素(comments.$.name)。如将评论人为Rose改成Lucy.

	> db.foo.update(
		{ "comments.name": "Rose" }, 
		{"$set":  
			{"comments.$.name": "Lucy"}})

	WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

	> db.foo.find({"book": "python cookbook"}).pretty()
	{
		"_id" : ObjectId("568a17b90c45f69abd83005b"),
		"book" : "python cookbook",
		"comments" : [
			{
				"name" : "Jack",
				"vote" : 11,
				"content" : "good"
			},
			{
				"name" : "Lucy",
				"vote" : 3,
				"content" : "very well"
			}
		]
	}

**定位符只更新第一个匹配的元素**。如果评论里面有两个Jack则上述方案只更新第一个，**思考：如何才能批量更新数组里的相同元素呢**

### 3.3.7 upsert & $setOnInsert

MongoDB 的update方法的三个参数是upsert，这个参数是个布尔类型，默认是false。当它为true的时候，update方法会首先查找与第一个参数匹配的记录，在用第二个参数更新之，如果找不到与第一个参数匹配的的记录，就插入一条（upsert 的名字也很有趣是个混合体：**update+insert**）

	> db.foo.update({"count": 100}, {"$inc": {"count": 10}}, true)
	> db.foo.find({"count": 110})
	{ "_id" : ObjectId("568a1dd53487d056d75967ad"), "count" : 110 }

如上，在找不到count=100这条记录的时候，自动插入一条count=100，然后再加10，最后得到一条count=110的记录

如果在创建文档的同时并创建字段赋初值则可使用`$setOnInsert`, 如果文档已经存在则无法更新：
	
	//该文档原先已存在
	> db.foo.find({"_id": 1})
	{ "_id" : 1, "scores" : [ 9 ] }

	//初始化
	> db.foo.update({"_id": 1},
	... {$setOnInsert: { default: 100, ctime: new Date()}},
	... {upsert:true}
	... )

	//未初始化
	> db.foo.find({"_id": 1})
	{ "_id" : 1, "scores" : [ 9 ] }

	//创建新文档并初始化
	> db.foo.update({"_id": 3}, {$setOnInsert: {"default":100, "ctime":new Date()}}, {upsert:true} )
	> db.foo.find({"_id": 3})
	{ "_id" : 3, "default" : 100, "ctime" : ISODate("2016-01-04T07:31:47.325Z") }
	
	//再次初始化，由于数据已存在则不再初始化
	> db.foo.update({"_id": 3}, {$setOnInsert: {"default":300, "ctime":new Date()}}, {upsert:true} )
	> db.foo.find({"_id": 3})
	{ "_id" : 3, "default" : 100, "ctime" : ISODate("2016-01-04T07:31:47.325Z") }
	 
### 3.3.8 返回被更新的文档
使用`findAndModify`,[参数详情参考文档：db.collection.findAndModify()¶](https://docs.mongodb.org/manual/reference/method/db.collection.findAndModify/)

	//query的条件不存在，创建文档,当new为false时，返回null
	> db.people.findAndModify({
		query: {name: "Jack"}, 
		update: { $inc: { score: 1 } }, 
		upsert: true
	})
	null

	> db.people.find({"name": "Jack"})
	{ "_id" : ObjectId("568a227a3487d056d75967b0"), "name" : "Jack", "score" : 1 }
	
	//query的条件存在，更新文档,当new为false时，返回未修改之前匹配上的文档
	> db.people.findAndModify({query: {name: "Jack"}, update: { $inc: { score: 10 } }, upsert: true})
	{
		"_id" : ObjectId("568a227a3487d056d75967b0"),
		"name" : "Jack",
		"score" : 1
	}

	> db.people.find({"name": "Jack"})
	{ "_id" : ObjectId("568a227a3487d056d75967b0"), "name" : "Jack", "score" : 11 }

	//query的条件不存在，创建文档,当new为true时，返回新文档
	> db.people.findAndModify({query: {name: "jack"}, update: { $inc: { score: 10 } }, upsert: true, new:true})
	{
		"_id" : ObjectId("568a22b43487d056d75967b1"),
		"name" : "jack",
		"score" : 10
	}



参考：

- [MongoDB 教程](http://www.runoob.com/mongodb/mongodb-tutorial.html)
- [《MongoDB权威指南》](http://book.douban.com/subject/25798102/)
