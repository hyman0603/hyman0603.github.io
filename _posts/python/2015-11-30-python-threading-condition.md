---
layout: post
title: "python多线程编程(5) threading Condition高级锁"
description: "python多线程编程(5) threading Condition高级锁"
category: "python"
tags: [python]
---

Python线程同步方式之一的锁,Lock & RLock在上一节[**python多线程编程(4) threading Lock and RLock**](http://beginman.cn/python/2015/11/30/python-threading-lock)已经总结了，这一节看下高级锁：Condition.

# 一.线程通信（条件变量）
紧接上一节的例子，然而还有另外一种尴尬的情况：列表并不是一开始就有的；而是通过线程”create”创建的。如果”set”或者”print” 在”create”还没有运行的时候就访问列表，将会出现一个异常。使用锁可以解决这个问题，但是”set”和”print”将需要一个无限循环——他们不知道”create”什么时候会运行，**让”create”在运行后`通知`”set”和”print”显然是一个更好的解决方案。于是，引入了条件变量。**

**条件变量允许线程比如”set”和”print”在条件不满足的时候（列表为None时）等待，等到条件满足的时候（列表已经创建）发出一个通知，告诉”set” 和”print”条件已经有了，你们该起床干活了；然后”set”和”print”才继续运行。**

线程与条件变量的交互如下图所示：

![](http://ww3.sinaimg.cn/mw690/aa213e02jw1ew4834l3wcj20e009nmzc.jpg)

![](http://ww4.sinaimg.cn/mw690/aa213e02jw1ew4834ykx6j20e009e76g.jpg)

# 二. Condition解析

`condition`英文是：条件，状态的意思，源码中，`Condition`是一个**工厂函数返回新的condition对象**

	def Condition(*args, **kwargs):
	    """Factory function that returns a new condition variable object.

	    A condition variable allows one or more threads to wait until they are
	    notified by another thread.

	    If the lock argument is given and not None, it must be a Lock or RLock
	    object, and it is used as the underlying lock. Otherwise, a new RLock object
	    is created and used as the underlying lock.

	    """
	    return _Condition(*args, **kwargs)

在`_Condition`类中，实例化参数如下：
	
	class _Condition(_Verbose):
		def __init__(self, lock=None, verbose=None):
			if lock is None:
	            lock = RLock()
	        self.__lock = lock
	        # Export the lock's acquire() and release() methods
	        self.acquire = lock.acquire
	        self.release = lock.release
	        ..

在创建Condigtion对象的时候把琐对象作为参数传入，提供了acquire, release方法，其含义与琐的acquire, release方法一致。Condition还提供了如下方法(特别要注意：这些方法只有在占用琐(acquire)之后才能调用，否则将会报RuntimeError异常。)：

`wait(timeout=None)`

等待通知或直到超时发生

该方法释放底层锁(underlying lock),然后阻塞直到它被调用同样条件的其他线程`notify()`或`notifyall()`唤醒，或者是超时。一旦被唤醒或超时则他将重新获得锁并返回。

`notify(n=1)`

释放等待该条件的一个或多个线程（如果存在挂起的线程），注意：notify()方法不会释放所占用的琐。

`notifyAll()`

释放所有等待该条件的线程。这些方法不会释放所占用的琐。

如下简单的例子：


	import threading
	import time


	class Thread_A(threading.Thread):
	    def __init__(self,cond_obj, name):
	        """
	        @:param cond_obj: Condition object
	        @:param name: thread name
	        """
	        super(Thread_A, self).__init__(name=name)
	        self.cond = cond_obj

	    def run(self):
	        self.cond.acquire()
	        self.cond.wait(10)              # wait 10s 等待B的应答, 如果10s后B还没有应答则timeout,自动开闸
	        print self.name, 'wait 10s'
	        self.cond.release()


	class Thread_B(threading.Thread):
	    def __init__(self,cond_obj, name):
	        """
	        @:param cond_obj: Condition object
	        @:param name: thread name
	        """
	        super(Thread_B, self).__init__(name=name)
	        self.cond = cond_obj

	    def run(self):
	        self.cond.acquire()
	        self.cond.notify()          # 开始应答A，A接收到应答后被唤醒并执行
	        print self.name, 'notify'
	        self.cond.release()

	cond = threading.Condition()        # 创建Condition实例
	t1 = Thread_A(cond, 't1')
	t2 = Thread_B(cond, 't2')
	t1.start()
	t2.start()

	# out:
	# t2 notify
	# t1 wait 10s

在实际的开发中，这个玩意儿用的少吧，反正我是从来没用过，也很少看见别人用。。
