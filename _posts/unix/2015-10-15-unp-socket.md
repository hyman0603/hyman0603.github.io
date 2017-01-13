---
layout: post
title: "Unix网络编程之理解Socket与字节序"
description: "Unix socket"
category: "unp"
tags: [Unix网络编程]
---

在学习[《UNIX网络编程 卷1：套接字联网API（第3版）》](https://github.com/BeginMan/BookNotes/tree/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition)的时候，对一些概念了解甚少，导致学习的进度比较缓慢。[第三章：套接字编程](https://github.com/BeginMan/BookNotes/blob/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition/top3.md) 是块很重要又晦涩难懂的知识。再看原著的同时又开了下这篇文章:[UNIX网络编程——socket概述和字节序、地址转换函数](http://blog.csdn.net/ctthuangcheng/article/details/9407837)觉得明朗了很多。如下重点概况包括：

1. 理解socket
2. 不同协议的地址结构的处理
3. 字节序

## 一.Socket概述

- **socket可以看成是用户进程与内核网络协议栈的编程接口。**
- socket不仅可以用于本机的进程间通信，还可以用于网络上不同主机的进程间通信。
![](http://img.blog.csdn.net/20130603130100109)
- socket API是一层抽象的网络编程接口，适用于各种底层网络协议，如IPv4、IPv6，以及以后要讲的UNIX Domain Socket。然而，各种网络协议的地址格式并不相同，如下图所示：
![](http://img.blog.csdn.net/20130722133529984?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY3R0aHVuYWdjaG5lZw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

IPv6地址用`sockaddr_in6`结构体表示，包括16位端口号、128位IP地址和一些控制字段。UNIX Domain Socket的地址格式定义在`sys/un.h`中，用sockaddr_un结构体表示。

**各种socket地址结构体的开头都是相同的**，前16位表示整个结构体的长度（并不是所有UNIX的实现都有长度字段，如Linux就没有），后16位表示地址类型。IPv4、IPv6和UNIX Domain, Socket的地址类型分别定义为常数`AF_INET`、`AF_INET6`、`AF_UNIX`。

这样，只要取得某种sockaddr结构体的首地址，不需要知道具体是哪种类型的sockaddr结构体，就可以根据地址类型字段确定结构体中的内容。因此，**socket API可以接受各种类型的sockaddr结构体指针做参数**，例如`bind`、`accept`、`connect`等函数，这些函数的参数应该设计成`void *`类型以便接受各种类型的指针，但是sock API的实现早于ANSI C标准化，那时还没有`void *`类型，因此这些函数的参数都用`struct sockaddr *`类型表示，即**通用地址结构**，如下所示：

	struct sockaddr {  
	        uint8_t      sa_len;  
	        sa_family_t  sin_family;  
	        char         sa_data[14];  
	};   

- `sin_family`：指定该地址家族
- `sa_data`：由sin_family决定它的形式。

**在传递参数之前要强制类型转换一下**，例如：

	struct sockaddr_in servaddr;
	/* initialize servaddr */
	bind(listen_fd, (struct sockaddr *)&servaddr, sizeof(servaddr));

## 二. 字节序
字节序是指多字节数据在计算机内存中存储或者网络传输时各字节的存储顺序。

![](https://raw.githubusercontent.com/BeginMan/BookNotes/master/Unix/media/bitsort.png)

## 2.1 常见字节序：

- 大端字节序（Big Endian)
	- 最高有效位（MSB：Most Significant Bit）存储于最低内存地址处；
	- 最低有效位（LSB：Lowest Significant Bit）存储于最高内存地址处。
- 小端字节序（Little Endian）
	- 最高有效位（MSB：Most Significant Bit）存储于最高内存地址处；
	- 最低有效位（LSB：Lowest Significant Bit）存储于最低内存地址处。

**快速记忆： 小端低低， 大端高高**

比如整形十进制数字：305419896 ，转化为十六进制表示 : 0x12345678 。其中按着十六进制的话，每两位占8个字节。如图

![](http://www.bysocket.com/wp-content/uploads/2015/10/iostream_thumb1.png)

## 2.2 为什么有大小端模式之分呢

在计算机系统中，我们是**以字节为单位，每个地址单元都对应着一个字节，一个字节为8bit**。但是在C语言中除了8bit的`char`之外，还有16bit的`short`型，32bit的`long`型（要看具体的编译器）。另外，对于位数大于8位的处理器，例如16位或者32位的处理器，由于寄存器宽度大于一个字节，那么必然存在着一个如果将多个字节安排的问题。因此就导致了大端存储模式和小端存储模式。

在《Linux高性能服务器编程》中这里理解更好些：

>现代PC大多采用小端字节序，因此小端字节序又称为主机字节序。

>当格式化的数据（比如32 bit整型数和16 bit短整型数）在两台使用不同字节序的主机之间直接传递时，接收端必然错误地解释之。解决问题的方法是：发送端总是把要发送的数据转化成大端字节序数据后再发送，而接收端知道对方传送过来的数据总是采用大端字节序，所以接收端可以根据自身采用的字节序决定是否对接收到的数据进行转换（小端机转换，大端机不转换）。因此大端字节序也称为网络字节序，它给所有接收数据的主机提供了一个正确解释收到的格式化数据的保证。

知道为什么有模式的存在，下面需要了解应用场景：

1、不同端模式的处理器进行数据传递时必须要考虑端模式的不同

2、在网络上传输数据时，由于数据传输的两端对应不同的硬件平台，采用的存储字节顺序可能不一致。所以在TCP/IP协议规定了在网络上必须采用**网络字节顺序，也就是大端模式,对于char型数据只占一个字节，无所谓大端和小端。而对于非char类型数据，必须在数据发送到网络上之前将其转换成大端模式。接收网络数据时按符合接受主机的环境接收。**

## 2.3 主机字节序与网络字节序

### 2.1.3 主机字节序
不同的主机有不同的字节序，如x86为小端字节序，Motorola 6800为大端字节序，ARM字节序是可配置的。**现代PC大多采用小端字节序，因此小端字节序又称为主机字节序。**

### 2.1.4 网络字节序
网络字节顺序是TCP/IP中规定好的一种数据表示格式，它与具体的CPU类型、操作系统等无关，从而可以保证数据在不同主机之间传输时能够被正确解释。**网络字节顺序采用big endian排序方式**。

为使网络程序具有可移植性，使同样的C代码在大端和小端计算机上编译后都能正常运行，可以调用以下库函数做网络字节序和主机字节序的转换。

	#include <arpa/inet.h>  
	uint32_t htonl(uint32_t hostlong);  
	uint16_t htons(uint16_t hostshort);  
	uint32_t ntohl(uint32_t netlong);  
	uint16_t ntohs(uint16_t netshort);

这些函数名很好记:

- h表示host
- n表示network
- l表示32位长整数
- s表示16位短整数。

例如`htonl`表示将32位的长整数从主机字节序转换为网络字节序，例如将IP地址转换后准备发送。如果主机是小端字节序，这些函数将参数做相应的大小端转换然后返回，如果主机是大端字节序，这些函数不做转换，将参数原封不动地返回。

原著中检查主机的大端小端程序如下：

	#include "unp.h"

	int main(int argc, char **argv)
	{
		union {
			short		s;
			char		c[sizeof(short)];
		} un;

		un.s = 0x0102;    //短整数变量中存放2个字节的值0x0102
		printf("%s: ", CPU_VENDOR_OS);  //标识CPU类型，厂家和操作系统版本，如:i386-apple-darwin14.5.0
		if(sizeof(short) == 2) {
			//查看它的两个连续字节c[0],c[1]来确定字节序
			if (un.c[0] == 1 && un.c[1] == 2)
				printf("big-endian\n");
			else if (un.c[0] == 2 && un.c[1] == 1)
				printf("litter-endian\n");
			else
				printf("unknown\n");
		} else
			printf("sizeof(short) = %lu\n", sizeof(short));
		exit(0);
	}

在我Mac OS X中输出的是小端.

还有一个更加简明的方式，如下：

	#include <stdio.h>
	#include <arpa/inet.h>

	int main(void)
	{
		unsigned int x = 0x12345678;
		unsigned char *p = (unsigned char *) &x;
		printf("%x,%x,%x,%x\n", p[0], p[1], p[2], p[3]);

		unsigned int y = htonl(x);
		p = (unsigned char *)&y;
		printf("%x,%x,%x,%x\n", p[0], p[1], p[2], p[3]);
		return 0;
	}

输出：

	78 56 34 12  
	12 34 56 78

**即本主机是小端字节序，而经过`htonl`转换后为网络字节序，即大端。**

# 参考资料

- [深入浅出： 大小端模式](http://blog.csdn.net/jeffli1993/article/details/49130947)
- [UNIX网络编程——socket概述和字节序、地址转换函数](http://blog.csdn.net/ctthuangcheng/article/details/9407837)
- [《UNIX网络编程 卷1：套接字联网API（第3版）》](https://github.com/BeginMan/BookNotes/tree/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition)]
- 《高性能的Linux服务器编程》

# 修订历史

- 2015/10/15: 初稿
- 2016/03/02：《高性能的Linux服务器编程》字节序



