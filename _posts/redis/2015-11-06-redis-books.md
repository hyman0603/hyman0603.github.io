---
layout: post
title: "《redis入门指南》读书笔记"
description: "redis book"
category: "redis"
tags: [redis]
---
此书是redis入门教程，大概分为基础命令，一些高级功能，脚本扩展与部署管理四个方面。去年买的书读的断断续续，耗时耗力，**以后一定要记住：读书保持连贯性，持续性，总结性。**

1. 简介与特性
2. 类型与基础命令
3. 高级进阶
4. python与nodejs实战
5. 脚本扩展
6. 管理

# 一.简介与特性
redis是意大利一家创业公司由于不满mysql性能问题，特此开发了这个高性能的nosql,仅仅耗时一年。想一想如果是我们，我们可能就会妥协，可能就会认为mysql是十分优秀的产品，有些不好的地方又能有啥呢，凑合用呗。这就是国外开发者与国内开发者的最大区别，**不妥协，求创新，求完美**才是程序员要追求的境界。

Redis(REmote DIctionary Server, 远程字典服务器)的缩写，它以字典结构存储数据。支持的数据类型有：

- 字符串类型
- 散列类型
- 列表类型
- 集合类型
- 有序集合类型

注意，**redis基于内存，所有数据都存储在内存中，可以其瓶颈所在也是内存。redis提供了持久化，可以将内存中的数据异步写入磁盘中。**，redis可以为每个键设置生存空间(Time To Live, TTL),可以做缓存服务，与memcached常常用于比较，**redis是单线程，memcached是多线程，在多核服务器上性能高些。但是如果想要更多数据类型和持久化等，redis是不二之选。**

redis的安装要注意，版本号奇数是非稳定版，偶数是稳定版。redis安装后有如下可可执行文件：

	redis-server		Redis服务器
	redis-cli			Redis命令行客户端
	redis-benchmark		Redis性能测试工具
	redis-check-aof		AOF文件修复工具
	redis-check-dump	RDB文件检查工具

## 1.1 正确启动redis服务
通过以下方式启动：

	redis-server /path/to/redis.conf
	redis-server /path/to/redis.conf --loglevel warning

关于配置文件,redis.conf或6379.conf详解如下，还可以在命令行中动态修改部分redis配置，如：

	127.0.0.1:6379> CONFIG GET loglevel
	1) "loglevel"
	2) "notice"
	127.0.0.1:6379> CONFIG set loglevel warning
	OK
	127.0.0.1:6379> CONFIG GET loglevel
	1) "loglevel"
	2) "warning"
	

可以先`ping`下可连接是否正常，如下：

	redis-cli -a yourpasswd ping
	PONG

或者：

	redis-cli -a yourpasswd
	redis 127.0.0.1:6379>ping
	PONG

如下图可以通过命令动态修改配置文件

![](http://beginman.qiniudn.com/redis-cli-up1.png)

![](http://beginman.qiniudn.com/redis-cli-up2.png)

## 1.2 正确停止redis服务
Redis可能这个时候正将这个内存中的数据同步到硬盘中，如果强行终止redis进程可能导致数据丢失，正确的方式是`save`数据同步后向redis发送`SHUTDOWN`命令：

	redis-cli shutdown save

当redis收到这个命令后会先断开所有客户端连接，然后根据配置执行持久化，最后完成退出。Redis可以妥善处理`SIGTERM`信号，所以`kill redisPID`同`SHUTDOWN`一样，不过个人还是觉得**最好用shutdown**。

# 二. 类型与基础命令
## 2.1 基础命令及命令返回值

1. 状态回复，如ping,回复PONG, set回复OK
2. 错误回复，当命令不存在或格式错误则返回以`(error)`开头的错误，后面是错误信息
3. 整数回复，如incr,dbsize等返回`(integer) 1`等信息
4. 字符串回复，如get foo
5. 多行字符串回复，如`keys *`

注意del不支持通配符，但是可以集合Linux管道和xargs命令实现删除所有符合规则的键，如下删除所有`user:*`开头的键：

	redis-cli KEYS "user:*" | xargs redis-cli DEL
	
由于del命令可以支持多个键做参数，下面的命令更加高性能：

	redis-cli DEL `redis-cli KEYS "user:*"`

如果选择数据库，则可以用`-n` 命令，如选择数据库2，则`-n 2`

如下实例：

	➜  src  ./redis-cli -a yourpasswd keys "user:*"
	1) "user:2:age"
	2) "user:1:age"
	3) "user:1:sid"
	4) "user:2:sid"
	5) "user:2:name"
	6) "user:1:name"
	➜  src  ./redis-cli -a yourPasswd keys "user:*" | xargs ./redis-cli -a yourPasswd del
	(integer) 6

如下删除数据库1下所有`contact:c:*`

	./redis-cli -a yourPasswd -n 1 keys "contact:c:*"|xargs ./redis-cli -a yourPasswd -n 1 del

可以通过`type key`查看数据类型

**redis键值设计：业界约定俗称的是：对象类型:对象ID:对象属性，如`user:1:name`, 对多个单词则推荐用`.`分隔，如`user:1:address.work` **

对于redis的存储可以用字符串，josn,还可存储二进制数据，可以用[MessagePack](http://msgpack.org/index.html)进行序列化，序列化后占用空间更少，性能更，值得一试。如：

![](http://beginman.qiniudn.com/MessagePack__It_s_like_JSON__but_fast_and_small_.png)


![](http://beginman.qiniudn.com/MessagePack__It_s_like_JSON__but_fast_and_small2_.png)


## 2.2 字符串类型
### (1).基础命令：

`SET key value`: 设置键并赋值

`GET key`:读取键值

`INCR key`: 递增数字

`INCRBY key increment`: 增加指定的整数， 如`incrby foo 100`, 如果foo不存在则赋值100，否则增值100。

`DECR key`: 递减

`DECRBY key increment`：减少指定的整数，相当于incrby key -increment

`incrbyfloat key increment`: 增加指定浮点数，减少则decr...是个双精度浮点数，如前面的整数foo 使用如下命令：`INCRBYFLOAT foo 0.02`则变成了浮点数（这里以字符串形式表示）"300.01999999999999999"

`append key value`: 向尾部追加值，如果键不存在则创建并设置value，返回的是追加后字符串总长度，如：

	127.0.0.1:6379> set name begin
	OK
	127.0.0.1:6379> get name
	"begin"
	127.0.0.1:6379> APPEND name " man"
	(integer) 9
	127.0.0.1:6379> get name
	"begin man"

**注意APPEND第二个参数使用了双引号，原因是该参数包含空格，在redis-cli中输入需要双引号区分。**

`strlen key`: 获取字符串长度

`mget key [key ...]`: 获取多个键值

`mset key value [key value ...]`：设置多个键值

### (2). 位操作
一个字节由8为二进制组成，redis提供4种命令可以直接对二进制位进行操作，如

	redis>set foo bar


![](http://beginman.qiniudn.com/redis_bin_test.png)

`getbit key offset`: 获取key在索引offset（偏移量）下的二进制位(0或1)，索引从0开始，如：

	127.0.0.1:6379> GETBIT foo 0
	(integer) 0
	127.0.0.1:6379> GETBIT foo 1
	(integer) 1
	127.0.0.1:6379> GETBIT foo 2
	(integer) 1
	
	127.0.0.1:6379> GETBIT foo 100000
	(integer) 0

如果超出索引则为0

`setbit key offset value`：是在key指定的offset(偏移量)下设定为value值，如

	127.0.0.1:6379> SETBIT foo 6 0
	(integer) 1
	127.0.0.1:6379> SETBIT foo 7 1
	(integer) 0
	127.0.0.1:6379> get foo
	"aar"

如果超过了索引，则将中间二进制位设为0,如：

	127.0.0.1:6379> SETBIT nofoo 7 1
	(integer) 0
	127.0.0.1:6379> get nofoo
	"\x01 "
	127.0.0.1:6379> GETBIT nofoo 7
	(integer) 1
	127.0.0.1:6379> GETBIT nofoo 6
	(integer) 0

`bitcount key [start] [end]`: 可以获得字符串的值是1的二进制位的个数，如：

	127.0.0.1:6379> BITCOUNT foo   # 统计全部
	(integer) 10
	127.0.0.1:6379> BITCOUNT foo 0 1  # 统计前两个字符，'ba'
	(integer) 6
	
`bitop operation destkey key [key...]`: 对多个字符串类型进行位操作，并将结果存储到destkey中，支持的运算操作有：AND, OR,XOR,NOT.

	127.0.0.1:6379> set foo1 bar
	OK
	127.0.0.1:6379> set foo2 aar
	OK
	127.0.0.1:6379> BITOP OR res foo1 foo2
	(integer) 3
	127.0.0.1:6379> get res
	"car"

关于使用二进制的几个典型案例，如减少存储空间，快速排序，运算，统计，日活等，可以参考这篇文章[beginman:redis bitmaps的妙用实现节省存储，快速查询，操作，统计](http://beginman.cn/redis/2015/11/03/redis-bit/)

## 2.3 散列(hash)类型

hash是一种字典结构，不同python的dict，其键值对可以是很多类型，**在redis中hash类型的key,value只能是字符串，不能嵌套其他数据类型**。其应用场景是**对象**。

`hset key field value`, `hmset key field value [field value ...]` 是一组，单独或批量添加如：

	hmset user:1 name "begin man" age 24 sex 1 address "中国 北京 天通苑西三区"

`hget key field`, `hmget key field [field ....]`是一伙的，用于查看key哈希键下的字段，如：

	127.0.0.1:6379> HMGET user:1 name age address
	1) "begin man"
	2) "24"
	3) "\xe4\xb8\xad\xe5\x9b\xbd \xe5\x8c\x97\xe4\xba\xac \xe5\xa4\xa9\xe9\x80\x9a\xe8\x8b\x91\xe8\xa5\xbf\xe4\xb8\x89\xe5\x8c\xba"

`hgetall key` 则获取key下所有k-v对。

**注意，`hset`不区分插入和更新，意味着不用事先判断字段是否存在。但不存在则插入则返回1，如果存在则更新则返回0，如果整个key不存在则建立。**

`hexists key field`:  判断字段是否存在

`hsetnx key field value`: 当字段不存在时赋值(返回1)，与`hset`不一样的是只要字段存在则不进行任何操作(返回0)。

`hincrby key field increment`: 增加数字，则返回增大后的数字，没有则创建,key不存在则创建，如下：

	127.0.0.1:6379> HINCRBY user:1 age 10
	(integer) 34
	127.0.0.1:6379> HINCRBY user:1 agess 10
	(integer) 10
	127.0.0.1:6379> HINCRBY user:2 agess 10
	(integer) 10

`hdel key field [field ...]`: 删除一个或多个字段，返回被删除的个数

`hkeys key`: 只获取字段名，有点像python的 dict.keys()

`hvals key`: 只获取字段值，像python的dict.values()

`hlen key`: 获取字段数量

## 2.4 列表类型
列表类型内部是C的双向链表实现的，向两端插入数据的时间复杂度为O(1), 代价就是通过索引访问元素比较慢，特别是数据量大的情况下。使用场景如获取前n条新鲜事，由于两端插入时间复杂度为O(1)则可以做记录日志，消息队列等。

`lpush key value [value ...]`: 从左边插入依次插入数据；`rpush key value [value ...]`: 右边插入；都返回总长度

`lpop key`,`rpop key`:从列表两端弹出元素

`llen key`: 获取长度, 不存在则返回0

`lrange key start stop`: 获取列表片段

`lrem key count value`: 删除列表中指定个数的指定的值，count为正则从左开始删除count个，负则反之，0则所有

`lindex key index`: 获取指定索引的元素值，`lset key index value`: 则设置指定索引的元素值。

`ltrim key start stop`: 只保留列表指定片段，如

	>lrange lis 0 -1
	1) "200"
	2) "100"
	3) "two"
	4) "one"

	#只保留"two","one"
	> LTRIM lis 2 3
	OK
	> lrange lis 0 -1
	1) "two"
	2) "one"
	
`linsert key before|after pivot value`: 在列表中从左到右查找值为pivot的元素，然后根据before或after进行插入，返回插入后列表个数，如：

	127.0.0.1:6379> LINSERT lis after two 100
	(integer) 3
	127.0.0.1:6379> lrange lis 0 -1
	1) "two"
	2) "100"
	3) "one"

`rpoplpush source destination`：从source列表`rpop`删除元素，删除的元素`lpush`插入到destination列表中，并返回这个元素的值，整个过程原子的。

	127.0.0.1:6379> lrange lis 0 -1
	1) "two"
	2) "100"
	3) "one"
	127.0.0.1:6379> RPOPLPUSH lis lis2
	"one"
	127.0.0.1:6379> lrange lis 0 -1
	1) "two"
	2) "100"
	127.0.0.1:6379> lrange lis2 0 -1
	1) "one"


## 2.5 集合类型
集合类型是无序的，唯一的，时间复杂度O(1)的，能实现并集，交集，差集运算的。。

`sadd key member [member ...]`: 增加元素，相反删除元素`srem ...`

`smembers key`: 获取集合中所有元素

`sismember key member`: 判断元素是否存在集合中

`sdiff key [key ...]`: 多个集合差集

`sinter key [key ...]`: 多个集合交集

`sunion key [key ...]`: 多个集合并集

`scard key`: 获得集合元素个数

`sdiffstore destination key [key ...]`: 多个集合求差集并存储在destination中，`sinterstore ..`,`sunionstore ..`同上

`srandmember key [count]`: 随机获取集合的元素

`spop key`: 弹出元素，由于无序则随机弹出

## 2.6 有序集合
`zadd key score member [score member ...]`: 增加元素和该元素的分数，如果已经存在该元素则更新其分数

`zscore key member`: 获取该元素的分数

`zrange key start stop [withscores]`: 获取排名在某个范围内的元素列表，会按照从小到大顺序返回索引从start到stop之间的所有元素，包括两端，`zrevrange`则表示反序。

`zrangebyscore key min max [withscores] [limit offset count]`: 获取指定分数范围的元素，按照分数从小到大在min~max范围之间(包含min max)的元素，如：

	127.0.0.1:6379> ZADD test 20 java 10 python 30 js 40 c/c++ 80 go 90 swift
	(integer) 6
	
	127.0.0.1:6379> ZRANGEBYSCORE test 30 80		# 分数在30-80之间
	1) "js"
	2) "c/c++"
	3) "go"
	
	127.0.0.1:6379> ZRANGEBYSCORE test 30 (80		# 不包括80端
	1) "js"
	2) "c/c++"
	127.0.0.1:6379> ZRANGEBYSCORE test (30 80		# 不包括30端
	1) "c/c++"
	2) "go"
	127.0.0.1:6379> ZRANGEBYSCORE test (30 (80		# 不包括30和80端
	1) "c/c++"
	127.0.0.1:6379> ZRANGEBYSCORE test 50 +inf		# +inf表示正无穷，-inf表示负无穷
	1) "go"
	2) "swift"
	127.0.0.1:6379> ZRANGEBYSCORE test 30 +inf
	1) "js"
	2) "c/c++"
	3) "go"
	4) "swift"
	127.0.0.1:6379> ZRANGEBYSCORE test 30 +inf limit 1 3  # 获取分数高于30的从第二个开始的3个元素
	1) "c/c++"
	2) "go"
	3) "swift"


注意`zrevrangebyscore`是其反序

`zincrby key increment member`: 增加某个元素的分数，可正负，不存在则创建后设置分数为0然后再进行incr操作,如：

	127.0.0.1:6379> ZINCRBY test 100 java
	"120"

`zcard key`: 查看集合中元素个数

`zcount key min max`:获取指定分数范围内的元素个数

`zrem key member [member ..]`: 删除一个或多个元素

`zremrangebyrank key start stop`: 按照排名范围删除元素，这里按照元素分数从小到大的顺序（即索引0表示最小值）删除元素，如：

	127.0.0.1:6379> zadd testRem 1 a 2 b 3 c 4 d 5 f 6 e
	(integer) 6
	127.0.0.1:6379> ZRANGE testRem 0 -1
	1) "a"
	2) "b"
	3) "c"
	4) "d"
	5) "f"
	6) "e"
	127.0.0.1:6379> zremrangebyrank testRem 0 2
	(integer) 3
	127.0.0.1:6379> ZRANGE testRem 0 -1
	1) "d"
	2) "f"
	3) "e"


`zremrangebyscore key min max`: 按照分数范围删除元素

`zrank key member`: 获取元素排名，从0开始，0表示最小，`zrevrank`则反序，0表示最大。接着上面的例子分析：

	127.0.0.1:6379> zrank testRem f
	(integer) 1
	127.0.0.1:6379> zrank testRem d
	(integer) 0
	127.0.0.1:6379> zrevrank testRem d
	(integer) 2
	127.0.0.1:6379> zrevrank testRem f
	(integer) 1
	127.0.0.1:6379> zrevrank testRem e
	(integer) 0

`zinterstore des numkeys key [key ...] [weights weight [weight...]] [aggregate sum|min|max] `: 计算有序集合的交集，这个命令算是redis里面最复杂的一个了。我们慢慢分析啊。

这个命令是将多个有序集合求交集并存储在des有序集合键中，返回des元素的个数。des元素分数是由aggregate来决定的：

(1) 当aggregate为sum时(默认)，des元素分数是参与计算的集合中各元素分数之和，如：

	127.0.0.1:6379> zadd test1 1 a 2 b
	(integer) 2
	127.0.0.1:6379> zadd test2 100 a 100 b
	(integer) 2
	127.0.0.1:6379> ZINTERSTORE des 2 test1 test2 
	(integer) 2
	127.0.0.1:6379> ZRANGE des 0 -1 withscores
	1) "a"
	2) "101"
	3) "b"
	4) "102"

(2) 当aggregate为MIN时，则分数为all keys中的最小值，如：

	127.0.0.1:6379> ZINTERSTORE des 2 test1 test2 aggregate min 
	(integer) 2
	127.0.0.1:6379> ZRANGE des 0 -1 withscores
	1) "a"
	2) "1"
	3) "b"
	4) "2"
	
(3) 当aggregate为MAX，则分数为all keys中最大值，如：

	127.0.0.1:6379> ZINTERSTORE des 2 test1 test2 aggregate max
	(integer) 2
	127.0.0.1:6379> ZRANGE des 0 -1 withscores
	1) "a"
	2) "100"
	3) "b"
	4) "100"

(4) weights为每个集合设置权重，每个元素分数会乘以该权重，如：

	127.0.0.1:6379> ZINTERSTORE des 2 test1 test2 weights 10 0.1 aggregate min 
	(integer) 2
	127.0.0.1:6379> ZRANGE des 0 -1 withscores
	1) "a"
	2) "10"
	3) "b"
	4) "10"

如果求并集则用`zunionstore`,用法同上不再累述。

案例：比如通过`posts:page:view` 对文章ID和点击率进行存储以实现点击率排序。如果展示某个文章的访问量则可以通过`zsocre posts:page:view 文章ID` 来实现。还可用时间戳做排序因子以实现各种统计如文章归档等。


**更多redis命令参考：[Redis 命令参考](http://redisdoc.com/)**
# 三.高级进阶
高级进阶涉及的是redis事务，排序与管道等。

## 3.1 事务
redis中的事务其实是一组命令的组合执行，比如微博关注，A关注B，A的following则添加B,B的Followers需要将A添加进去，这两个命令是一块执行的，要么不执行，要么都执行，一旦有一个命令没有执行则逻辑上不通了。为了解决此类问题，事务就出现了。涉及事务的命令有：

- `multi`:标记一个事务块的开始。事务块内的多条命令会按照先后顺序被放进一个队列当中，最后由 EXEC 命令原子性(atomic)地执行。
- `exec`:执行所有事务块内的命令。
- `watch`:监视一个(或多个) key ，如果在事务执行之前这个(或这些) key 被其他命令所改动，那么事务将被打断。
- `unwatch`:取消 WATCH 命令对所有 key 的监视。

那么上面的场景就可以用事务来执行：

	redis>multi
	OK
	redis>sadd "user:1:following" 2
	QUEUED
	redis>sadd "user:2:followes" 1
	QUEUED
	redis>EXEC
	1) (integer) 1
	2) (integer) 1

上面例子multi告诉redis下面的一系列命令都是属于一个事务块的，先不执行暂存起来，OK则表示事务开始，QUEUED表示命令存入待执行队列中，exec则表示开始执行所有事务块中的命令了，执行结果则是每个命令的结果。

我们最好保证事务里的命令都是正确的，如果因为**语法错误**则立马提示错误，执行exec也会提示相应的错误，如下：

	127.0.0.1:6379> MULTI
	OK
	127.0.0.1:6379> inc us
	(error) ERR unknown command 'inc'
	127.0.0.1:6379> exec
	(error) EXECABORT Transaction discarded because of previous errors.

还有一种情形是**运行错误**，exec后会在结果中打印该命令的错误，但还是正常执行，如下：

	127.0.0.1:6379> MULTI
	OK
	127.0.0.1:6379> set key 1
	QUEUED
	127.0.0.1:6379> sadd key 2
	QUEUED
	127.0.0.1:6379> exec
	1) OK
	2) (error) WRONGTYPE Operation against a key holding the wrong kind of value

**虽然还是执行了但是数据的完整性不能保证，因为redis事务不支持回滚，我们必须自己收拾烂摊子，所以使用事务的时候务必认真小心，并考虑各种可能出现的情况做好善后准备。**

`watch`可以监视一个或多个key,直到exec执行，如果被监视的key被修改或删除则之后的事务就不会执行。

	127.0.0.1:6379> set key 1
	OK
	127.0.0.1:6379> WATCH key
	OK
	127.0.0.1:6379> set key 2
	OK
	127.0.0.1:6379> get key
	"2"
	127.0.0.1:6379> MULTI
	OK
	127.0.0.1:6379> set key 3
	QUEUED
	127.0.0.1:6379> exec
	(nil)
	127.0.0.1:6379> get key
	"2"

注意watch在事务中才有效哦，如果想要取消watch则使用unwatch命令，如果执行了exec或discard命令则自动会取消watch. 

## 3.2 排序
我们知道**sorted set没有set类型的集合操作灵活，如果即需要sorted sort类型的强大又要sort集合操作的灵活则可以配合sort命令,`sort`命令可以对list,set,sorted set类型进行排序并且可以完成与关系数据库中连接查询相似的任务**。这里最好看下[文档](http://redisdoc.com/key/sort.html),其命令参数特别长：

	SORT key [BY pattern] [LIMIT offset count] [GET pattern [GET pattern ...]] [ASC | DESC] [ALPHA] [STORE destination]

如下测试：

	redis> LPUSH today_cost 30 1.5 10 8
	(integer) 4
	redis> SORT today_cost
	1) "1.5"
	2) "8"
	3) "10"
	4) "30"

最简单的sort key,如果倒序则set key desc.

注意：因为 SORT 命令默认排序对象为数字， 当需要对字符串进行排序时， 需要显式地在 SORT 命令之后添加 ALPHA 修饰符：

	# 网址

	redis> LPUSH website "www.reddit.com"
	(integer) 1

	redis> LPUSH website "www.slashdot.com"
	(integer) 2

	redis> LPUSH website "www.infoq.com"
	(integer) 3

	# 默认（按数字）排序

	redis> SORT website
	1) "www.infoq.com"
	2) "www.slashdot.com"
	3) "www.reddit.com"

	# 按字符排序

	redis> SORT website ALPHA
	1) "www.infoq.com"
	2) "www.reddit.com"
	3) "www.slashdot.com"

还有一个少见的命令`by`,语法为 `by 参考键`。其中参考键可以是字符串类型或散列类型的某个字段（表示为键名->字段名），如果提供了by参数则sort命令将不会在依据元素自身值进行排序，而是对每个元素使用的值替换参考键中的第一个`*`并获取其值，然后再依据该值对元素进行排序，如：

	127.0.0.1:6379> LPUSH sortbylist 2 1 3
	(integer) 3
	
	127.0.0.1:6379> set itemscore:1 50
	OK
	127.0.0.1:6379> set itemscore:2 100
	OK
	127.0.0.1:6379> set itemscore:3 -10
	OK
	
	127.0.0.1:6379> SORT sortbylist
	1) "1"
	2) "2"
	3) "3"
	127.0.0.1:6379> SORT sortbylist desc
	1) "3"
	2) "2"
	3) "1"
	
	127.0.0.1:6379> SORT sortbylist by itemscore:* 
	1) "3"
	2) "1"
	3) "2"
	
	127.0.0.1:6379> SORT sortbylist by itemscore:* desc
	1) "2"
	2) "1"
	3) "3"
	
是不是挺强大的。如果我们排序后并不想打印出参与排序的结果，像同`by`一样通过`*`占位符来打印其它的值，则可以用`get`命令，比如我们对博客发布时间进行排序，但是不想打印博客的ID，只想打印博客的title则可以试一试`get`：

	127.0.0.1:6379> SORT sortbylist by itemscore:* desc
	1) "2"
	2) "1"
	3) "3"
	127.0.0.1:6379> set itemtitle:1 "Hello world"
	OK
	127.0.0.1:6379> set itemtitle:2 "Learn python."
	OK
	127.0.0.1:6379> set itemtitle:3 "Linux shell with python."
	OK
	127.0.0.1:6379> SORT sortbylist by itemscore:* desc get itemtitle:*
	1) "Learn python."
	2) "Hello world"
	3) "Linux shell with python."

是不是也很强大，:-D.我们也可以用多个get哦！如果还想返回原样则用`get #`

	127.0.0.1:6379> SORT sortbylist by itemscore:* desc get itemtitle:* get itemscore:* get #
	1) "Learn python."
	2) "100"
	3) "2"
	4) "Hello world"
	5) "50"
	6) "1"
	7) "Linux shell with python."
	8) "-10"
	9) "3"


哇塞，已经强大的不可理喻了。

如果我们想保存结果则使用`store`,如上

	127.0.0.1:6379> SORT sortbylist by itemscore:* desc get itemtitle:* get itemscore:* get # store result
	(integer) 9
	127.0.0.1:6379> TYPE result
	list
	127.0.0.1:6379> LRANGE result 0 -1
	1) "Learn python."
	2) "100"
	3) "2"
	4) "Hello world"
	5) "50"
	6) "1"
	7) "Linux shell with python."
	8) "-10"
	9) "3"


虽然`sort`排序命令很强大但是最好不要轻易使用它，因为它的时间复杂度为O(n+mlogm),n表示要排序的列表(集合或有序集合)中的元素个数，m表示要返回的元素个数，n较大时则排序性能较低，且redis会在排序前建立一个长度为n的容器来存储待排序的元素，所以在开发过程中要注意：

- 尽可能减少待排序键中元素的数量（n要尽量小）
- 使用limit参数只获取需要的数据(m尽量小)
- 如果排序数量较大，则用store参数将结果缓存起来

## 3.3 消息通知
也就是使用redis做消息队列，现有成熟的基于redis的消息队列。此外可以使用发布/订阅模式来实现.

### 3.3.1 队列
关于队列我们要搞清楚**谁是生产者，谁是消费者**，redis中可以通过`lpush`,`rpop`等命令实现。

**version 1:不断轮询**

	loop
		task = RPOP queue   // queue为队列
		if task
			//如果任务队列有task则执行
			execute(task)
		else
			//如果没有则等待1s以免过于频繁地请求数据
			wait 1 secode

这种轮训的方式不太好的一点就是需要每隔一段时间去询问，有没有一旦有数据就通知消费者呢，redis提供了`BRPOP`(或`BLPOP`)命令

**version 2:BRPOP**

与`rpop`不同的是，`brpop`当列表中没有元素时会一直阻塞直到有新数据加入，如下开启两个redis-cli终端测试：

	127.0.0.1:6379> LPUSH testb 0 1 2 3
	(integer) 4
	127.0.0.1:6379> LRANGE testb 0 -1
	1) "3"
	2) "2"
	3) "1"
	4) "0"
	127.0.0.1:6379> BRPOP testb 0
	1) "testb"
	2) "0"
	127.0.0.1:6379> BRPOP testb 0
	1) "testb"
	2) "1"
	127.0.0.1:6379> BRPOP testb 0
	1) "testb"
	2) "2"
	127.0.0.1:6379> BRPOP testb 0
	1) "testb"
	2) "3"
	127.0.0.1:6379> BRPOP testb 

终端1在testb列表没有数据时立马阻塞，然后在开启一个终端生产输入：

	127.0.0.1:6379> LPUSH testb mytask
	(integer) 1
	127.0.0.1:6379> LRANGE testb 0 -1
	(empty list or set)

生产完数据后发现已经被消费了，至此我们直到终端1的brpop消费了我们的数据

	127.0.0.1:6379> BRPOP testb 0
	1) "testb"
	2) "mytask"
	(16.00s)

那么我们version1的轮训可改成以下：

	loop
		task=brpop queue 0 
		execute(task)

`brpop`两个参数，键和超时时间，如果超时设置为0则默认一直阻塞，其返回值两个，一个是键名，一个是结果。


**redis队列的优先级**

如果有多个queue，则要分优先执行，则可以通过`brpop`or`blpop`实现多个queue，如：

	BRPOP queue_a queue_b queue_c 0

阻塞多个queue,一旦有一个queue有数据则立马执行，如果都没有数据则阻塞，如果有多个数据则执行从左到右顺序第一个key中的数据。如下测试：

	client 1> BRPOP queue_a queue_b queue_c 0
	1) "queue_b"
	2) "taskB"
	(10.2s)

终端1阻塞3个队列，在终端2中生产queue_b的数据：

	client2> lpush queue_b taskB

则终端1会消费queue_b的数据。那么接下来我们生产多个队列数据：

	client 1> BRPOP queue_a queue_b queue_c 0		# 终端1一直阻塞直到有数据
	
	#终端2通过事务插入多条数据
	client 2> multi
	OK
	client 2> lpush queue_a taskA
	QUEUED
	client 2> lpush queue_b taskB
	QUEUED
	client 2> lpush queue_c taskC
	QUEUED
	client 2> exec
	1) (integer) 1
	2) (integer) 1
	3) (integer) 1
	
	#则此时终端1只消费了queue_a的数据
	1) "queue_a"
	2) "taskA"
	(25.22s)
	# 在执行brpop ... 才会消费第二队列

通过这一特点我们可以实现队列的优先级。

## 3.4 发布订阅
发布与订阅（pub/sub）就是发布一个频道(channel),可以订阅(`SUBSCRIBE`)任意多个（正则），订阅者可以收到发布者所发布(`PUBLISH`)的消息，如果不想订阅则退订(`UNSUBSCRIBE`).Pieter Noordhuis 提供了一个使用 EventMachine 和 Redis 编写的[高性能多用户网页聊天软件](https://gist.github.com/348262) ， 这个软件很好地展示了发布与订阅功能的用法。(需要翻墙), nodejs测试可参考之前写的[nodejs redis使用(二).发布与订阅](http://beginman.cn/redis/2015/04/22/nodejs-redis-pub/)

命令则参考：[发布与订阅（pub/sub)](http://redisdoc.com/topic/pubsub.html)

## 3.5 管道(Pipeline)
redis通过TCP与client传输的，client可以通过一个socket连续发起多个请求命令。 每个请求命令发出后client通常会阻塞并等待redis服务端处理，redis服务端处理完后将结果返回给client。

每条命令都在TCP上产生交互往返的时间，如果命令太多则耗时更长，管道则可以将一些命令一并送入执行，相当于批处理工具，管道就是通过减少客户端与Redis的通信次数降低交互往返延时。

不过在编码时请注意，pipeline期间将“独占”链接，此期间将不能进行非“管道”类型的其他操作，直到pipeline关闭；如果你的pipeline的指令集很庞大，为了不干扰链接中的其他操作，你可以为pipeline操作新建Client链接，让pipeline和其他正常操作分离在2个client中。不过pipeline事实上所能容忍的操作个数，和socket-output缓冲区大小/返回结果的数据尺寸都有很大的关系；同时也意味着每个redis-server同时所能支撑的pipeline链接的个数，也是有限的，这将受限于server的物理内存或网络接口的缓冲能力。

比如用python的pyredis库使用管道：

	>>> p = r.pipeline()        --创建一个管道
	>>> p.set('hello','redis')
	>>> p.sadd('faz','baz')
	>>> p.incr('num')
	>>> p.execute()
	[True, 1, 1]
	>>> r.get('hello')
	'redis'

管道的命令可以写在一起：

	>>> p.set('hello','redis').sadd('faz','baz').incr('num').execute()

## 3.6 节省空间
内存很量小且很贵的，下面总结了几个节省内存空间的方法。

- 精简键值和键名，如very.important.person:1001:sex, 可以精简为`vip:1001:sex`
- 内部编码优化，当键中元素变多时则自动将内部编码方式转换为散列表，可以通过`OBJECT ENCODING`查看一个键的内部编码方式。具体细节可参考《redis设计与实现》一书。

# 四 脚本
redis2.6版本提供了脚本功能，允许Lua脚本传到redis中执行，Lua脚本可以调用大部分redis命令。

# 五.管理
管理从持久化，主从复制，安全性，通信协议和管理工具等入手。

## 5.1 持久化
redis重启后数据要以某种形式同步到硬盘中。Redis支持两种方式的持久化，一种`RDB`方式(默认)，一种`AOF`方式。

### RDB方式

RDB是通过快照完成的，在配置文件中如下：

	save 900 1			# 15min内至少有一个键被改动
	save 300 10			# 5分钟内...
	save 60 10000		# 1分钟内...

由两个参数组成，时间和改动的键的个数，当在指定的时间内被改动的键的个数大于指定数值就会进行快照。save可以多个条件以“或”的形式共存，如果要禁用快照则删除save.

redis默认将快照文件存储在当前目录的dump.rdb文件中，其过程就是：

- fork复制当前进程（父进程）的副本（子进程）
- 父进程继续处理client发来的命令，子进程则将内存中的数据写入硬盘中的临时文件
- 当子进程写完后会用该临时文件替换旧的RDB文件

可以通过[配置文件(个人配置详解)](https://github.com/BeginMan/codeStandradStyle/blob/master/redis/redis.conf)中的`rdbcompression yes`压缩rdb文件，压缩可能需要额外的cpu开支,不过这能够有效的减小rdb文件的大小,有利于存储/备份/传输/数据恢复.

我们还可以手动发送

- `save`：由主进程进行快照操作，会阻塞其他请求
- `bgsave`：fork子进程在后台进行快照

**redis启动后会读取redis快照文件，将数据从硬盘载入内存，通过RDB方式实现的持久化，一旦redis异常退出则会丢失最后一次快照以后更改后所有数据**

### AOF方式
默认情况下redis没有开启AOF(append only file)方式的持久化，可以通过`appendonly`参数开启：

	appendonly yes

**开启AOF持久化后每执行一条会更改Redis中数据的命令则redis就将该命令写入硬盘中的AOF文件。保存文件位置同RDB,可以修改`appendfilename`参数设置**

AOF文本是纯文本文件，redis会在一定条件下自动重写AOF文件，如：

	set a 100
	set a 1000
	set a 1
	
如上，会将写命令写入AOF中，无疑前两条是冗余的，最后一条才是最终的，那么redis如何优化呢，在redis配置文件中：

	auto-aof-rewrite-percentage 100
	auto-aof-rewrite-min-size 64mb

	#appendfsync always			#每次写操作就会执行同步	
	appendfsync everysec		#每秒执行一次同步操作（保证数据安全和性能推荐用它）
	#appendfsync no				#不主动执行而是由操作系统（30s）来做。

**redis两种方式都可以，既保证数据安全性又能备份操作，此时redis使用AOF文件来恢复数据，因为AOF不容易丢失数据。**

## 5.2 复制
**持久化保证服务器重启后数据不丢失，复制则为了避免单点故障**。 当一台服务器出现故障后依然可以继续提供服务，这要求一台服务器上的数据更新后，可以自动将更新的数据同步到其他服务器中，redis提供复制(replication)功能可以自动实现同步过程。

同步后数据库分两大类：

- 主数据库(master): 进行读写操作，并将写操作后的数据自动同步到多个从数据库，只能有一个主数据库
- 从数据库(slave)：可以多个，一般只读，并接受主数据库同步过来的数据。

我们应该注意的是：

- Master下的Slave还可以接受同一架构中其它slave的链接与同步请求，实现数据的级联复制，即Master->Slave->Slave模式；
- Master以非阻塞的方式同步数据至slave，这将意味着Master会继续处理一个或多个slave的读写请求；
- 通过配置禁用Master数据持久化机制，将其数据持久化操作交给Slaves完成，避免在Master中要有独立的进程来完成此操作。

如下在同一台主机上测试复制：

Master: 将redis.conf 重命名为Redis-master.conf并编辑：

	daemonize yes  
	port 6379  

复制一份命名Redis-slave.conf并编辑：

	daemonize yes  
	port 6380
	slaveof 192.168.13.274 6379
	masterauth master的redis密码

启动Master、Slave的Redis

	[root@localhost ~]$ /home/db/redis/src/redis-server /etc/redis-master.conf 
	[root@localhost ~]$ /home/db/redis/src/redis-server /etc/redis-slave.conf

	ps -ef | grep redis
	501 24170     1   0 11:09PM ??         0:00.42 ./redis-server *:6379 
	501 24243     1   0 11:19PM ??         0:00.10 ./redis-server *:6380

测试数据同步

Master写数据:

	127.0.0.1:6379> set myname beginman
	OK
	
Slave：

	127.0.0.1:6380> get myname
	"beginman"
	127.0.0.1:6380> set myname bm
	(error) READONLY You can't write against a read only slave.

Slave开启只读模式保证数据只从主服务器写入同步到从服务器,参数slave-read-only控制是否开启只读模式

查看同步状态:

master 执行`info`命令则部分如下：

	# Replication
	role:master
	connected_slaves:1
	slave0:ip=127.0.0.1,port=6380,state=online,offset=360,lag=1
	master_repl_offset:360
	repl_backlog_active:1
	repl_backlog_size:1048576
	repl_backlog_first_byte_offset:2
	repl_backlog_histlen:359

slave执行`info`:

	# Replication
	role:slave
	master_host:127.0.0.1
	master_port:6379
	master_link_status:up
	master_last_io_seconds_ago:4
	master_sync_in_progress:0
	slave_repl_offset:430
	slave_priority:100
	slave_read_only:1
	connected_slaves:0
	master_repl_offset:0
	repl_backlog_active:0
	repl_backlog_size:1048576
	repl_backlog_first_byte_offset:0
	repl_backlog_histlen:0

也可以通过命令行形式设置，如： 

	redis-server slave.conf --port 6380 --slaveof 127.0.0.1 6379

或直接在redis命令中修改如：
	
	redis>SLAVEOF 127.0.0.1 6379

如果该数据已经是其他主数据的从数据库，则`slaveof`命令会停止原来的同步转向新的同步。

**`slaveof no one` 将当前数据库停止接受主数据库的同步，转而成为主数据库，这在运维上很有帮助，如一台主数据的服务器崩溃掉后。**

### redis主从复制原理
![](http://s3.51cto.com/wyfs02/M02/38/6A/wKiom1Ozz5OThc6NAAGUIzDDlQs366.jpg)

图片来源：http://cfwlxf.blog.51cto.com/3966339/1433637

当启动一个Slave进程后，它会向Master发送一个SYNC Command，请求同步连接。无论是第一次连接还是重新连接，Master都会启动一个后台进程，将数据快照保存到数据文件中，同时Master会记录所有修改数据的命令并缓存在数据文件中。后台进程完成缓存操作后，Master就发送数据文件给Slave，Slave端将数据文件保存到硬盘上，然后将其在加载到内存中，接着Master就会所有修改数据的操作，将其发送给Slave端。若Slave出现故障导致宕机，恢复正常后会自动重新连接，Master收到Slave的连接后，将其完整的数据文件发送给Slave，如果Mater同时收到多个Slave发来的同步请求，Master只会在后台启动一个进程保存数据文件，然后将其发送给所有的Slave，确保Slave正常。

由于Redis服务器使用TCP协议通信，可以用`telnet`伪装成一个从数据库来了解同步的具体过程，首先启动主数据库后：

	telnet 127.0.0.1 6379
	Trying 127.0.0.1...
	Connected to localhost.
	Escape character is '^]'.
	AUTH 2015yunlianxiQAZWSX			# 由于设置了密码则发送 AUTH命令输入密码验证
	+OK
	REPLCONF listening-port 6380		# REPLCONF命令说明自己的端口号
	+OK
	SYNC								# 发送SYNC命令开始同步，此时master发送二进制快照文件和缓存命令
	$4384
	REDIS0006?mynambeginman?			# 从数据库会将收到的内容写入硬盘中的临时文件里，当写入完成后从数据库会用该临时文件替换旧的RDB。
	...

	PING								# 发送完之后一直阻塞在PING

此时在master redis终端中写入一条如：set foo bar,则telnet终端里面就会同步，如下：

	set
	$3
	foo
	$3
	bar
	*1
	$4
	PING

我们可以在slave端也可进行复制，形成一个图结构：

![](http://beginman.qiniudn.com/redis_replication.png)

### 读写分离
**通过复制可以实现读写分离以提高服务器的负载能力，让Master负责处理写请求，Slave负责处理读请求；通过扩展Slave处理更多的并发请求，减轻Master端的负载，如下图：**

![](http://images.cnitblog.com/blog/28306/201212/19155946-11750d0080914f2680f70c213b9333d2.jpg)

图片来源：http://www.cnblogs.com/Mainz/archive/2012/12/19/2825039.html

**为了提高性能，可以复制多个slave并设置持久化，禁用master的持久化（因为减少master额外的开销），当slave崩溃后，重启后master会自动将数据同步过去，所以无需担心数据丢失；当master崩溃后，则在slave使用`slaveof no one`命令将slave提升为master继续服务，并在原来的master恢复启动后使用`slaveof`命令再将其设为新的master对应的slave.即可将数据同步过来。**

## 5.3 安全性
原则：

- 运行在可信环境下，生产环境下坚决不对外开放
- 设置密码，越复杂越好，因为在redis性能极高，且在输错密码后redis并不会主动延时，对外开放的环境下，攻击者可用穷举法破解密码（1s内可尝试十几万次)
- 对危险命令重命名，如`flushdb`,`flushall`在配置文件中重命名为复杂的名字，只有自己知道哦。如：`rename-command FULSHALL fuckyou2015hahahhqazwsx123321poi`, 或者禁用命令，如：`rename-command flushdb ""`重命名为空字符串即可。

## 5.4 管理工具
### 耗时命令日志(slow log)
配置文件默认：

	slowlog-log-slower-than 10000	#(微妙，这里转换为1秒)
	slowlog-max-len 128				#(日志条数，超过128则overwrite)

日志文件存储在内存中，通过`slowlog get`查看：

	127.0.0.1:6379> SLOWLOG get
	1) 1) (integer) 0
	2) (integer) 1447121333
	3) (integer) 16557
	4) 1) "SYNC"

介绍了几个监控工具如：`montitor`命令，`redis-faina.py`工具，phpRedisAdmin工具和Rdbtools工具。

Over~


