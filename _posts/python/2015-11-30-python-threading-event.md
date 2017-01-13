---
layout: post
title: "python多线程编程(6) threading Event"
description: "python多线程编程(6) threading Event"
category: "python"
tags: [python]
---

上一节的[python多线程编程(5) threading Condition高级锁](http://beginman.cn/python/2015/11/30/python-threading-condition/)用的比较少，Event与Condition类似，只不过它是通过`set()`,`clear()`,`wait()`维护内部的标识符来实现高级锁，进行线程同步的。

Event也是一个工厂函数，如下：


	def Event(*args, **kwargs):
	    """A factory function that returns a new event.

	    Events manage a flag that can be set to true with the set() method and reset
	    to false with the clear() method. The wait() method blocks until the flag is
	    true.

	    """
	    return _Event(*args, **kwargs)

看着挺简单的，**Event是Condition的简单实现版本**

	class _Event(_Verbose):
		def __init__(self, verbose=None):
	        self.__cond = Condition(Lock())				# _Condition对象,使用Lock
	        self.__flag = False 						# 标识符默认false

	    def _reset_internal_locks(self):
	        # private!  called by Thread._reset_internal_locks by _after_fork()
	        self.__cond.__init__()

	    def isSet(self):
	        'Return true if and only if the internal flag is true.'
	        return self.__flag

	    def set(self):
	        """Set the internal flag to true.

	        所有线程等待标志变成True被激活，则wait()线程不会在阻塞
	        """
	        self.__cond.acquire()
	        try:
	            self.__flag = True
	            self.__cond.notify_all()		# 这里使用Condition的notify_all()来唤醒所有wait()的线程
	        finally:
	            self.__cond.release()

	    def clear(self):
	        """Reset the internal flag to false.

	       	随后，wait()将线程阻塞直到set()将flag 设为true.

	        """
	        self.__cond.acquire()
	        try:
	            self.__flag = False
	        finally:
	            self.__cond.release()

	    def wait(self, timeout=None):
	    	"""Block until the internal flag is true."""
	    	self.__cond.acquire()
	        try:
	            if not self.__flag:
	                self.__cond.wait(timeout)
	            return self.__flag
	        finally:
	            self.__cond.release()

 那么上一节的程序可以简写成这样：


	import threading


	class Thread_A(threading.Thread):
	    def __init__(self, event_obj, name):
	        """
	        @:param event_obj: Event object
	        @:param name: thread name
	        """
	        super(Thread_A, self).__init__(name=name)
	        self.event = event_obj

	    def run(self):
	        while not self.event.is_set():      # test
	            print 'Flag False'

	        self.event.wait(10)              # wait 10s 等待B的应答, 如果10s后B还没有应答则timeout,自动开闸
	        print self.name, 'wait 10s'


	class Thread_B(threading.Thread):
	    def __init__(self, event_obj, name):
	        """
	        @:param event_obj: Event object
	        @:param name: thread name
	        """
	        super(Thread_B, self).__init__(name=name)
	        self.event = event_obj

	    def run(self):
	        self.event.set()          # 开始应答A，A接收到应答后被唤醒并执行
	        print self.name, 'set'

	cond = threading.Event()        # 创建Event实例
	t1 = Thread_A(cond, 't1')
	t2 = Thread_B(cond, 't2')
	t1.start()
	t2.start()


与Condition相比，不用自己手动实现获取锁和释放锁了。

