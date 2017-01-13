---
layout: post
title: "redis大量TIME_WAIT分析"
description: "redis close time_wait"
category: "redis"
tags: [redis]
---
`quit`关闭，如果是连接池则就不需要了
redis-server 会关闭空闲超时的连接，在`redis.conf`中可以设置超时时间如：
	
	#Close the connection after a client is idle for N secondes(0 to disable)
	timeout 300

默认是300s超时，也就是说300s内如果client没有发送任何指令则server关闭它，如果设置为0则表示永不关闭，关于[**redis配置文件详解我已经放在github上了**](https://github.com/BeginMan/codeStandradStyle/blob/master/redis/redis.conf)。

redis基于TCP/IP，这就让我们不得不注意频发的交互问题.

接下来从一个python操作redis的简单例子入手：

	import time
	import os
	import redis
	print redis.__file__            # redis库文件目录，/Library/Python/2.7/site-packages/redis/__init__.pyc

	# connect
	r = redis.Redis(host='192.168.0.120', password='2015yunlianxiQAZWSX')       # 在这个阶段并没有开始TCP连接，TCP连接是发生在交互的过程，如下
	# 第一个命令交互，此时才开始发生TCP连接
	info = r.info()     # The method info() can print all message about redis and server.
	# for key in info:
	#     print "%s:%s" % (key, info[key])vv
	# size of database
	# print "dbsize:%s" % r.dbsize()

	# ping
	os.system("netstat -ant|grep 6379")
	time.sleep(3)
	print "ping:%s" % r.ping()

	del r
	os.system("netstat -ant|grep 6379")

实验环境及工具：

本机测试：Mac OS X, python2.7

服务器端：Centos 6.5, redis 3.0.3, tcpdump

首先在服务器端用`tcpdump`监控TCP变化，这是只监控SYN和FIN过程，也就是握手和挥手过程。

	tcpdump -i eth1 "tcp[tcpflags] & (tcp-syn|tcp-fin)!=0" -nn

当运行程序后，监控变化如下：

![](http://beginman.qiniudn.com/tcpdump_for_redis_test.png)

![](http://beginman.qiniudn.com/netstat_for_redis_test.png)

![](http://beginman.qiniudn.com/python_test_for_redis.png)

可以总结的是：

1. `redis.Redis()`是一个向后兼容的类，实例化后并没有直接去TCP连接，你可以测试如输错密码或主机等，运行后并没有连接提示，TCP连接发生在命令交互阶段，如上程序所示。
2. 当我们手动关闭连接`del r`（这里直接删除该实例），则TCP挥手。如果没有手动删除则根据你服务器端redis的配置，如`timeout`等，这里由内核控制断开。

当然我们的程序肯定不是只运行一次的，往往是配合webserver，如下配合tornado测试

	import redis
	import tornado.ioloop
	import tornado.web

	r = redis.Redis(host='192.168.0.120', password='2015yunlianxiQAZWSX')       # 在这个阶段并没有开始TCP连接，TCP连接是发生在交互的过程，如下

	class MainHandler(tornado.web.RequestHandler):
		def get(self, *args, **kwargs):
			self.write(r.info())


	application = tornado.web.Application([
		(r'/', MainHandler),
	])

	if __name__ == '__main__':
		application.listen(8000)
		tornado.ioloop.IOLoop.current().start()

运行服务并打开url连接然后在中断它，在服务端发生如下：

![](http://beginman.qiniudn.com/tornado_redis_tcp_test.png)

连接成功是`ESTABLISTEND`,中断客户端程序后则进入`TIME_WAIT`,关于TIME_WAIT可参考[我在unp学习过程中的总结](https://github.com/BeginMan/BookNotes/blob/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition/top2.md#26-time_wait状态)


