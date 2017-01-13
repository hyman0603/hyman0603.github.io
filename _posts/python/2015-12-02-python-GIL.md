---
layout: post
title: "python多线程编程(10) 理解GIL"
description: "python多线程编程(10) 理解GIL"
category: "python"
tags: [python]
---

# 一.介绍

首先需要明确的一点是GIL并不是Python的特性，它是在实现Python解析器(CPython)时所引入的一个概念。同样一段代码可以通过CPython，PyPy，Psyco等不同的Python执行环境来执行。像其中的JPython就没有GIL。然而因为CPython是大部分环境下默认的Python执行环境。所以在很多人的概念里CPython就是Python，也就想当然的把GIL归结为Python语言的缺陷。所以这里要先明确一点：GIL并不是Python的特性，Python完全可以不依赖于GIL。

官方给出的解释：

>In CPython, the global interpreter lock, or GIL, is a mutex that prevents multiple native threads from executing Python bytecodes at once. This lock is necessary mainly because CPython’s memory management is not thread-safe. (However, since the GIL exists, other features have grown to depend on the guarantees that it enforces.)

GIL:一个防止多线程并发执行机器码的一个Mutex

# 二.一个实验

	from threading import Thread
	import time


	def countdown(n):
	    while n > 0:
	        n -= 1

	if __name__ == '__main__':
	    s = time.time()
	    COUNT = 100000000       # 100 million
	    # countdown(COUNT)        # use time 5.29941797256

	    t1 = Thread(target=countdown, args=(COUNT//2, ))
	    t2 = Thread(target=countdown, args=(COUNT//2, ))
	    t1.start()
	    t2.start()
	    t1.join()
	    t2.join()
	    # use time 6.96924901009
	    print 'use time', time.time() - s

在四核MacPro执行：

	顺序执行：	7.8s
	Threaded (2 threads) : 15.4s (2X slower!)

如果分四个线程执行：

	Threaded (4 threads) : 15.7s (about the same)

如果一个CPU禁用：
	
	Threaded (2 threads) : 11.3s (~35% faster than running with all 4 cores)
	Threaded (4 threads): 11.6s 

代码上注释的执行时间是我的双核air测试的. **为什么多线程执行性能还不如单线程呢？**

# 三.线程和GIL

## 3.1 关于Python线程：

- Python线程都是真实的系统线程(POSIX threads (pthreads)和Windows threads)
- 完全由主机操作系统管理
- 代表了Python的线程执行解释过程（用C语言编写）

## 3.2 哎，GIL：

- 禁止并行
- 这有一个全局解释器锁挡住
- GIL确保同一时刻只有一个线程执行
- 简化了许多低级别的细节（内存管理，C扩展等）

## 3.3 线程执行模型

![](http://beginman.qiniudn.com/UnderstandingGIL1.png)

- **当一个线程正在执行，它会hold GIL**
- **GIL released on I/O (read,write,send,recv,etc.)**

## 3.4 CPU密集型任务(CPU Bound Tasks)

- CPU密集型线程从未执行I/O,被作为特殊情况处理
- 每100"ticks"检查("check")一次
- 通过`sys.setcheckinterval()`更改这个阀值

![](http://beginman.qiniudn.com/UnderstandingGIL2.png)

# 3.5 什么是"Tick?"

![](http://beginman.qiniudn.com/UnderstandingGIL3.png)

- 定期"check"简单(通过sys.setcheckinterval())
- 如果线程执行则：
	- 重设tick计数器
	- 如果运行的主线程则开始信号处理
	- 释放GIL
	- 重新获得GIL
- That's it

## 3.6 C执行

![](http://beginman.qiniudn.com/UnderstandingGIL4.png)

# 四.GIL和线程切换结构
## 4.1 Python Locks

- Python解释器仅仅提供**单一**lock类型(C中)，用于构建所有其他线程同步原语(thread synchronization primitives)
- 并不是简单的互斥锁(mutex lock)
- 是pthreads互斥(pthreads mutex)和条件变量(condition variable)构建的二进制信号(semaphore)
- GIL就是这种锁的实例

## 4.2 锁的构建

锁的三部分组成：

	locked = 0 					# Lock status
	mutex = pthreads_mutex() 	# Lock for the status
	cond = pthreads_cond() 		# Used for waiting/wakeup

 `acquire()`和`release()`是如何工作：

![](http://beginman.qiniudn.com/UnderstandingGIL5.png)


## 4.3 线程切换

### 4.3.1  比较简单的情况

假如你有两个线程，一个正在执行，一个准备状态(等待GIL)， 如下图：

![](http://beginman.qiniudn.com/UnderstandingGIL6.png)

最简单的情况：线程1执行I/O (read/write), 线程1可能会阻塞所以它要释放GIL，让出CPU让其他线程使用，别站着茅坑不拉屎。

![](http://beginman.qiniudn.com/UnderstandingGIL7.png)

GIL的释放导致信号操作,通过处理的线程库和操作系统

![](http://beginman.qiniudn.com/UnderstandingGIL8.png)

### 4.3.2 较复杂的情况
线程1一直执行直到进行一次`check`,这就是我们常见的非I/O操作，如CPU密集型， check后其他线程会进入执行。但是那个线程会执行呢？可能线程1立马执行，可能线程2开始接手，还可能优先级高的执行

![](http://beginman.qiniudn.com/UnderstandingGIL9.png)

理解上面的问题，还是看一看pthreads的执行和OS调度吧。

pthreads的执行细节如下：

- 条件变量有一个内部的等待队列
- 信号pop出一个线程从队列中
- 在这之后呢？ 看下OS调度吧

![](http://beginman.qiniudn.com/UnderstandingGIL10.png)

OS 调度：

- 操作系统有线程或进程准备执行的优先级
- 已经发出信号的线程只需进入该队列
- 但操作系统会先让优先级高的线程或进程执行
- 所以对以signaled的线程有可能并非立马执行，决定权还是在OS调度手里

所以对于线程的切换有下面两种情况：

(1).线程1可能继续执行下去; 线程2进入OS就绪队列且执行一段时间后

![](http://beginman.qiniudn.com/UnderstandingGIL11.png)

(2).线程2可能会立马执行

![](http://beginman.qiniudn.com/UnderstandingGIL12.png)

所以：**Python的线程就是C语言的一个pthread，并通过操作系统调度算法进行调度（例如linux是CFS）。为了让各个线程能够平均利用CPU时间，python会计算当前已执行的微代码数量，达到一定阈值后就强制释放GIL。而这时也会触发一次操作系统的线程调度（当然是否真正进行上下文切换由操作系统自主决定）**

## 4.4 Single CPU Threading
线程交替执行，但切换远比你想象的那么频繁,可能会成百上千次check(但这是好事)

![](http://beginman.qiniudn.com/UnderstandingGIL13.png)

## 4.5 多核GIL战争

多核中，可运行的线程得到调度同时与GIL混战，如下图，Thread 2 is repeatedly signaled, but when it
wakes up, the GIL is already gone (reacquired)

![](http://beginman.qiniudn.com/UnderstandingGIL14.png)

## 4.6 多核事件处理

CPU密集型线程使得GIL回收困难对于要处理事件的线程

![](http://beginman.qiniudn.com/UnderstandingGIL15.png)

## 4.7 I/O处理的行为
I/O操作通常不阻塞，由于缓冲(buffer)，操作系统是能够满足I/O立即请求并保持一个线程运行,然而GIL总是释放的，Results in GIL thrashing under heavy load.

![](http://beginman.qiniudn.com/UnderstandingGIL16.png)


如下图表示的两个线程在双核CPU上得执行情况。两个线程均为CPU密集型运算线程。绿色部分表示该线程在运行，且在执行有用的计算，红色部分为线程被调度唤醒，但是无法获取GIL导致无法进行有效运算等待的时间。

![](http://ww4.sinaimg.cn/mw690/aa213e02jw1eujep4hiebj20mx02gdg0.jpg)

由图可见，GIL的存在导致多线程无法很好的利用多核CPU的并发处理能力。

而对于Python的IO密集型线程，如下图：

![](http://ww3.sinaimg.cn/mw690/aa213e02jw1eujep4uxhgj20mx04cweq.jpg)

因为GIL的存在，只有IO Bound场景下得多线程会得到较好的性能


# 五.参考：

- [python 线程，GIL 和 ctypes](http://zhuoqiang.me/python-thread-gil-and-ctypes.html)
- [Python的GIL是什么鬼，多线程性能究竟如何](http://python.jobbole.com/81822/)
- [UnderstandingGIL](http://www.dabeaz.com/python/UnderstandingGIL.pdf)


