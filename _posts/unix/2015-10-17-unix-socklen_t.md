---
layout: post
title: "Unix socklen_t类型"
description: ""
category: "unp"
tags: [Unix网络编程]
---

在[一.套接字地址结构](https://github.com/BeginMan/BookNotes/blob/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition/top3.md#一套接字地址结构)一节中一览了**POSIX数据类型**

- `int8_t`:带符号的8位整数 | `<sys/types.h>`
- `uint8_t`:无符号的8位整数 | `<sys/types.h>`
- `int16_t`:带符号的16位整数 | `<sys/types.h>`
- `uint16_t`:无符号的16位整数 | `<sys/types.h>`
- `int32_t`: 带符号的32位整数 | `<sys/types.h>`
- `uint32_t`:无符号的32位整数 | `<sys/types.h>`
- `sa_family_t`: 套接字地址结构的地址族 | `<sys/socket.h>`
- `socklen_t`:套接字地址结构的长度，一般为uint32_t | `<sys/socket.h>`
- `in_addr_t`:IPv4地址，一般为uint32_t | `<netinet/in.h>`
- `in_port_t`:TCP或UDP端口，一般为uint16_t | `<netinet/in.h>`


