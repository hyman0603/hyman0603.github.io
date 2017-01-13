---
layout: post
title: "python多线程编程(7) threading Semaphore and BoundedSemaphore"
description: "python多线程编程(7) threading Semaphore and BoundedSemaphore"
category: "python"
tags: [python]
---


信号量（Semaphore)也是工厂函数，如下：

	def Semaphore(*args, **kwargs):
		return _Semaphore(*args, **kwargs)

	class _Semaphore(_Verbose):
		def __init__(self, value=1, verbose=None):
			"""
			构造器使用参数value来表示计数器的初始值，默认值为1
			一个条件锁实例用于保护计数器，同时当信号量被释放时通知其他线程。
			"""
	        if value < 0:
	            raise ValueError("semaphore initial value must be >= 0")
	        _Verbose.__init__(self, verbose)
	        self.__cond = Condition(Lock())		# Condition实例，Lock锁
	        self.__value = value

	    def acquire(self, blocking=1):
	    	rc = False
	        with self.__cond:					# with lock
	            while self.__value == 0:		# 如果计数器为0则acquire()调用被阻塞
	                if not blocking:
	                    break
	                if __debug__:
	                    self._note("%s.acquire(%s): blocked waiting, value=%s",
	                            self, blocking, self.__value)
	                self.__cond.wait()
	            else:							# 否则每调用一次acquire()，计数器减1
	                self.__value = self.__value - 1
	                if __debug__:
	                    self._note("%s.acquire: success, value=%s",
	                            self, self.__value)
	                rc = True
	        return rc

	    def release(self):
	        """释放信号量，每调用一次release()，计数器加1.
	        信号量类的release()方法增加计数器的值并且唤醒其他线程。
	        """
	        with self.__cond:						# with lock
	            self.__value = self.__value + 1 	# 每调用一次release()，计数器加1.
	            if __debug__:
	                self._note("%s.release: success, value=%s",
	                        self, self.__value)
	            self.__cond.notify()				# Condition notify()释放线程（如果存在挂起的线程）

信号量同步机制适用于访问像服务器这样的有限资源。信号量同步的例子：

	semaphore = threading.Semaphore()
	semaphore.acquire()
	 # 使用共享资源
	...
	semaphore.release()


`BoundedSemaphore`:“有限”(bounded)信号量类，可以确保`release()`方法的调用次数不能超过给定的初始信号量数值(value参数)

	class _BoundedSemaphore(_Semaphore):		# 继承_Semaphore类
		def __init__(self, value=1, verbose=None):
        	_Semaphore.__init__(self, value, verbose)
        	self._initial_value = value 		# 设定初始信号量

        def release(self):
        	with self._Semaphore__cond:
        		# 检查release()的调用次数是否小于等于acquire()次数
	            if self._Semaphore__value >= self._initial_value:
	                raise ValueError("Semaphore released too many times")
	            self._Semaphore__value += 1
	            self._Semaphore__cond.notify()

同样信号量(Semaphore)对象可以和“with”一起使用：

	semaphore = threading.Semaphore()
	with semaphore:
  		# 使用共享资源
  		...

如下实例：控制访问url地址，每两个两个的进行，当前面两个都没有release则后面的线程阻塞，如果前面两个任意一个release后则后面线程跟进。

	import threading
	import time
	import random


	class AccessUrl(threading.Thread):
	    """访问url"""
	    def __init__(self, host):
	        threading.Thread.__init__(self)
	        self.host = host

	    def run(self):
	        k = random.randint(1, 10)
	        print "Processing " + self.host + " waiting for : " + str(k)
	        time.sleep(k)
	        print "exiting " + self.host
	        pool.release()


	class Handler(threading.Thread):
	    def __init__(self):
	        threading.Thread.__init__(self)

	    def run(self):
	        for i in hosts:
	            pool.acquire()
	            t = AccessUrl(i)
	            t.setDaemon(True)
	            t.start()


	# 设置初始信号量数值为2,意味着release()调用次数不能超过初始值
	maxconn = 2

	# 有限(bounded)信号量
	pool = threading.BoundedSemaphore(value=maxconn)

	# 临界资源
	hosts = ["http://yahoo.com",
	         "http://google.com",
	         "http://amazon.com",
	         "http://ibm.com",
	         "http://apple.com"]

	handler = Handler()
	handler.start()
	handler.join()

	print "exiting main"


如下输出：

	Processing http://yahoo.com waiting for : 2
	Processing http://google.com waiting for : 10

	exiting http://yahoo.com
	Processing http://amazon.com waiting for : 1

	exiting http://amazon.com
	Processing http://ibm.com waiting for : 6
	
	exiting http://ibm.com
	Processing http://apple.com waiting for : 3
	
	exiting main




