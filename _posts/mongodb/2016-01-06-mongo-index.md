---
layout: post
title: "Mongodb索引小结"
header-img: "img/in-post/tian-an-men.jpg"
category: "mongodb"
tags: [mongodb]
---
>摄于元旦晚天安门 2016/1/1

>只要你还在担心别人会怎么看你，他们就能奴役你；只有你再也不用从自身之外寻求肯定，才能成为自己的主人。 --尼尔·唐纳德·沃尔什

索引如同书籍目录，有则择页，无则翻书（如关系型数据库的**全表扫描**）。

比如我们插入10w数据，测试下：

	> for(i=0;i<100000;i++){
	... db.foo.insert(
	... {
	...     "i": i,
	...     "username": "user"+i,
	...     "age": Math.floor(Math.random()*120),
	...     "created": new Date()
	... })
	... }

使用`find`查询时可使用[`explain()`](https://docs.mongodb.org/manual/reference/method/cursor.explain/)查看执行详情，发现确实扫描了全部文档，**如果使用`limit(1)`则会一直扫描直到找到该文档**。如果我们用索引了，那就简单了。

	// username字段创建索引
	db.foo.ensureIndex({"username": 1})

再次使用`explain()`查看只扫码了1个文档，就是它自己。好了，开始我们的正文吧。

# 一.索引的优缺点

与关系型数据库的索引基本一致。

**优点：**

- 创建唯一性索引，保证数据的唯一性
- 加快数据的检索速度(主要原因)
- 索引的值是按照一定顺序排列的，使用索引键对文档进行排序非常快

**缺点：**

- 创建索引和维护索引要耗费时间，这种时间随着数据量的增加而增加
- 索引需要占物理空间
- 当对文档进行写操作（插入，更新，删除），索引也要动态的维护，降低了数据的维护速度

明白这些优缺点后有助于我们做抉择，该不该有索引？选择哪些索引？哪些字段比较合适？

**建议：**

- mongodb限制每个集合最多有64个索引，通常，在一个特定集合中，**索引数最好不要超过2个**
- 选择热点字段或有可能是性能瓶颈的字段做索引

# 二.索引类型

## 2.1 普通索引
就是单一索引

## 2.2 复合索引
复合索引(compound index)顾名思义就是多个索引。但是在排序时**只有首先在使用索引键进行排序，索引才有用。**如：

	// 索引没啥优势
	// 先根据age排序，再根据username排序
	> db.foo.find().sort({"age": 1, "username": 1}).limit(100)

故而需要在age上建立索引：

	//建立复合索引
	//注意顺序很重要，最好与.sort({"age": 1, "username": 1})顺序一致，这样查询才是最高效的
	db.foo.ensureIndex({"age": 1, "username": 1})

这样操作后上面的代码才能发挥索引的优势。嗖的一下就出来了。。

**mongodb对索引的使用方式取决于查询的类型，下面三种主要方式**

(1).单值查询，对已加索引键查询后，对其结果集进行排序

	>db.foo.find({"age": 21}).sort({"username": 1})
	{ "_id" : ObjectId("568cbdeb024"), "i" : 100029, "username" : "user100029", "age" : 21}
	{ "_id" : ObjectId("568cbdeb0c7"), "i" : 100080, "username" : "user100080", "age" : 21}
	{ "_id" : ObjectId("568bd8327a2"), "i" : 10043, "username" : "user10043", "age" : 21 }


匹配查询已经排序了(age)，然后在age的排序结果中再按照username排序。这样是比较高效的。


(2).多值查询，对已加索引键查询

	>db.foo.find({"age": {"$gte": 21, "$lte": 30}})
	{ "_id" : ObjectId("568cbdeb0c724"), "i" : 100029, "username" : "user100029", "age" : 21 }
	{ "_id" : ObjectId("568cbde848757"), "i" : 100080, "username" : "user100080", "age" : 21 }
	{ "_id" : ObjectId("568cbdbe0c45f"), "i" : 10043, "username" : "user10043", "age" : 21 }


这样也一样，**按索引键进行查询，那么查询结果文档通常是按照索引顺序排序的。**

(3). 在内存中排序 

	>db.foo.find({"age": {"$gte": 21, "$lte": 30}}).sort({"username": 1})
	{ "_id" : ObjectId("568cbdb778"), "i" : 10001, "username" : "user10001", "age" : 23}
	{ "_id" : ObjectId("568cbx871c"), "i" : 100021, "username" : "user100021", "age" : 29}
	{ "_id" : ObjectId("568cs48724"), "i" : 100029, "username" : "user100029", "age" : 21}

在内存中先排序后再返回。


## 2.3 唯一索引
**唯一索引确保集合中每个文档指定的键都有唯一值。**

	> db.user.ensureIndex({"uid": 1}, {"unique": true})
	> db.user.insert({"uid": 1001, "uname": "Jack"})
	> db.user.insert({"uid": 1001, "uname": "Rose"})
	..
	 	.."errmsg" : "E11000 duplicate key error index: foo.user.$uid_1 dup key: { : 1001.0 }"

我们熟悉的`_id`就是唯一索引，作为系统其不能被删除。

如果插入文档时缺少该索引字段的键，如：

	> db.user.insert({ "uname": "Rose"})
	WriteResult({ "nInserted" : 1 })

	//但是当我们在此插入时却报错了
	> db.user.insert({ "uname": "Luck"})
	..		
		.."errmsg" : "E11000 duplicate key error index: foo.user.$uid_1 dup key: { : null }"

**如果一个文档没有对应的键，索引会将其作为null存储，所以上述情况，由于集合中已存在一个该索引键的值为null的文档而导致插入失败。**

## 2.4 复合唯一索引
创建复合唯一索引时，单个键的值可以相同，但所有键的组合值必须是唯一的。
	
	//username,age复合唯一索引
	> db.user.ensureIndex({"username": 1, "age": 1}, {"unique": true})

	> db.user.insert({"username": "Jack"})
	WriteResult({ "nInserted" : 1 })
	
	> db.user.insert({"username": "Jack", "age": 20})
	WriteResult({ "nInserted" : 1 })
	
	> db.user.insert({"username": "Rose", "age": 18})
	WriteResult({ "nInserted" : 1 })
	
	> db.user.insert({"username": "Rose"})
	WriteResult({ "nInserted" : 1 })
	
	> db.user.insert({"username": "Rose"})
	WriteResult({
		"nInserted" : 0,
		"writeError" : {
			"code" : 11000,
			"errmsg" : "E11000 duplicate key error index: foo.user.$username_1_age_1 dup key: { : \"Rose\", : null }"
		}
	})
	
	> db.user.insert({"username": "Rose", "age": 18})
	WriteResult({
		"nInserted" : 0,
		"writeError" : {
			"code" : 11000,
			"errmsg" : "E11000 duplicate key error index: foo.user.$username_1_age_1 dup key: { : \"Rose\", : 18.0 }"
		}
	})
	
## 2.5 稀疏索引
上面的null问题，如果只针对存在的字段的做唯一，则需要稀疏索引。
	
	//对可选字段email做稀疏索引
	> db.user.ensureIndex({"email": 1}, {"unique": true, "sparse": true})

	> db.user.insert({"name": "jack", "age": 10, "email": "jack@163.com"})
	WriteResult({ "nInserted" : 1 })
	
	> db.user.insert({"name": "jack", "age": 10})
	WriteResult({ "nInserted" : 1 })
	
	> db.user.insert({"name": "jack", "age": 10})
	WriteResult({ "nInserted" : 1 })
	
	> db.user.insert({"name": "jack", "age": 10, "email": "jack@163.com"})
	WriteResult({
		"nInserted" : 0,
		"writeError" : {
			"code" : 11000,
			"errmsg" : "E11000 duplicate key error index: foo.user.$email_1 dup key: { : \"jack@163.com\" }"
		}
	})
	

# 三.操作符$使用索引
有些操作符无法使用索引，有些使用效率低，有些则高，这里总结下。

## 3.1 低效率的操作符

- `$exists`
- `$ne`
- `$not` & `$nin`

## 3.2 范围
复合索引大大优化了对于多字段查询效率，在使用时**将精准匹配的条件放在前面，将范围查询放在最后**，这样将使用第一个索引进行精准匹配，然后再使用第二个索引范围在这个结果集内部进行搜索。如：

	//使用{"age": 1, "username": 1}索引
	db.users.find({"age": 47, "username": {"$gt": "user5", "$lt": "user8"}})
	// 这个查询会直接定位到age为47的索引条目，然后在其中搜索用户名介于user5到user8的条目

	//如果反序使用{"username": 1, "age": 1}的索引
	//则查询必须先找到介于user5到user8所有用户(全表扫描了)，然后再从中挑选age=47的用户，这样会大大降低效率

# 四.索引对象和数组
可以对嵌套文档内部和数组建立索引，与正常索引行为操作一致。

## 4.1 索引嵌套文档
	
这里对内嵌文档name.first字段建立索引

	db.users.insert({  
	    "name":{  
	        "first":"Carey",  
	        "last":"Ickes"  
	    },  
	    "age":25  
	}) 
	//对第一个名字建立索引
	>db.users.ensureIndex({"name.first": 1})
	//查询发现效率挺高的
	>db.users.find({"name.first": "Jack100"}).explain("executionStats")

**注意**：

对嵌套文档本身“name”建立索引，与对嵌套文档的某个字段（name.first）建立索引是完全不相同的。

对整个文档建立索引，只有在使用文档完整匹配时才会使用到这个索引：

	//对嵌套文档本身“name”建立索引	
	>db.users.ensureIndex({"name":1})
	
	//这种完整匹配时才会使用到这个索引
	>db.users.find({"name":{"first":"xxx","last":"xxx"}})
	
	//是不会使用到该索引的。
	>db.users.find({"name.first":"xxx"})
 

## 4.2 索引数组
可以高效检索数组中的元素。

如博客评论，每篇文章都有一个comments字段作为数组，里面的每个子文档表示一条评论，如果要找出最近被评论次数最多的博客，则可以在comments数组的score键上建立索引：

	db.blog.insert({  
	    "_id":"B001",  
	    "title":"MongoDB查询",  
	    "comments":[  
	      {"name":"ickes","score":3,"comment":"nice"},  
	      {"name":"xl","score":4,"comment":"nice"},  
	      {"name":"eksliang","score":5,"comment":"nice"},  
	      {"name":"ickes","score":6,"comment":"nice"}  
	    ]  
	})

	>db.blog.ensureIndex({"comments.score":1})  

	>db.blog.find({"comments.score": {"$gt": 5}})

注意：

- **对数组建立索引，实际上是对数组的每个元素建立索引，要注意的是我们无法像嵌套文档一样对整个数组建立索引，而是每个元素，因此它要比单值索引代价要高。**
- 在数组上建立的索引并不包含任何位置信息：无法使用数组索引查找特定位置的数组元素，比如"comments.4".
- 一个索引中数组字段最多只能有一个。这是为了避免在复合索引中索引条目爆炸性增长。
- 对于某个索引的键，如果这个键在某个文档中是一个数组，那么这个索引就会标记为多键索引。可以从explain()的输出信息中看到一个索引是否为多键索引。如果是多键索引,那么"isMultikey"字段的值就会为true。索引只要被标记为多键索引，就无法再变成非多键索引，即使索引的键从文档中删除也不行。唯一的办法就是删除重建。

# 五.索引取舍

>结果集在原集合中占的比例越大，索引的速度就越慢，因为使用索引需要进行两次查找，**一次是查找索引条目，一次是根据索引指针去查找相应的文档。**而全表扫描只需要进行一次查找：查找文档。

索引通常适用的情况 | 全表扫描适用情况 
----|------
集合较大 | 集合较小  
文档较大 | 文档较小
选择性查询 | 非选择性查询

# 六.索引管理

- 索引只创建一次，重复创建则无反应
- 所有索引都存储在system.indexes集合中
- db.collection.getIndexes() 查看指定集合上的所有索引信息
- 索引顺序很重要， {x: 1, y: 1} 与{y: 1, x: 1}索引不同
- 索引名称默认形式是：keyname1_dir1_keyname2_dir2_... keyname为索引的键，dir为索引的方向
- 可以在ensureIndex中添加{"name": "索引别名"}来标识索引
- dropIndex()删除索引， db.user.dropIndex({"age": 1}) == db.user.dropIndex("age_1")
- 在创建索引时指定background选项在后台创建索引，异步处理，不会阻塞请求，当有请求是则索引创建动作暂停下来；但比前台创建索引慢得多。




