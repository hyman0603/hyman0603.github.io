---
layout: post
title: "Unix网络编程Socket基础APi总结"
description: "Unix网络编程Socket基础APi总结"
category: "UNP"
tags: [Unix网络编程, unp,socket]
---

>环境提示：本文总结是基于IPv4, TCP socket

总结导航：

- 理解socket
- 字节序
- socket地址概述
- socket地址的创建(IP地址，port端口号的处理函数)
- Socket创建TCP协议通讯流程图
	- 服务端流程
		- 创建socket, socket()
		- 绑定socket和端口号，bind()
		- 监听socket, listen()
		- 接收来自客户端的请求,accept()
		- 从socket读取字符，recv()
		- 关闭socket, close()
	- 客户端流程
		- 创建socket
		- 连接, connect
		- 发送，send()
		- 关闭，close()
- 一个完整的回显服务器实例
- Python基础Socket总结


# 一.理解socket
**从协议的角度上**:

socket是在传输层和应用层之间，是一个桥梁。为什么说是一座桥梁呢？因为数据链路层、网络层、传输层协议是在内核中实现的。因此操作系统需要实现一组系统调用，使得应用程序能够访问这些协议提供的服务，那么**socket系统调用的API就是用户空间和内核空间的媒介**。

比如我在[《Linux高性能服务器编程》协议部分的总结](https://github.com/BeginMan/BookNotes/blob/master/High-performance-Linux-server-programming/top1-tcp-ip-detail.md)关于TCP报文封装过程图

![](https://github.com/BeginMan/BookNotes/raw/master/High-performance-Linux-server-programming/media/tcp-fz.png)

**从通讯角度:**

**socket可以看成是用户进程与内核网络协议栈的编程接口。**, 在[Linux Socket编程（不限Linux）](http://www.cnblogs.com/skynet/archive/2010/12/12/1903949.html)文中作者讲本地进程间和网络进程间通信时，让人受益匪浅：

> **本地的进程间通信（IPC）**有很多种方式，但可以总结为下面4类：

- 消息传递（管道、FIFO、消息队列）
- 同步（互斥量、条件变量、读写锁、文件和写记录锁、信号量）
- 共享内存（匿名的和具名的）
- 远程过程调用（Solaris门和Sun RPC）

那么**网络中进程之间如何通信？**


>首要解决的问题是**如何唯一标识一个进程**，否则通信无从谈起！在本地可以通过进程PID来唯一标识一个进程，但是在网络中这是行不通的。其实TCP/IP协议族已经帮我们解决了这个问题，网络层的“ip地址”可以唯一标识网络中的主机，而传输层的“协议+端口”可以唯一标识主机中的应用程序（进程）。这样利用三元组（ip地址，协议，端口）就可以标识网络的进程了，网络中的进程通信就可以利用这个标志与其它进程进行交互。

>使用TCP/IP协议的应用程序通常采用应用编程接口：UNIX  BSD的套接字（socket）来实现网络进程之间的通信。就目前而言，几乎所有的应用程序都是采用socket，而现在又是网络时代，网络中进程通信是无处不在，这就是我为什么说“一切皆socket”。

![](http://images.cnitblog.com/blog/349217/201312/05225723-2ffa89aad91f46099afa530ef8660b20.jpg)

![](http://img.blog.csdn.net/20130603130100109)

# 二.字节序
我这篇博客[Unix网络编程之字节序](http://beginman.cn/unp/2015/10/15/unp-socket/)总结的已经很明了了。重点是记住**网络字节顺序是TCP/IP中规定好的一种数据表示格式，网络字节顺序采用big endian排序方式。**下面是字节序处理函数，要巧记哦：
	
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

例如`htonl`表示将32位的长整数从主机字节序转换为网络字节序。

# 三. socket地址API
地址包含什么呢？IP,port，协议等信息。socket地址结构有很多，常用的就是：

- 通用socket地址， sockaddr结构体(**之根本**)
- 新socket地址，sockaddr_storage地址结构体(**更大**)
- 专用socket地址(**更细**)
	- IPv4, sockaddr_in结构体
	- IPv6, sockaddr_in6结构体
	- UDP, sockaddr_un结构体

## 3.1 概念
网络中以主机 IP 、端口以及使用的协议表明一个网络应用。 UNIX Socket 将它们组成一个结构，统称为 SOCKET 地址结构。

## 3.2 通用socket地址

sockaddr结构体如下：
	
	#include <bits/socket.h>
	struct sockaddr{
	     sa_family_t sa_family;      		//地址族类型(sa_family_t)的变量
	     char sa_data[14];             	//存放socket地址值
	}
	
搞清楚地址族类型与协议族类型

![](http://img.blog.csdn.net/20140220095948562?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenM2MzQxMzQ1Nzg=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

**通用socket地址的缺陷是：不同的协议族的地址值不同，14字节的sa_data无法容纳更多协议族地址值。**

![](http://img.blog.csdn.net/20130722133529984?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY3R0aHVuYWdjaG5lZw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

所以Linux打造了新的socket地址， **sockaddr_storage**

## 3.3 新socket地址，sockaddr_storage地址结构体

	#include <bits/socket.h>
	struct sockaddr_storage{
	     sa_family_t sa_family;      		//地址族类型(sa_family_t)的变量
	     unsigned long int __ss_align;   //内存对齐。
	     char __ss_padding[128-sizeof(__ss_align)];
	}
	
与上面的区别：

- 能提供严格的结构对齐;
- 提供更大的内存空间

## 3.4 专用socket地址

根据不同的协议指定相关socket地址。这里列出常用的IPv4和IPv6的专用socket地址。

IPv4 `sockaddr_in`

	#inlcude<sys/un.h>
	struct sockaddr_in {
	     sa_family_t sa_family ;//地址族类型(sa_family_t)的变量,AF_INET;
	     u_int16_t sin_port;       //端口号，要用网络字节序表示
	     struct in_addr sin_add; //IPv4地址结构体
	}
	
	struct in_addr{
	     u_int32_t s_addr;          //IPv4地址，要用网络字节序表示
	}

IPv6专用socket地址,`sockaddr_in6 `

	#inlcude<sys/un.h>
	struct sockaddr_in6
	{
	    sa_family_t sin6_family;                /* 地址族：AF_INET6*/
	    u_int16_t sin_port;                        /* 端口号，要用网络字节序表示 */
	    u_int32_t sin6_flowinfo;                /* 流信息，应设置为0  */
	    struct int6_addr sin6_addr;           /* IPv6地址结构体 */
	    u_int32_t sin6_scope_id;               / * scope Id.，尚处于试验阶段  */
	};
	struct in_addr
	{
	    unsigned char sa_addr[16];     /* IPv6地址，要用网络字节序表示  */
	};

虽然Linux给我们提供了专用的socket地址，但是，在实际使用时，都要(包括sockaddr_storage)强制转换为通用socket地址类型（sockaddr）因为所有socket编程接口使用的地址参数的类型都是sockaddr。

总结：

- 通用socket地址，`sockaddr`为基础
- 其余的socket地址都是以`sockaddr_`开头
- 其余的socket都要强制转换为通用socket地址类型（sockaddr）

# 四.socket地址的创建

## 4.1 基于IPv4的socket地址结构创建
现如今用的最多的就是创建IPv4地址结构，如下：
	
	/*创建IPv4 socket地址结构*/
	struct sockaddr_in address;
	
	/*在使用之前把地址变量初始化为全 0*/
	bzero( &address, sizeof( address ) );
	
	/*设置地址族 AF_INET*/
	address.sin_family = AF_INET;
	
	/*设置ip地址，经过inet_pton函数转换为网络字节序并存储在sin_addr内存中*/
	inet_pton( AF_INET, ip, &address.sin_addr );
	
	/*设置port端口，经过htons函数转换为网络字节序*/
	address.sin_port = htons( port );

这样一个完整的IPv4 socket地址就创建好了，如果接受来自任何地址的连接则可设置ip为`INADDR_ANY`变量，且推荐使用`memset`来初始化socket地址结构体。如下：

	struct sockaddr_in serv_addr;
	memset(&serv_addr, 0, sizeof(serv_addr));
	
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	serv_addr.sin_port = htons(port);
	
前面说了字节序的问题，对于ip和端口都要转换为网络字节序。对于端口的处理，很简单通过`htons`就可以处理，重点在**IP地址转换函数**

## 4.2 IPv4地址转换函数
点分十进制(十六进制)字符串 `<-->` 网络字节序整数(二进制数) 

使用的函数存在于`arpa/inet.h`头文件中，我们在[Open Group arpt/inet.h](http://pubs.opengroup.org/onlinepubs/009696899/basedefs/arpa/inet.h.html)可查看详情。

	#include <arpa/inet.h>
	
	in_addr_t    inet_addr(const char *);   /*IPv4 str -->网络序*/
	
	char        *inet_ntoa(struct in_addr); /*网络序-->IPv4 str指针*/
	
	int         inet_aton(const char* cp, struct in_addr* inp); /*IPv4 str-->网络序*/
	

如下解释：

- `inet_addr `: IPv4 Str转为网络序,当IP地址转换错误时返回INADDR_NONE（-1）
- `inet_ntoa `: 网络序转换为IP地址字符串,注意inet_ntoa()返回的字符串存放在套接字接口实现所分配的内存中，应用程序不应该假设内存是如何分配的，因此它不是一个线程安全的函数(不可重入)。返回值：无错误发生返回一个字符串指针，否则返回NULL指针。
- `inet_aton`: 与`inet_addr `一样，将IPv4 Str转为网络序。但是将转换结果存储于参数inp指向的地址结构中，成功返回1，否则为0

## 4.3 适用于IPv4地址和IPv6地址转换函数

这个比较常用的，`inet_ntop`和`inet_pton `：

	
	#include<arpa/inet.h>
	
	int inet_pton(int af, const char *src, void *dst);
	
	const char* inet_ntop(int af, const void *src, char *dst, socklen_t cnt); 


如下解释：

- `inet_pton`: IP str 转为网络序，并把转换结果存储于dst指向的内存中。其中，af参数指定地址族，可以是AF_INET或者AF_INET6。inet_pton成功时返回1，失败则返回0并设置errno
- `inet_ntop`: 进行相反的转换，前三个参数的含义与inet_pton的参数相同，最后一个参数cnt指定目标存储单元的大小，成功时返回目标存储单元的地址，失败则返回NULL并设置errno。

# 五.Socket创建TCP协议通讯流程
从客户端，服务端角度出发，依照如下流程图：

![](http://images.cnitblog.com/blog/349217/201312/05232335-fb19fc7527e944d4845ef40831da4ec2.png)

这些socket函数都在`sys/socket.h`头部里

## 5.1 创建socket
socket也是文件，创建socket则像普通文件的打开操作返回一个文件描述字一样，而`socket()`用于创建一个socket描述符唯一标识一个socket。

	int socket(int domain, int type, int protocol);

参数分析：

- domain：即协议域（或叫协议族）,如AF_INET、AF_INET6
- type：指定socket类型, 如SOCK_STREAM(TCP), SOCK_DGRAM(UDP)
- protocol：就是指定协议，应该设为0表示默认协议

socket系统调用成功时返回一个socket文件描述符，失败则返回-1并设置errno。

>当我们调用socket创建一个socket时，返回的socket描述字它存在于协议族（address family，AF_XXX）空间中，但没有一个具体的地址。如果想要给它赋值一个地址，就必须调用bind()函数，否则就当调用connect()、listen()时系统会自动随机分配一个端口。

这就是下面说的命名socket

## 5.2 bind 命名socket

Need know:

- 将一个socket与socket地址绑定称为**给socket命名**
- 服务端需要命名socket
- 客户端则通常不需要命名socket，而是采用匿名方式，即使用操作系统自动分配的socket地址
- 命名socket的系统调用是`bind`函数

如下`bind()`函数：


	int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

函数的三个参数分别为：

- sockfd：即socket描述字，它是通过`socket()`函数创建了，唯一标识一个socket。`bind()`函数就是将给这个描述字绑定一个名字。
- addr：一个`const struct sockaddr *`指针，指向要绑定给sockfd的协议地址。
- addrlen：对应的是地址的长度

bind成功时返回0，失败则返回-1并设置errno。

**注意：**

>通常服务器在启动的时候都会绑定一个众所周知的地址（如ip地址+端口号），用于提供服务，客户就可以通过它来接连服务器；而客户端就不用指定，有系统自动分配一个端口号和自身的ip地址组合。这就是为什么通常服务器端在listen之前会调用`bind()`，而客户端就不会调用，而是在`connect()`时由系统随机生成一个。


## 5.3 listen监听socket, connect连接socket

CS流程：

- 服务器，在调用`socket()`、`bind()`之后就会调用`listen()`来监听这个socket
- 客户端这时调用`connect()`发出连接请求，服务器端就会接收到这个请求。

对于服务器, socket被命名之后，还不能马上接受客户连接，我们需要使用如下系统调用来创建一个监听队列以存放待处理的客户连接。

	int listen(int sockfd, int backlog);

listen函数将socket变为被动类型的，等待客户的连接请求。listen成功时返回0，失败则返回-1并设置errno。

对于客户端，

	int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

要注意：

- 第一个参数即为客户端的socket描述字
- 第二参数为服务器的socket地址
- 第三个参数为socket地址的长度

connect成功时返回0。一旦成功建立连接，sockfd就唯一地标识了这个连接，客户端就可以通过读写sockfd来与服务器通信。connect失败则返回-1并设置errno。

## 5.4 accept接收请求

CS流程：

- TCP服务器端依次调用`socket()`、`bind()`、`listen()`之后，就会监听指定的socket地址
- TCP客户端依次调用`socket()`、`connect()`之后就向TCP服务器发送了一个连接请求。
- TCP服务器监听到这个请求之后，就会调用`accept()`函数来接收这个请求
- 完整的连接就建立好了。之后就可以开始网络I/O操作了，即类同于普通文件的读写I/O操作。

如下`accept()`函数：

	int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

参数说明：

- sockfd： 服务器的socket描述字（称为“监听socket描述字”）
- addr： 指向`struct sockaddr *`的指针,用于返回客户端的协议地址
- addrlen: 协议地址的长度

注意：**如果accpet成功，那么其返回值是由内核自动生成的一个全新的描述字（称为“已连接的socket描述字”），代表与返回客户的TCP连接。**


>注意：accept的第一个参数为服务器的socket描述字，是服务器开始调用socket()函数生成的，称为监听socket描述字；而accept函数返回的是已连接的socket描述字。一个服务器通常通常仅仅只创建一个监听socket描述字，它在该服务器的生命周期内一直存在。内核为每个由服务器进程接受的客户连接创建了一个已连接socket描述字，当服务器完成了对某个客户的服务，相应的已连接socket描述字就被关闭。

在使用过程中注意：**如果不关心客户端地址信息的话，可以把第二个和第三个参数都设置为空指针 NULL。**

如：

	connfd = accept(listen_fd, (struct sockaddr*)NULL, NULL)

如果关心客户端地址则：

	/*客户端地址信息*/
	socklen_t cli_len;
	struct sockaddr_in cli_addr;
	memset(&cli_addr, '0', sizeof(cli_addr));
	cli_len = sizeof(cli_addr);
	
	/*accept接收客户端请求*/
	conn_fd = accept(listen_fd, (struct sockaddr*)&cli_addr, &cli_len);
    printf("client ip: %s, port: %d\n",
                inet_ntoa(cli_addr.sin_addr),
                ntohs(cli_addr.sin_port));
    


## 5.5 read()、write()函数
上面步骤完成后，服务器与客户已经建立好连接了。可以调用网络I/O进行读写操作，网络I/O操作有下面几组：

- read()/write() 阻塞式
- recv()/send() 基础I/O, 专门用于socket数据读写的系统调用
- readv()/writev() 高级I/O, 分散读/集合写
- recvmsg()/sendmsg() 推荐使用最通用的I/O函数
- recvfrom()/sendto()

这里介绍recv和send
	
	ssize_t recv ( int sockfd, void *buf, size_t len, int flags );
	ssize_t send ( int sockfd, const void *buf, size_t len, int flags );

函数说明：


- `recv`读取sockfd上的数据，buf和len参数分别指定读缓冲区的位置和大小，flags一般设置为0。返回0说明连接关闭，返回-1出错并设置errno。
- `send`往sockfd上写入数据，buf和len参数分别指定写缓冲区的位置和大小。成功时返回实际写入的数据的长度，失败则返回-1并设置errno。

## 5.6 close关闭

关闭一个连接实际上就是关闭该连接对应的socket，可以通过普通文件描述符的系统调用来完成。

	#include <unistd.h>
	int close(int fd); 
	
close系统调用并非总是立即关闭一个连接，而是将fd的引用计数减1。只有当fd的引用计数为0时，才真正关闭连接。这个在后面多进程处理尤为显著。

直接关闭则用`shutdown()`函数。

# 六. 一个完整的echo server

在我的[github Clanguage仓库中专门socketAPis](https://github.com/BeginMan/Clanguage/tree/master/socketAPis)目录放置编写的网络IO代码。这里参考两个：

- [简单的echo server echo_server.c](https://github.com/BeginMan/Clanguage/blob/master/socketAPis/echo_server.c)
- [客户端和服务端echo demo](https://github.com/BeginMan/Clanguage/tree/master/socketAPis/echo_server_demo)


# 七. Python socket
Python操作socket比C简单多了，且调用的是C socket api.之前写过：

- [python网络编程（三）python socket](http://beginman.cn/python/2015/04/06/python-socket/)
- [python网络编程（四）python SocketServer](http://beginman.cn/python/2015/04/06/python-SocketServer/)

以及之前看[《Python网络编程攻略》，写过的一些示例代码](https://github.com/BeginMan/BookNotes/tree/master/Python/pnp)

PS.真心觉得写Python太舒服了，为毛我要写C呢？主要是想啃一啃**UNP**这块难啃的骨头！

# 参考资料

- 《Linux高性能服务器编程》
- [Linux Socket编程（不限Linux）](http://www.cnblogs.com/skynet/archive/2010/12/12/1903949.html)
- [socket 编程基础知识](http://cizixs.com/2015/03/29/basic-socket-programming)

