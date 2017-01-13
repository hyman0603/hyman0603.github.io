---
layout: post
title: "Linux 服务器内存使用情况统计"
description: "Linux 服务器内存使用情况统计"
category: "ops"
tags: [ops]
---

查看linux服务器内存使用情况:`free -m` ,`m`是M个字节的意思

	$ free -m
						total       used       free     shared    buffers     cached
	Mem:				7869		7697		171          0        386       5503
	-/+ buffers/cache:				1808       6060
	Swap:				0          0          0

第一行：

- total:	内存总数
- used:		已经使用的内存数
- free:		空闲的内存数
- shared:	多个进程共享的内存总额
- Buffers/cached:磁盘缓存的大小。

第二行：

`/`为了简化参数的显示。

- `- buffers/cache`: (已用)的内存数，即 used-buffers-cached, 如上：1808=7697-386-5503
- `+ buffers/cache`: (可用)的内存数，即 free+buffers+cached, 如上：6060=171+386+5503

第一行的输出时从操作系统（OS）来看的。也就是说，从OS的角度来看，计算机上一共有:

- 7869 物理内存(total)
- 在这些物理内存中有7697(used)被使用了,注意并不是真正意义上的被霸占了，看到这么高的数据不要害怕(囧)；
- 还用171（free是可用的,即完全空闲；

buffer是用于存放要输出到disk（块设备）的数据的，而cache是存放从disk上读出的数据。这二者是为了提高IO性能的，并由OS管理。

第二行是从一个应用程序的角度看系统内存的使用情况：

-buffers/cache，表示一个应用程序认为系统被用掉多少内存

+buffers/cache，表示一个应用程序认为系统还有多少内存；

因为被系统cache和buffer占用的内存可以被快速回收，所以这两者通常会很大

如图阿里云监控出服务器内存占用率23.18%(第二台)，我这边测试的是：1808/7869=23%

![](http://beginman.qiniudn.com/aliyun_console_memory.png)

回头整理下Linux监控工具vmstat。今天是双十一晚会，还是放松下心情shopping.

参考：

[Linux上的free命令详解](http://www.cnblogs.com/coldplayerest/archive/2010/02/20/1669949.html)

《构建高可用的Linux服务器》



