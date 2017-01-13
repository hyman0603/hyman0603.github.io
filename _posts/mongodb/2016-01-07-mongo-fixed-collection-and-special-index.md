---
layout: post
title: "Mongodb固定集合和特殊索引"
header-img: "img/in-post/city-light.jpg"
category: "mongodb"
tags: [mongodb]
---
>图片来自纪录片《轮回》

>德国哲学中的德意志精神，始终与人密切相关。黑格尔认为，国家是人自由的真正体现。马克思则相反，说只有消除国家，人的本质才能真正恢复。-- 《品质德国》

# 一.固定集合
固定集合就是创建一个指定大小的集合，有如下特点：

- 有序排列，插入速度快
- 大小固定，当插满后最老的数据会被删除，然后插入新数据
- 固定集合不能分片
- 一旦创建完成就不能再更改其属性了，除非删掉重建
- 提供循环游标，不断的对查询结果(getNext())进行处理，如果hasNext()没有数据则等待插入，一旦有数据则立马处理，等待10分钟后自动释放(dead())


固定集合必须显式创建

	//创建名为my_collection最大字节10000的固定集合
	> db.createCollection("my_collection", {"capped": true, "size": 10000})
	{ "ok" : 1 }

	//创建名为my_collection_2最大字节为10000且最大文档数为100的固定集合
	> db.createCollection("my_collection_2", {"capped": true, "size": 10000, "max": 100})
	{ "ok" : 1 }

固定集合适用：

- 记录日志
- 记录Top,如最新的10条新闻
- 限制， 如以每个用户作固定集合名，限制其创建的最大文档数，如果超限了，呵呵，付费。

记住：**可以将常规集合转换为固定集合，但不能将固定集合转为常规集合**

	db.runCommand({"converToCapped": "normal_collection", "size": 1000})

由于固定集合有插入顺序，那么在查询的时候需要使用`{"$natural" : -1}`进行自然排序（就是文档在磁盘的顺序）。

	db.my_collection.find().sort({"$natural": -1})

# 二.特殊索引

## 2.1 TTL索引

设置过期时间，超时后该文档会被删除。如下：

	//mydate日期时间字段加ttl索引，超时时间2min
	db.foo.ensureIndex({"mydate": 1}, {"expireAfterSeconds": 60*2})

	> db.foo.insert({"my": "bm", "mydate": new Date()})
	WriteResult({ "nInserted" : 1 })

	> db.foo.find()
	{ "_id" : ObjectId("568e1b2d203665df33bf39ee"), "my" : "bm", "mydate" : ISODate("2016-01-07T08:00:45.009Z") }

	// 2min后查询发现被删了
	> db.foo.find()

我个人不太推荐过期处理用它，我觉得不如redis用着爽，因为我第一次创建的时候等了好久数据竟然没删掉，之后重新设置ttl索引，才有效，还有几点注意：

- TTL索引只能建立在单独字段上，在复合索引上无法指定TTL属性
- 只能用于日期时间对象的字段
- 如果索引字段包含一个数组且其中有多个日期类型数据, MongoDB 将会匹配最早的一个日期移除数据.
- 创建TTL索引后，MongoDB会有一个TTL后台线程来负责管理文档，当达到超时间时会将文档删除
- TTL索引不能保证达到过期时间时，立即将文档删除，中间可能会有一定的延迟
- 至于过期文档的移除操作, MongoDB 的后台任务会**每分钟**检查一次过期文档, 并且移除操作的耗时也要取决于当前服务器的负载, 所以过期文档通常会存在一个移除延迟, 这个时间可能会超过 1 分钟.
- 除了以上限制外, TTL 索引和普通索引没任何区别, 也可以用来进行查询.

也可以随时修改这个时间阈值

	db.runCommand({"collMod": "集合名.文档字段", "expireAfterSecs": 秒})

## 2.2 全文本索引
我这一本《Mongodb权威指南》太尼玛老了，版本太低了。full text search(fts：全文搜素)是在版本2.4新加的特性，我估计该书使用的就是2.4版本。目前支持15种语言(就是**不支持中文**，世界第一语言竟然都不支持。)的全文索引。

还有一点，创建全文本索引是最耗性能的，目前还不稳定，常用全文检索有lucene，sphinx，redis。

可参考[mongodb 全文搜索—ttlsa教程系列之mongodb(十)](http://www.ttlsa.com/mongodb/mongodb-full-text-search-mongodb-ttlsa-tutorial-series/)

## 2.3 地理空间索引
对于LBS(Location-Based Service，LBS)置于位置的服务用的越来越多，Mongodb专门针对这种查询建立了地理空间索引。 2d和2dsphere索引，分别是针对平面和球面。

针对2dsphere索引，球面的，可以按照坐标轴：经度，纬度的方式把位置数据存储为GeoJSON对象。

这里了解下，没搞过LBS项目。

## 2.4 GridFS存储文件
mongodb使用mongofiles工具

**谨记:对于不熟悉的命令首先一定要--help查看帮助！**

`mongofiles --help`查看帮助

	➜  ~  mongofiles -d gridfs put a.txt 
	2016-01-07T17:00:23.556+0800	connected to: localhost
	added file: a.txt

	> use gridfs
	switched to db gridfs
	// 获取文件信息
	> db.fs.files.find()
	{ "_id" : ObjectId("568e29273a53f23565000001"), "chunkSize" : 261120, "uploadDate" : ISODate("2016-01-07T09:00:23.897Z"), "length" : 129, "md5" : "f4d682f9c86e5f18af876f13ff4b4b46", "filename" : "a.txt" }
	// 获取文件块
	> db.fs.chunks.find({files_id: ObjectId("568e29273a53f23565000001")})
	{ "_id" : ObjectId("568e29273a53f23565000002"), "files_id" : ObjectId("568e29273a53f23565000001"), "n" : 0, "data" : BinData(0,"am9bmdoYWkK") }
	
>对于小文件如大量图片等可以用[fastDFS](http://tech.uc.cn/?p=221)存储，不应该用mongodb GridFS，因为其本质上只是把文件内容存储在16M大小限制的document中，如果你只是存储图片文件，图片文件不大可能超过16M，如果要存储视频文件，使用GridFS倒是可以更利于产生流信息，因为一次只需要读取一个Document。 

对于Python的使用，可看下这个小项目[flask mongodb GridFS实例](https://github.com/BeginMan/flask-dessert/blob/master/tools/mongo_gridfs-app.py)


