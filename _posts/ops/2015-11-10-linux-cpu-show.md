---
layout: post
title: "Linux CPU信息查看与分析"
description: "Linux CPU信息查看与分析"
category: "ops"
tags: [ops]
---

要弄清楚的是：

- Linux cpu如何查看？
- 物理CPU和逻辑CPU的区别？
- CPU核数是什么？
- 什么是超线程技术？
- 总核数与总逻辑CPU数怎么求？

# 一. 概念

考虑内核的数量是以并行方式工作的物理处理器的数目，作为逻辑处理器的线程数，线程或逻辑处理器用来提升并执行更多的指令，我们可以考虑每个线程执行一个特定的指令，如果处理器有2个线程，它可以同时执行2个指令。

## 物理CPU

**物理的核心是一个实际的物理处理器内核,就是插槽上的CPU.**每个物理核心有自己的线路和自己一级（一般2级）缓存可以分别从其他物理核心芯片上读取和执行指令.

## 逻辑CPU
逻辑核是一种比实际物理实体更抽象的编程抽象.一个逻辑核心的一个简单的定义是，它是一个处理单元，它可以在与其它逻辑内核并行执行它自己的线程。事实上，你可以说，一个逻辑核心相当于一个线程,每一个物理核可以有多个逻辑核心，多个逻辑内核共享资源。所以有更多的逻辑内核，也不一定会让你有更多的物理核心相同的性能增加。
参考[What is the difference between physical core and logical core?](http://www.tomshardware.com/answers/id-1850932/difference-physical-core-logical-core.html)

系统引入了SMT（Simultaneousmulti-threading的功能后，在SMT功能启用的情况下，**逻辑cpu个数是物理cpu个数的两倍，而在SMT功能禁用的情况下，逻辑cpu个数与物理cpu个数相等。 备注一下：Linux下top查看的CPU是逻辑CPU个数。**

## CPU核数
一块CPU上面能处理数据的芯片组的数量。比如现在的i5 760,是双核心四线程的CPU。而 i5 2250 是四核心四线程的CPU。

一般来说，**物理CPU个数×cpu核数=逻辑CPU的个数，如果不相等的话，则表示服务器的CPU支持超线程技术**

## 求核数

总核数 = 物理CPU个数 X 每颗物理CPU的核数  

总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数

# 二. Linux如何查看物理CPU 及逻辑CPU个数，CPU核心数

	cat /proc/cpuinfo 

注意：

**具有相同core id的CPU是同一个core的超线程。** 

**具有相同physical id的CPU是同一个CPU封装的线程或核心。**

如下命令：

物理CPU个数如下：

	$ cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
	1

每个物理CPU中core的个数(即核数)如下：

	$ cat /proc/cpuinfo| grep "cpu cores"| uniq
	cpu cores	: 4

逻辑CPU的个数如下：

	$ cat /proc/cpuinfo| grep "processor"| wc -l
	4

这里:

	逻辑CPU的个数= 物理CPU个数×每颗核数
	// 4 = 1 x 4

如果不相等的话，则表示服务器的CPU支持超线程技术。在实际部署中当以逻辑CPU为准。

参考：[ Linux及AIX下如何查看物理CPU, 逻辑CPU及核数 ](http://blog.itpub.net/35489/viewspace-743927/)

	




