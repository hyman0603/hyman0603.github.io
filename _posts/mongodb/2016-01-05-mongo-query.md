---
layout: post
title: "Mongodb常用查询"
subtitle: "find&findOne和各种查询条件"
header-img: "img/bigshows/my_env.jpg"
category: "mongodb"
tags: [mongodb]
---
>大图是我个人编程环境。

>不胡思乱想就是禅，一旦你明白这点，走路，站着，坐着或躺着，你所做的一切都是禅。 --达摩(Red Pine, 1987)

# Summary
大纲之.

1. [find基础](http://beginman.cn/mongodb/2016/01/05/mongo-query/#find)
2. [查询条件](http://beginman.cn/mongodb/2016/01/05/mongo-query/#section)
3. [特定类型的查询](http://beginman.cn/mongodb/2016/01/05/mongo-query/#section-1)
	- [null](http://beginman.cn/mongodb/2016/01/05/mongo-query/#null)
	- [正则](http://beginman.cn/mongodb/2016/01/05/mongo-query/#section-2)
	- [数组](http://beginman.cn/mongodb/2016/01/05/mongo-query/#section-3)
	- [内嵌文档](http://beginman.cn/mongodb/2016/01/05/mongo-query/#section-4)
4. [$where查询](http://beginman.cn/mongodb/2016/01/05/mongo-query/#where)
5. [游标](http://beginman.cn/mongodb/2016/01/05/mongo-query/#section-5)

# 一.find基础

- find( {} ) 等于 find(), `{}`表示全部，默认之
- find( { key: value, .... } ) 指定条件查询
- find( {}, { "key":1,...} ) 第二个参数来指定需要返回的键，默认是全部。**指定返回可节省解码，传输时间和内存消耗。**，默认情况`_id`总是返回，可显式{_id: 0}将其踢掉

# 二.查询条件
`find`,`findOne`用起来还是挺简单的，难就难在查询条件上。可通过文档查看详细[**Query and Projection Operators**](https://docs.mongodb.org/v3.0/reference/operator/query/)

永远要记住：

- 查询条件是在键(key)的基础上，{"key": {查询条件..}}
- 对于多条件，如`$in`,`$nin`,`$or`,`$and`等需要用数组包起来，如db.foo.find({"$or": [{"uid": 1001}, {"uname": "beginman", "pid": {"$in": [1,2,3,4]}}]})
- 对于元条件，如`$not`,`$or`,`$and`可以用在任何条件上,也用于外层文档 如： db.foo.find({"uid": {"$not": {"$mod": [5, 1]}}})
- **对比上一节的`$`更新操作，如`$inc`用在外层文档的键, 条件语义如：`$lt`用在内层文档，条件语句是内层文档的键，而修改器则是外层文档的键。**
- **一个键有任意多个条件，但一个键不能有任意多个更新修改器**，也就是说不能同时存在：{"$inc": {"age": 1}, "$set": {"age": 10}}

# 三.特定类型的查询
针对特殊的类型如null,数组，内嵌等处理。

## 3.1 null
也可通过上述方式匹配null自身，但是**null不仅会匹配null自身还会匹配不包括这个键的文档**，如下：

	> db.foo.find()
	{ "_id" : ObjectId("568bdc9a0c45f69abd83005c"), "y" : null }
	{ "_id" : ObjectId("568bdc9c0c45f69abd83005d"), "y" : 1 }
	{ "_id" : ObjectId("568bdca10c45f69abd83005e"), "z" : 3 }

	> db.foo.find({y: null})
	{ "_id" : ObjectId("568bdc9a0c45f69abd83005c"), "y" : null }
	{ "_id" : ObjectId("568bdca10c45f69abd83005e"), "z" : 3 }

虽然查询到了y为null的情况但是也查到了键不为y的情况，显然这不是我们想要的。

**如果仅想匹配键值为null的文档，则既要检查该键的值是否为null，还要通过`$exists`条件判定键值已存在。**

	> db.foo.find({'y': {'$eq': null, '$exists': true}})
	{ "_id" : ObjectId("568bdc9a0c45f69abd83005c"), "y" : null }

## 3.2 正则表达式

**mongodb使用perl兼容的正则表达式(PCRE)库来匹配正则表达式，在使用前在js shell中先测试下你的正则是否行得通。正则表达式也会匹配自身的。**

	> db.people.find({'name': /^j/})
	{ "_id" : ObjectId("568a22b43487d056d75967b1"), "name" : "jack", "score" : 10 }

	> db.people.find({'name': /^j/i})
	{ "_id" : ObjectId("568a227a3487d056d75967b0"), "name" : "Jack", "score" : 11 }
	{ "_id" : ObjectId("568a22b43487d056d75967b1"), "name" : "jack", "score" : 10 }

## 3.3 数组
**(1).查询数组元素与查询标量值是一样的**

	> db.foo.find({"fruit": "apple"})
	{ "_id" : ObjectId("568bdf460c45f69abd83005f"), "fruit" : [ "apple", "banna", "peach" ] }
	{ "_id" : ObjectId("568bdf990c45f69abd830060"), "fruit" : [ "apple", "tomato" ] }

相当于查询：{'fruit': 'apple', 'fruit': 'banna', ...}

**(2).如果我们全部匹配则需要全部将数组元素写出且顺序要一致**

	> db.foo.find({"fruit": [ "apple", "banna" ]})
	> db.foo.find({"fruit": [ "apple", "peach", "banna" ]})
	> db.foo.find({"fruit": [ "apple", "banna", "peach" ]})
	{ "_id" : ObjectId("568bdf460c45f69abd83005f"), "fruit" : [ "apple", "banna", "peach" ] }

**(3).如果要查询数组特定位置的元素，使用key.index语法指定下标**

	> db.foo.find({"fruit.1": "tomato"})
	{ "_id" : ObjectId("568bdf990c45f69abd830060"), "fruit" : [ "apple", "tomato" ] }


**(4).`$all`通过多个元素匹配数组**

	//查询所有含apple的文档
	> db.foo.find({"fruit": {"$all": ["apple"]}})
	{ "_id" : ObjectId("568bdf460c45f69abd83005f"), "fruit" : [ "apple", "banna", "peach" ] }
	{ "_id" : ObjectId("568bdf990c45f69abd830060"), "fruit" : [ "apple", "tomato" ] }
	{ "_id" : ObjectId("568be1a50c45f69abd830061"), "fruit" : [ "apple", "tomato", "banna" ] }

	//查询既有apple又有banna的文档
	> db.foo.find({"fruit": {"$all": ["apple", "banna"]}})
	{ "_id" : ObjectId("568bdf460c45f69abd83005f"), "fruit" : [ "apple", "banna", "peach" ] }
	{ "_id" : ObjectId("568be1a50c45f69abd830061"), "fruit" : [ "apple", "tomato", "banna" ] }

	> db.foo.find({"fruit": {"$all": ["apple", "peach"]}})
	{ "_id" : ObjectId("568bdf460c45f69abd83005f"), "fruit" : [ "apple", "banna", "peach" ] }
	

这里顺序无关紧要。

**(5).`$size`查询特定长度的数组**

	> db.foo.find({"fruit": {"$size": 2}})
	{ "_id" : ObjectId("568bdf990c45f69abd830060"), "fruit" : [ "apple", "tomato" ] }

但是并不能与查询条件如$lt一块使用，替代方案是在插入数组的同时插入一个冗余的字段如arr_size, 每次操作数组就更新arr_size,这样就能：

	db.foo.find({"arr_size": {"$lt": 3}})

**(6).`$slice`操作符进行切片**

因为find第二个参数为指定返回，如数组则返回全部元素，可通过`$slice`进行切片返回部分元素。如返回博客前10条评论：

	db.blog.find(criteria, {"_id":0, "comments": {"$slice": 10}})

如果返回后10条，则`-10`即可。如果获取最后一条则为`-1`

也可指定偏移量，如[10, 20]

**(7).返回一个匹配的数组元素**
`$slice`是在知道数组下标的情况下很好用，如果不知道下标但需要返回一个相匹配的任意一个数组元素，则通过`$`操作符得到一个匹配的元素。如：


	> db.foo.find({"comments.name": "jack"}).pretty()
	{
		"_id" : ObjectId("568c540c0c45f69abd830062"),
		"post" : 1,
		"comments" : [
			{
				"name" : "bob",
				"uid" : 1001,
				"content" : "good"
			},
			{
				"name" : "jack",
				"uid" : 1002,
				"content" : "nice"
			},
			{
				"name" : "jack",
				"uid" : 1002,
				"content" : "I like it"
			}
		]
	}

	//只返回第一个匹配的文档
	> db.foo.find({"comments.name": "jack"}, {"comments.$": 1}).pretty()
	{
		"_id" : ObjectId("568c540c0c45f69abd830062"),
		"comments" : [
			{
				"name" : "jack",
				"uid" : 1002,
				"content" : "nice"
			}
		]
	}


**(8).数组和范围查询的相互作用**
在使用`$gt`,`$lt`等范围查询时，往往数组还会对其产生作用，看下面实例：


	//假如有如下文档
	{ "_id" : ObjectId("568c56120c45f69abd830063"), "x" : 5 }
	{ "_id" : ObjectId("568c56150c45f69abd830064"), "x" : 15 }
	{ "_id" : ObjectId("568c56170c45f69abd830065"), "x" : 25 }
	{ "_id" : ObjectId("568c561e0c45f69abd830066"), "x" : [ 5, 25 ] }

	//查询x键值位于10~20之间的文档
	> db.foo.find({"x" : {"$gt": 10, "$lt": 20}})
	{ "_id" : ObjectId("568c56150c45f69abd830064"), "x" : 15 }
	{ "_id" : ObjectId("568c561e0c45f69abd830066"), "x" : [ 5, 25 ] }

上面查询结果竟然有数组，因为25与第一个查询条件大于10匹配， 5与第二个查询条件小于20匹配，所以说**数组使用范围查询没有用：范围会匹配任意多元数组。**

## 3.4 内嵌文档
**有两种方法可以查询内嵌文档**：

- 查询整个文档（精准匹配且与顺序有关）
- 只针对其键值对查询（用点表示法查询内嵌文档的键）

推荐第二种：

	>db.people.find({"name.first": "Joe", "name.last": "Schmoe"})

注意：**查询文档可以包括`点`来表达“进入内嵌文档内部”的意思，所以该文档`键`不能包含`.`,如URL作为键时我们就应该将`.`进行全局替换。**

要注意的是对于查询多个条件可能存在问题，如：

	// 查询所有5分评论
	{"comment.author": "Joe", "comments.score": {"$gte": 5}}

则符合author和score条件的可能不是同一条评论，他们之间是或的关系。如果要正确的指定一组条件，而不必指定每个键，需要`$elemMatch`对限定条件进行分组，仅当需要对一个内嵌文档的多个键操作时才会用到：

	>db.blog.find({"comments": {"$elemMatch": {"author": "Joe",
					"score": {"$gte": 5}}}})

# 四.$where查询
**当使用键值对不好查询时，你应该想到`$where`, 它可以在查询中执行任意的Js, 虽然强大但也危险，应该严格限制。**

$where查询一般用的很少，因为它查询很慢，每个文档都要从BSON转换为Js对象再操作，且不能使用索引。

服务器上执行js是要注意安全性，与关系型数据库的注入攻击类似，我们应该在运行mongod时指定`--noscripting`关闭js的执行，以保证安全。

# 五.游标
**数据库使用游标返回find执行结果， 如果要迭代则使用游标的`next()`方法**：

	var cursor = db.foo.find();

	//cursor.hasNext()检查是否有后续结果存在
	> while(cursor.hasNext()){
	... obj = cursor.next();		// cursor.next()获取
	... //do stuff
	... }

游标还实现了Js的迭代器接口，可以在`forEach`循环中使用：

	> cursor.forEach(function(x) {print(x)})
	[object Object]
	....

**调用`find`时，shell并不立即查询数据库，而是等待真正开始要求获得结果时才发送查询，这样执行之前可以给查询附加额外的选项；几乎游标对象的每个方法都会返回游标本身，则可按任意顺序组成方法链**， 如下几种表达式是等价的：

	>var cursor = db.foo.find().sort({"x": 1}).limit(1).skip(10)
	>var cursor = db.foo.find().limit(1).sort({"x": 1}).skip(10)
	>var cursor = db.foo.find().skip(10).limit(1).sort({"x": 1})

此时查询还没有真正执行，所以这些函数都是构造查询，如果执行： 

	cursor.hasNext()

则开始查询。

注意游标用了后要**尽快释放**

Over~ 更详解则查看文档。

