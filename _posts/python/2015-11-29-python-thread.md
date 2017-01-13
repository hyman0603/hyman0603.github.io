---
layout: post
title: "python多线程编程(2) thread模块"
description: "python多线程编程(2) thread模块"
category: "python"
tags: [python]
---
在第一节：[Python多线程编程(1)：基础](http://beginman.cn/python/2015/04/09/Python-learn9/)算是把一些基础性的东西复习了一遍。接下来总结thread模块，虽然不建议用了，但是对于研究底层而言还是挺有必要的。。注意，在python3中，thread更名为_thread.


常用函数：

	thread.start_new_thread(function, args[, kwargs])
	# 创建一个新线程并返回它的标识，其方法类似apply(),需要一个函数名和参数（必须是元组类型的，若无则传`()`）

	thread.exit()
	# 退出线程，若没有捕获则触犯SystemExit异常。

要明确的是**同步原语(thread提供锁对象(lock object, 也叫原语锁、简单锁、互斥锁、互斥量、二值信号量))和线程管理密不可分**， 如下是`LockType`类型锁对象常用方法：

	lock = thread.allocate_lock()
	# 分配一个LockType类型的锁对象

	lock.acquire(wait=None)
	# 尝试获取锁对象

	lock.locked()
	# 如果获取了锁对象返回True,否则False

	lock.release()
	# 释放锁


在之前顺序执行，如果我们sleep(n)，sleep(m),..sleep(z)后，则程序总执行时间为：n+m..+z；如果使用多线程，则执行时间为耗时最长的那个。如下例子：

	import thread
	import time

	def loop0():
	    print 'start loop0 at:', time.ctime()
	    time.sleep(4)
	    print 'end loop0 at:', time.ctime()


	def loop1():
	    print 'start loop1 at:', time.ctime()
	    time.sleep(2)
	    print 'end loop1 at:', time.ctime()

	def main():
	    print 'all loops at:', time.ctime()
	    t1 = thread.start_new_thread(loop0, ())
	    t2 = thread.start_new_thread(loop1, ())
	    time.sleep(6)       # why sleep 6s？
	    print 'all loops done at:', time.ctime()


	if __name__ == '__main__':
	    main()

通过输出时间发现执行时长其实是最长的4s，注意为什么`sleep(6)`呢，**这里使用`sleep()`作为同步机制，因为thread是不对线程控制的，一旦执行完进程立马退出，它才不管手下小弟(子线程)的死活呢**

但是问题暴露出来了，因为我们是**阻塞主进程**，况且这个sleep时间是不可控的，时间长了则阻塞过长，时间短了则还在runing的线程就被kill了。。，那么我们就该用**锁**了。

使用锁后，子线程退出后，主线程才马上退出。如下改进：


	import thread
	import time

	secs = [4, 2]


	def loop(nloop, sec, lock_obj):
	    print 'satrt loop:%s at:[%s]' % (nloop, time.ctime())
	    time.sleep(sec)
	    lock_obj.release()  # 释放锁


	def main():
	    """主线程使用锁来控制子线程"""
	    print 'starting at:', time.ctime()
	    lock_objs = []
	    nloops = range(len(secs))

	    # 分配锁对象
	    for i in nloops:
	        lock = thread.allocate_lock()       # 分配一个LockType类型的锁对象
	        lock.acquire()                      # 尝试获取锁对象
	        lock_objs.append(lock)

	    # 创建线程
	    for i in nloops:
	        thread.start_new_thread(loop, (i,               # thead编号,0-1
	                                       secs[i],         # sleep时间
	                                       lock_objs[i]))   # 分配的锁对象

	    # 确保所有锁对象都释放了主线程才退出
	    for i in nloops:
	        while lock_objs[i].locked():
	            pass

	    print 'all done at:', time.ctime()


	if __name__ == '__main__':
	    main()

通过`while lock_objs[i].locked()`判断是否获取锁对象，来检查所有的子线程是否已经释放，这样的话主线程才能老老实实的等着小弟们了。

ok，thread模块重要的函数就这些，主要参考了《Python核心编程》。呵呵，算是复习吧~



