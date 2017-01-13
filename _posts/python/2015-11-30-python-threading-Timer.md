---
layout: post
title: "python多线程编程(8) threading Timer"
description: "python多线程编程(8) threading Timer"
category: "python"
tags: [python]
---

threading.Timer是threading.Thread的子类，可以在指定时间间隔后执行某个操作。

	def Timer(*args, **kwargs):
		return _Timer(*args, **kwargs)

	class _Timer(Thread):
	    """Call a function after a specified number of seconds:

	            t = Timer(30.0, f, args=[], kwargs={})
	            t.start()
	            t.cancel()     # stop the timer's action if it's still waiting

	    """

	    def __init__(self, interval, function, args=[], kwargs={}):
	        Thread.__init__(self)
	        self.interval = interval
	        self.function = function
	        self.args = args
	        self.kwargs = kwargs
	        self.finished = Event()

	    def cancel(self):
	        """Stop the timer if it hasn't finished yet"""
	        self.finished.set()

	    def run(self):
	        self.finished.wait(self.interval)
	        if not self.finished.is_set():
	            self.function(*self.args, **self.kwargs)
	        self.finished.set()

如下实例：

	import threading


	def hello():
	    print 'hello world'

	t = threading.Timer(5, hello)		# 5s后调用hello
	t.start()

我们也可以自己造轮子：

	import threading
	import time

	class TimerClass(threading.Thread):
	    def __init__(self):
	        threading.Thread.__init__(self)
	        self.event = threading.Event()
	        self.count = 10

	    def run(self):
	        while self.count > 0 and not self.event.is_set():
	            print self.count
	            self.count -= 1
	            self.event.wait(1)

	    def stop(self):
	        self.event.set()

	tmr = TimerClass()
	tmr.start()

	time.sleep(3)

	tmr.stop()

