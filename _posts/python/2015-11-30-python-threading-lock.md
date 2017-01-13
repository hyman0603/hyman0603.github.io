---
layout: post
title: "python多线程编程(4) threading Lock and RLock"
description: "python多线程编程(4) threading模块的锁"
category: "python"
tags: [python]
---

上一节[**python多线程编程(3) threading模块**](http://beginman.cn/python/2015/11/29/python-threading/)对`Thread`类的主要方法进行了总结，这一节总结下threading`Lock`和`RLock`.

# 一. 线程同步（锁）

多线程的优势在于可以同时运行多个任务（至少感觉起来是这样）。**但是当线程需要共享数据时，可能存在数据不同步的问题**。考虑这样一种情况：一个列表里所有元素都是0，线程”set”从后向前把所有元素改成1，而线程”print”负责从前往后读取列表并打印。那么，可能线程”set”开始改的时候，线程”print”便来打印列表了，输出就成了一半0一半1，这就是数据的不同步。**为了避免这种情况，引入了锁的概念。**

锁有两种状态——锁定和未锁定。每当一个线程比如”set”要访问共享数据时，必须先获得锁定；如果已经有别的线程比如”print”获得锁定了，那么就让线程”set”暂停，也就是同步阻塞；等到线程”print”访问完毕，释放锁以后，再让线程”set”继续。经过这样的处理，打印列表时要么全部输出0，要么全部输出1，不会再出现一半0一半1的尴尬场面。


线程与锁的交互如下图所示：

![](http://ww3.sinaimg.cn/mw690/aa213e02jw1ew4833wjycj20e006sgmy.jpg)

**Python线程同步机制**：

- **Lock，RLock**  (低级锁)
- **Semaphore**  （条件变量,高级锁）
- **Condition**	  (条件变量,高级锁)
- **Event**       (条件变量,高级锁)
- **Queue**       (队列,高级锁)

那么先从第一个开始吧，余下的在后面专题中总结。

# 二. Lock与RLock的区别

如下代码进行区别,Lock：

	import threading
	lock = threading.Lock()		# Lock对象
	lock.acquire()				# 正常
	lock.acquire()  			# 产生了死琐,程序一直阻塞在这里。
	lock.release()
	lock.release()

RLock:

	import threading
	rLock = threading.RLock()  	# RLock对象
	rLock.acquire()				# 正常
	rLock.acquire()				# 可重入锁对象,在同一线程内，程序不会堵塞。
	rLock.release()				# 释放
	rLock.release()				# 释放

区别就是：**`RLock`,可重入锁对象，使得单线程可以再次获得已经获得了的锁（递归锁定）,RLock允许在同一线程中被多次acquire。而Lock却不允许这种情况。注意：如果使用RLock，那么acquire和release必须成对出现，即调用了n次acquire，必须调用n次的release才能真正释放所占用的琐。**

我们在看threading源码的时候发现，**Lock模块其实就是thread模块的`allocate_lock`。**

# 三. 何谓锁？

当多个线程同时访问共享资源(或称“临界资源”)时，往往会出现数据的不一致，如下实例：

	import threading
	import time


	class SetGlobalVariableThread(threading.Thread):
	    def __init__(self, thread_name):
	        super(SetGlobalVariableThread, self).__init__(name=thread_name)

	    def run(self):
	        global x
	        x += 1
	        time.sleep(2)
	        print x


	x = 0
	threads = []
	for i in range(10):
	    threads.append(SetGlobalVariableThread(i))

	for t in threads:
	    t.start()

	# 10
	# 10
	# 10
	# 10
	# 10
	# 10
	# 10
	# 10
	# 10
	# 10

为什么都输出10呢？ 这是因为全局变量x作为公共数据，当一个线程对其操作累加后，sleep了2s（模拟线程还做其他事情的耗时），然后在sleep过程中，其他线程又修改了它，依次类推，由于这10个线程的修改的耗时基本上微秒级别的，所以数据立马被修改成了10，在线程sleep 2s后开始打印的都是已经被修改过的数据了，所以都是10.

解决办法就是：**使用互斥锁来保护公共资源**。

**用互斥锁来保证同一时刻只有一个线程访问公共资源,实现简单的`同步`，当有一个线程获的锁(`acquire()`)之后，这把锁就会进入locke状态（被锁起来了），另外的线程试图获取锁的时候就会变成`同步阻塞状态`，当拥有线程锁的的线程调用锁方法 `release()`之后就会释放锁，那么锁就会变成开锁unlocked状态，之后再从同步阻塞状态的线程中选择一个来获得锁.然后依次类推，直到所有线程都finish。**

如下使用锁改进的代码：


	import threading
	import time


	class SetGlobalVariableThread(threading.Thread):
	    def __init__(self, thread_name):
	        super(SetGlobalVariableThread, self).__init__(name=thread_name)

	    def run(self):
	        global x
	        lock.acquire()      # 锁住
	        x += 1
	        time.sleep(2)
	        print x
	        lock.release()      # 释放

	x = 0
	lock = threading.Lock()     # 分配锁对象
	threads = []
	for i in range(10):
	    threads.append(SetGlobalVariableThread(i))

	for t in threads:
	    t.start()

	#1
	#2
	#3
	#4
	#5
	#6
	#7
	#8
	#9
	#10


当然也可以使用**可重入锁：`threading.RLock()`:方法和互斥锁一样**。

使用场景： **假设一个锁嵌套的情况：有个线程已经获取锁和共享资源了，但是又需要一把锁来获取另外一个资源，那么只要把代码里面的：
`lock = threading.Lock()`改为：`lock = threading.RLock()`即可。**

# 四. with作用于锁

可将锁（Lock）与`with`语句一起使用，锁可以作为上下文管理器（context manager）。

使用`with`语句的好处是：当程序执行到`with`语句时，`acquire()`方法将被调用，当程序执行完`with`语句时，`release()`方法会被调用,这样我们就不用显式地调用`acquire()`和`release()`方法，而是由`with`语句根据上下文来管理锁的获取和释放。下面我们用`with`语句重写:
	
	...
	def run(self):
        global x
        with lock:
            x += 1
            time.sleep(2)
            print x

是不是可简单。


参考：

[python：threading多线程模块-锁介绍](http://zeping.blog.51cto.com/6140112/1258973)

[Python线程指南](http://python.jobbole.com/82105/)


