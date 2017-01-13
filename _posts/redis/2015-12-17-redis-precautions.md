---
layout: post
title: "Redis使用过程中注意事项"
description: "Redis使用过程中注意事项"
category: "redis"
tags: [redis]
---

redis应该保证内存够用，最好部署在独立的服务器，如数据库服务器中，加大内存，保持环境纯净，避免应用程序进程对redis进程的影响，如应用程序进程跑满CPU则redis进程可能就无法启动，或则redis进程在恢复数据`fork`子进程时候因内存不足而导致数据恢复失败等潜在因素。

## redis基础过滤
redis正确的stop方式：

	redis-cli shutdown save

参考我之前写的[《redis入门指南》读书笔记](http://beginman.cn/redis/2015/11/06/redis-books/), **在做什么事之前一定要备份好，想好了再处理.**

## 关于 Hash

![](http://www.infoq.com/resource/articles/tq-redis-memory-usage-optimization-storage/zh/resources/image4.jpg)

>Key仍然是用户ID, value是一个Map，这个Map的key是成员的属性名，value是属性值，这样对数据的修改和存取都可以直接通过其内部Map的Key(Redis里称内部Map的key为field), 也就是通过 key(用户ID) + field(属性标签) 就可以操作对应属性数据了，既不需要重复存储数据，也不会带来序列化和并发修改控制的问题。很好的解决了问题。

>**这里同时需要注意，Redis提供了接口(`hgetall`)可以直接取到全部的属性数据,但是如果内部Map的成员很多，那么涉及到遍历整个内部Map的操作，由于Redis单线程模型的缘故，这个遍历操作可能会比较耗时，而另其它客户端的请求完全不响应，这点需要格外注意。**

## 常用内存优化

- 不要开启Redis的VM选项，即虚拟内存功能，将redis.conf文件中`vm-enabled`为 no。
- 设置redis.conf中的`maxmemory`选项，该选项是告诉Redis当使用了多少物理内存后就开始拒绝后续的写入请求，该参数能很好的保护好你的Redis不会因为使用了过多的物理内存而导致swap,最终严重影响性能甚至崩溃。
- 为不同数据类型分别提供了一组参数来控制内存使用, 见redis.conf中[`ADVANCED CONFIG`](https://github.com/BeginMan/codeStandradStyle/blob/master/redis/redis.conf#L844)一栏
- 当业务场景不需要数据持久化时，关闭所有的持久化方式可以获得最佳的性能以及最大的内存使用量.
- 不要让你的Redis所在机器物理内存使用超过实际内存总量的3/5。

参考：

- [Redis内存使用优化与存储](http://www.infoq.com/cn/articles/tq-redis-memory-usage-optimization-storage)
