---
layout: post
title: "Mongodb聚合"
header-img: "img/in-post/city.jpg"
category: "mongodb"
tags: [mongodb]
---
>图片来源：纪录片《轮回》

>人类对光的渴望与生俱来，在《圣经·创世纪》中被神第一个创造出来的便是光，从而区分明暗。人类通过光观察宇宙与尘埃，通过固定光的痕迹来记录时间与历史，用光重现过去演绎未来。人类对光的研究与控制也从未停止。 --《品质德国》

聚合的本质：**分析结果集**， 如下工具和命令：

- 聚合框架
	- 筛选(filtering)
	- 投射(projecting)
	- 分组(grouping)
	- 排序(sorting)
	- 限制(limiting)
	- 跳过(skipping)
- MapReduce
- 聚合命令
	- count
	- distinct
	- group

# 一.聚合框架
关于聚合，最好先查看文档:[**Aggregation Pipeline Operators**](https://docs.mongodb.org/manual/reference/operator/aggregation/) (呦西，很全), 剩下的事情就是在使用中慢慢总结了，不懂的就看文档。

**如果需要对查询数据做分析等特殊处理，就首先考虑聚合，可针对要处理的，聚合操作符分为算术，字符串，日期时间，数组，布尔，设置，比较等等，总有一款适合你。**

如计算用户发送事件最多的前10名排行榜：

	> db.event.aggregate({"$project": {"user_id": 1}},
	... {"$group": {"_id": "$user_id", "count": {"$sum": 1}}},
	... {"$sort": {"count": -1}},
	... {"$limit": 10})
	{ "_id" : 381709, "count" : 133 }
	{ "_id" : 426402, "count" : 91 }
	{ "_id" : 430556, "count" : 86 }
	{ "_id" : 289521, "count" : 64 }
	{ "_id" : 430569, "count" : 46 }
	{ "_id" : 431041, "count" : 35 }
	{ "_id" : 430517, "count" : 25 }
	{ "_id" : 381712, "count" : 19 }
	{ "_id" : 427115, "count" : 7 }
	{ "_id" : 430571, "count" : 7 }

`aggregate()`返回数组, 每个操作作为参数，逗号分隔，第一个处理完了交给第二个，以此类推，有点像*uinx管道符`|`的意思，在mongodb里也称之为**管道**， 下面来解释根据mongo提供的**管道操作符**

## 1.1 $match
`$match` 筛选的意思，如：

	{"$match": {"title": "good"}}

可以与常规**查询操作符**配合使用，如`$gt`,`$in`等， `$match`应该放在管道前面位置。

## 1.2 $project
`$project`投射的意思，与普通的find查询相比，它能够：

- 管道
- 从子文档中提取字段
- 可操作字段，如重命名字段

如下实例：

	//只投射出title字段
	> db.foo.aggregate({"$project": {"title": 1, "_id": 0}})
	{ "title" : "good" }
	{ "title" : "lll" }

	//注意哦，不存在也会显示
	> db.foo.find()
	{ "_id" : ObjectId("568e1534ba4afd0154378c08"), "title" : "good"}
	{ "_id" : ObjectId("568e170eba4afd0154378c09"), "title" : "lll"}
	{ "_id" : ObjectId("568f7b79203665df33bf39ef"), "pay" : { "book" : 1000, "food" : 3000 } }
	{ "_id" : ObjectId("568f7c2f203665df33bf39f0"), "pay" : "ok", "book" : 1000, "food" : 3000 }
	> db.foo.aggregate({"$project": {"pay": 1, "_id": 0}})
	{  }
	{  }
	{ "pay" : { "book" : 1000, "food" : 3000 } }
	{ "pay" : "ok" }

	//重命名title字段
	> db.foo.aggregate({"$project": {"重命名": "$title", "title": 1, "_id": 0}})
	{ "title" : "good", "重命名" : "good" }
	{ "title" : "lll", "重命名" : "lll" }

	> db.foo.aggregate({"$project": {"重命名": "$title"}})
	{ "_id" : ObjectId("568e1534ba4afd0154378c08"), "重命名" : "good" }
	{ "_id" : ObjectId("568e170eba4afd0154378c09"), "重命名" : "lll" }
	
总结：

- {"filename": 1}, 1表示投射该字段，0表示不投射.
- 如果投射的字段不存在则也会显示出来
- $filename, 表示要引用字段，如"$age"替换age字段的内容， "$tags.3"替换tags数组第4个元素
- 重命名字段后，如果该字段有索引则聚合框架内无法使用重命名后的字段索引， 如： {new: $old}, {'$sort': {"new": 1}} 无法使用索引，所以**在重命名前尽量先使用索引。**
- $project十分强大，还可使用表达式将多个字面量和变量组合在一个值中使用

**看文档，看文档，看文档。重要的事情说三遍。**

## 1.3 $group
根据特定字段进行分组。如果选定好要分组的字段后，传给`_id`字段。

	//根据天分组
	{$group: {_id: "$day"}
	
	//根据城市分组，每个city/state做分组
	{$group: {_id: {"state": "$state", "city": "$city"}}}


比如一份账单如下：

	> db.foo.find()
	{ "_id" : 1, "item" : "abc", "price" : 10, "quantity" : 2, "date" : ISODate("2014-03-01T08:00:00Z") }
	{ "_id" : 2, "item" : "jkl", "price" : 20, "quantity" : 1, "date" : ISODate("2014-03-01T09:00:00Z") }
	{ "_id" : 3, "item" : "xyz", "price" : 5, "quantity" : 10, "date" : ISODate("2014-03-15T09:00:00Z") }
	{ "_id" : 4, "item" : "xyz", "price" : 5, "quantity" : 20, "date" : ISODate("2014-04-04T11:21:39.736Z") }
	{ "_id" : 5, "item" : "abc", "price" : 10, "quantity" : 10, "date" : ISODate("2014-04-04T21:23:13.331Z") }

我们以月，天和年进行分组：
	
	// 构造分组条件
	var qs = {
		"$group" : {
			"_id" : {
				"month" : {
					"$month" : "$date"
				},
				"day" : {
					"$dayOfMonth" : "$date"
				},
				"year" : {
					"$year" : "$date"
				}
			}
		}
	}

	// 按月，天，年分组
	> db.foo.aggregate(qs)
	{ "_id" : { "month" : 3, "day" : 15, "year" : 2014 } }
	{ "_id" : { "month" : 4, "day" : 4, "year" : 2014 } }
	{ "_id" : { "month" : 3, "day" : 1, "year" : 2014 } }

我们还想查总价，评价数，分组数，可以用到分组操作符，分组操作符就是对每个分组进行计算。相关的操作符看参考[**Accumulator Operator¶**](https://docs.mongodb.org/manual/reference/operator/aggregation/group/#accumulator-operator)。

	{
		"$group" : {
			"_id" : {
				"month" : {
					"$month" : "$date"
				},
				"day" : {
					"$dayOfMonth" : "$date"
				},
				"year" : {
					"$year" : "$date"
				}
			},
			"totalPrice" : {
				"$sum" : {
					"$multiply" : [
						"$price",
						"$quantity"
					]
				}
			},
			"averageQuantity" : {
				"$avg" : "$quantity"
			},
			"count" : {
				"$sum" : 1
			}
		}
	}

	> db.foo.aggregate(qs)
	{ "_id" : { "month" : 3, "day" : 15, "year" : 2014 }, "totalPrice" : 50, "averageQuantity" : 10, "count" : 1 }
	{ "_id" : { "month" : 4, "day" : 4, "year" : 2014 }, "totalPrice" : 200, "averageQuantity" : 15, "count" : 2 }
	{ "_id" : { "month" : 3, "day" : 1, "year" : 2014 }, "totalPrice" : 40, "averageQuantity" : 1.5, "count" : 2 }

再比如说，分组后求最大，最小：

	> db.foo.aggregate({$group: {_id: "$item", "low": {"$min": "$price"},"max":{"$max": "$price"}}})

## 1.4 $unwind

拆分的意思，用于将数组中每个值拆分成独立文档，这个比较强大。如**查询特定子文档，然后$match进行在处理**

	> db.foo.find().pretty()
	{
		"_id" : ObjectId("568fd068"),
		"author" : "k",
		"post" : "hello world",
		"comments" : [
			{
				"author" : "Jack",
				"txt" : "good"
			},
			{
				"author" : "Li",
				"txt" : "well"
			}
		]
	}
	
	> db.foo.aggregate(
	... {$project: {"comments": "$comments"}},
	... {$unwind: "$comments"},
	... {$match: {"comments.author": "Jack"}}
	... )
	{ "_id" : ObjectId("568fd5324"), "comments" : { "author" : "Jack", "txt" : "good" } }
	
## 1.5 $sort
排序用的，与普通查询语法相同.

	{ $sort: { <field1>: <sort order>, <field2>: <sort order> ... } }

如下：

	//普通查询
	> db.foo.find().sort({"age": -1, "post": -1})
	//聚合
	> db.foo.aggregate({$sort: {age: -1, post: -1}})

比如有个员工表，要按照薪资高低排序，然后按照姓名A-Z排序：

	//构造$project投射条件，注意排序可以使用文档存在的字段，也可使用投射重命名的字段
	> f1
	{
		"$project" : {
			"money" : {
				"$add" : [
					"$salary",
					"$bonus"
				]
			},
			"name" : 1
		}
	}
	//构造$sort字段，如下的money字段,是薪资和奖金的和
	> f2
	{ "$sort" : { "money" : -1, "name" : 1 } }

	//执行聚合
	> db.foo.aggregate(f1)
	{ "_id" : ObjectId("569073e9eb107d"), "name" : "Jack", "money" : 12000 }
	{ "_id" : ObjectId("569073e9eb107e"), "name" : "Bob", "money" : 14000 }
	{ "_id" : ObjectId("569073e9eb107f"), "name" : "Alien", "money" : 9000 }
	{ "_id" : ObjectId("569073e9eb1080"), "name" : "Ben", "money" : 18000 }
	{ "_id" : ObjectId("569073e9eb1081"), "name" : "Zen", "money" : 14000 }

	//先按照薪资从高到低排序，然后在按照姓名A-Z正序
	> db.foo.aggregate(f1, f2)
	{ "_id" : ObjectId("569073e9eb1080"), "name" : "Ben", "money" : 18000 }
	{ "_id" : ObjectId("569073e9eb107e"), "name" : "Bob", "money" : 14000 }
	{ "_id" : ObjectId("569073e9eb1081"), "name" : "Zen", "money" : 14000 }
	{ "_id" : ObjectId("569073e9eb107d"), "name" : "Jack", "money" : 12000 }
	{ "_id" : ObjectId("569073e9eb107f"), "name" : "Alien", "money" : 9000 }

>注意：**如果对大量文档进行排序，首先应该在管道第一阶段进行排序，这时的排序操作可以使用索引，否则排序过程就比较慢，还会占用大量内存。**

如上的操作就不能使用索引，因为第一阶段是投射。

## 1.6 $limit
`$limit` n 返回集合中前n个文档

## 1.7 $skip
`$skip` n 丢弃集合中前n个文档

## 1.8 使用管道注意事项

- 在管道基于内存，将结果集放在内存中，所以要避免大文档，如果Mongodb发现聚合操作占用20%内存则报错
- 聚合操作的结果可以放在一个集合中方便以后使用
- 在聚合开始阶段尽可能的将文档或字段过滤掉，减少内存开销

# 二.MapReduce
MapReduce是非常强大的聚合工具，在上面的情况无法完成任务时，可尝试MapReduce，它**使用Js作为查询语言**，可以表达复杂的逻辑，但它**很慢**的。

# 三.聚合命令
注意区别聚合框架和聚合命令。在3.X版本中，它们都作为[**Collection Methods**](https://docs.mongodb.org/manual/reference/method/js-collection/), 不知道《Mongodb权威指南》怎么说成聚合命令的，还有一点就是书上版本太低，具体还要参考文档。

## 3.1 count
返回集合文档中数量

	> db.foo.count()
	5
	> db.foo.count({"name": "Jack"})
	1

注意：

- count()命令非常快，可做分页总数
- count()使用索引
- count({..}) 查询条件会使count变慢，还不如直接查询快。

## 3.2 distinct
找出给定键的所有不同值。

	db.collection.distinct(field, query)

如下实例：

	> db.bar.find({}, {_id: 0})
	{ "dept" : "A", "item" : { "sku" : "111", "color" : "red" }, "sizes" : [ "S", "M" ] }
	{ "dept" : "A", "item" : { "sku" : "111", "color" : "blue" }, "sizes" : [ "M", "L" ] }
	{ "dept" : "B", "item" : { "sku" : "222", "color" : "blue" }, "sizes" : "S" }
	{ "dept" : "A", "item" : { "sku" : "333", "color" : "black" }, "sizes" : [ "S" ] }

	> db.bar.distinct( "dept" )
	[ "A", "B" ]

	> db.bar.distinct( "item.sku" )
	[ "111", "222", "333" ]

	> db.bar.distinct( "item.sku", { dept: "A" } )
	[ "111", "333" ]

	//数组
	> db.bar.distinct( "sizes" )
	[ "M", "S", "L" ]

## 3.3 group
功能很强大，比集合框架的`$group`还牛叉，使用js做复杂的处理。文档[db.collection.group()](https://docs.mongodb.org/manual/reference/method/db.collection.group/#db-collection-group)在此。

> **最高效的学习就是：实践-->犯错-->大量应用-->回顾-->总结-->创新！可见工作环境是多重要，可以提供给你更多实践和探讨的机会。我就有点闭门造车了。**
