---
layout: post
title: "学习网络编程的十个步骤浅析"
description: ""
category: "unp"
tags: [Unix网络编程]
---

偶然在网上看到这篇[学习网络编程的十个步骤](http://www.cppblog.com/waterinfire/archive/2007/05/11/23904.html), 觉得说的确实很有道理，总结如下：

1. 用python互动，提高兴趣和理解力(因为python socket编程几乎与Unix接口一致，且用python能很快的开发一个小程序)
2. 掌握网络编程中会用到的几个基本概念和内涵，比如IP地址，port号，socket等(也就是说掌握一些网络基础知识，TCP/IP基础， 如这篇文章[TCP IP基础知识的复习](http://www.cnblogs.com/rollenholt/archive/2012/04/25/2469592.html))
3. 记住和消化网络编程C/S模型，把server和client端编程的常用模式理解和消化
4. 花几天时间学习socket api集，api集可以分为下面几大类：
	- 创建   socket bind listen accept
	- 收发   read/recv/recvfrom  write/send/sendto   
	- 关闭   close shutdown
	- 参数   getsockopt/setsockopt
	- 地址   gethostbyaddr getaddrbyhost,...
5. 结合python互动平台，实践socket api的用法(可参考：《Python网络编程基础》和《python网络编程攻略》)
6. 学习socket server端编程实现简单规约比如echo，time等，然后通过cmd中的telnet来测试。(最好用C和python各自实现简单的echo,time等服务器客户端)
7. 学习I/O模型，比如阻塞、非阻塞和反应式（select,poll,WaitForMultipleObject)等
8. 学习Richard Stevens的《Unix网络编程》，深入学习其中的api原理以及服务端设计原理，并通过代码编写。
9. 下载高性能网络编程框架twisted(这里我推荐学习tornado和nodejs，twisted毕竟太臃肿了)
10. 学习设计模式、操作系统知识比如线程、进程、同步等。

推荐书籍有：

《Unix网络编程套接字联网API》，《Python网络编程基础》，《python网络编程攻略》，《Linux C一站式编程》，《深入浅出nodejs》

下面我来说说我的网络编程之旅吧。

阶段1： 理解tornado异步框架受阻，决定学习网络编程，深入理解I/O模型

阶段2： 花半个月时间学完[《嗨翻C语言》](https://github.com/BeginMan/BookNotes/tree/master/C), 这是学习Unix网络编程的基础，便是学好C

阶段3： 理解C指针和内存管理上有问题，学习[《深入理解C指针》](https://book.douban.com/subject/25827246/),为了更好的深入C，买了C进阶三杰[《C和指针》](book.douban.com/subject/3012360/)，[《C专家编程》](http://book.douban.com/subject/2377310/), [《C陷阱与缺陷》](http://book.douban.com/subject/2778632/)

阶段4：正在看[《UNIX网络编程：套接字联网API》](https://github.com/BeginMan/BookNotes/tree/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition), 届时互动[《python网络编程攻略》](https://github.com/BeginMan/BookNotes/tree/master/Python/pnp)和[《Python标准库》](http://book.douban.com/subject/10773324/)进行理解和实战

阶段5：尚未进行（深入tornado源码，搞懂tornado异步框架； 学习gevent; 继续我的nodejs）


**所以我在2015年的主要目标就是学习Unix网络编程，[计划在这里](http://beginman.cn/pages.html)**

推荐:

[陈硕:谈一谈网络编程学习经验](http://www.cppblog.com/Solstice/archive/2011/06/06/148129.aspx)

[陈皓:如何学好C语言](http://coolshell.cn/articles/4102.html)

[Linux Socket编程（不限Linux）](http://www.cnblogs.com/skynet/archive/2010/12/12/1903949.html)
