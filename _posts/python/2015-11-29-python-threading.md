---
layout: post
title: "python多线程编程(3) threading模块"
description: "python多线程编程(3) threading模块"
category: "python"
tags: [python]
---

上一节的[python多线程编程(2) thread模块](http://beginman.cn/python/2015/11/29/python-thread/)是对一个快淘汰的模块的怀念，接下来就要用最时髦的模块theading了。

语法：

	class threading.Thread(group=None, target=None, name=None, args=(), kwargs={})

参数释义：

- `group`: 应为 None，这参数是为将来可能出现的 ThreadGroup 类准备的（现在还没有实现）
- `target`: 为将被 `run()` 方法调用的可调用对象。如果是 None，那就意味着什么也不做
- `name`: 是本线程的名字，默认会分配一个形如“Thread-N”的名字，其中 N 是一个十进制数
- `args`: 是给 target 准备的非关键字参数
- `kwargs`: 是给 target 准备的关键字参数
- `daemon`: 用来设定线程的 daemon 属性，如果使用默认值（None），将从当前进程中继承

接下来介绍threading模块对象：

- `Thread`: 表示一个线程的执行的对象
- `Lock`: 锁原语对象（跟thread模块的锁对象一样）
- `RLock`: 可重入锁对象，使得单线程可以再次获得已经获得了的锁（递归锁定）
- `Condition`: 条件变量对象能让一个线程停下来，等待其他线程满足了某个条件
- `Event`: 通过条件变量，多个线程可以等待某个事件的发生，发生后所有线程都会被激活
- `Semaphore`: 为等待锁的线程提供一个类似“等候室”的结构
- `BoundedSemaphore`: 与Semaphore类似，只是它不允许超过初始值
- `Timer`: 与Thread相似，只是它要等待一段时间后才开始运行

hreading 模块提供的常用方法：

- threading.currentThread(): 返回当前的线程变量。
- threading.enumerate(): 返回一个包含正在运行的线程的list。正在运行指线程启动后、结束前，不包括启动前和终止后的线程。
- threading.activeCount(): 返回正在运行的线程数量，与len(threading.enumerate())有相同的结果。

## 一.Thread类
最长使用的是通过Thread类派生出一个子类，创建这个子类的实例。关于Thread类函数，如下：

`start()`

开始线程的执行

本方法至多只能调用一次。它会在独立线程中执行 run() 方法,如果对一个对象多次调用本方法，会引发 RuntimeError 异常

`run()`

包含了线程实际执行的内容

本方法可以在子类中重写。否则默认调用传给构造器的 target 参数（和 args，kwargs 参数）

常用操作如下：

	def run(self):
	        apply(self.func,self.args)　＃应用apply函数


`join(timeout=None)`

程序挂起，直到线程结束（正常结束，或引发未处理异常，或超出 timeout 的时间）。

>join([timeout]) Wait until the thread terminates. This blocks the calling thread until the thread whose join() method is called terminates – either normally or through an unhandled exception – or until the optional timeout occurs.


timeout 参数是一个以秒为单位的浮点数。当给出 timeout 参数时，因为 join() 方法总是返回 None，你应该随即调用 is_alive() 方法，来判断子线程到底是终结了，还是超时了。

如果没有给出 timeout 参数，那么调用者的进程会一直阻塞直到本进程结束。

一个线程可以被 join() 多次

当调用 join() 方法可能引发死锁，或被调用者的进程还未 start() 时，都会引发一个 RuntimeError


`getName() / setName()`

前者用于返回线程名字，后者用于设置线程名字


`is_alive()`

返回本进程是否是 alive 状态

`daemon`

布尔值，标明本进程是否为“daemon thread”。一定要在 start() 被调用前设定，否则引发 RuntimeError。初始值继承自当前线程，因此从主线程创建的子线程默认都是 False，而从“daemon thread”创建的子线程默认都是 True 当只剩下“daemon thread”为 alive 状态时，整个程序就会退出

关于守护进程可参考如下图：

![](http://beginman.qiniudn.com/python-threading-setDaemon.png)

`isDaemon() / setDaemon()`

为后向兼容而保留的方法，现在请直接访问 daemon 属性

实现方式：

**方式一:创建Thread实例，传递一个函数**

	def foo(sec):
	    print '%s starting..' % sec
	    sleep(sec)
	    print '%s end..' % sec


	def main():
	    threads = []
	    for i in range(5):
	        t = threading.Thread(target=foo, args=(i,))  # 创建Thread实例并传参
	        threads.append(t)

	    for i in threads:
	        i.start()   # 启动所有

	    for i in threads:
	        i.join()    # 等待结束

	if __name__ == '__main__':
	    main()


释义：

- 所有线程创建后，再一起调用`start()`启动，而不是像`start_new_thread()`创建一个启动一个
- 对每个线程调用`join()`函数就不用像thead模块一样管理一大堆锁
- join()**也可以完全不用调用**，一旦线程启动后就会一直运行，知道线程的函数结束，退出为止。只有在你要等待线程结束的时候才调用`join()`.如果你的主线程除了等待线程结束外，还要处理其他事情则可不调用join.

**方式二：创建Thread实例，传递一个可调用的类对象**

这个更加灵活，其实主要用到`__init__()`传参；`__call__()`调用；`apply()`应用

	from time import sleep
	import threading


	secs = [4, 2]


	class ThreadFunc(object):
	    def __init__(self, func, args, name=''):
	        self.func = func
	        self.args = args
	        self.name = name

	    def __call__(self, *args, **kwargs):
	        apply(self.func, self.args)


	def loop(nloop, nsec):
	    print nloop, 'sleep:', nsec
	    sleep(nsec)


	def main():
	    threads = []
	    nloops = range(len(secs))

	    for i in nloops:
	    	# 传递可调用类对象
	        t = threading.Thread(
	            target=ThreadFunc(loop,
	                              (i, secs[i]),
	                              loop.__name__),
	            )
	        threads.append(t)

	    for i in nloops:
	        threads[i].start()

	    for i in nloops:
	        threads[i].join()


	if __name__ == '__main__':
	    main()


**方式三：从Thread派生出一个子类，创建这个子类的实例**

也就继承threading.Thread，注意此时不需要`__call__`，而是重写父类的`run()`方法


	from time import sleep
	import threading

	class Mythread(threading.Thread):
	    def __init__(self,func,args):
	        threading.Thread.__init__(self)
	        self.func = func
	        self.args = args

	    def run(self):
	        apply(self.func,self.args)


	def foo(i):
	    print '%s starting..' %i
	    sleep(i)


	threads = []
	for i in range(5):
	    t = Mythread(foo,(i,))
	    threads.append(t)

	for t in threads:
	    t.start()

	for t in threads:
	    t.join()


这儿[有个有趣的话题关于jon](http://stackoverflow.com/questions/15085348/what-is-the-use-of-join-in-python-threading), 如下图分析join在不同场景的用途：

![](http://beginman.qiniudn.com/what_is_the_use_of_join_in_python_threading.png)

**join只与主线程(main-thread)的执行流(execution-flow)相关，主线程是否等待子线程的结束需要看自己的业务逻辑。**


