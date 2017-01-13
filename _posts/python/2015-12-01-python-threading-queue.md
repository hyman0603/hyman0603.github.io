---
layout: post
title: "python多线程编程(9) Queue模块"
description: "python多线程编程(9) Queue模块"
category: "python"
tags: [python]
---

Queue模块源码可少，扫两眼就能看完,如下分析：

	"""A multi-producer, multi-consumer queue."""

	from time import time as _time
	try:
	    import threading as _threading          # 导入threading模块
	except ImportError:
	    import dummy_threading as _threading    # 该模块的接口和thread相同，在没有实现thread模块的平台上提供thread模块的功能。
	from collections import deque               # https://github.com/BeginMan/pythonStdlib/blob/master/collections.md
	import heapq                                # 堆排序 https://github.com/qiwsir/algorithm/blob/master/heapq.md

	__all__ = ['Empty', 'Full', 'Queue', 'PriorityQueue', 'LifoQueue']  # 模块级别暴露接口


	class Empty(Exception):
	    """当调用Queue.get(block=0)/get_nowait()时触发Empty异常

	    调用队列对象的get()方法从队头删除并返回一个项目。可选参数为block，默认为True。
	    如果队列为空且block为True，get()就使调用线程暂停，直至有项目可用。
	    如果队列为空且block为False，队列将引发Empty异常
	    """
	    pass


	class Full(Exception):
	    """当调用Queue.put(block=0)/put_nowait()时触发Full异常

	    如果队列当前为空且block为1，put()方法就使调用线程暂停,直到空出一个数据单元。
	    如果block为0，put方法将引发Full异常。
	    """
	    pass


	class Queue:
	    """创建一个给定的最大大小的队列对象.

	    FIFO(先进先出)队列, 第一加入队列的任务, 被第一个取出
	    If maxsize is <= 0, the queue size is 无限大小.
	    """
	    def __init__(self, maxsize=0):
	        self.maxsize = maxsize
	        self._init(maxsize)             # 初始化queue为空

	        # 所有获取锁的方法必须在返回之前先释放，互斥锁在下面三个Condition条件共享
	        # 从而获取和释放的条件下也获得和释放互斥锁。
	        self.mutex = _threading.Lock()  # Lock锁

	        # 当添加queue元素时通知`not_empty`,之后线程等待get
	        self.not_empty = _threading.Condition(self.mutex)       # not_empty Condition实例

	        # 当移除queue元素时通知`not_full`,之后线程等待put.
	        self.not_full = _threading.Condition(self.mutex)        # not_full Condition实例

	        # 当未完成的任务数为0时，通知`all_tasks_done`,线程等待join()
	        self.all_tasks_done = _threading.Condition(self.mutex)  # all_tasks_done Condition实例
	        self.unfinished_tasks = 0

	    def task_done(self):
	        """表明，以前排队的任务完成了

	        被消费者线程使用. 对于每个get()，随后调用task_done()告知queue这个task已经完成
	        """
	        self.all_tasks_done.acquire()
	        try:
	            # unfinished_tasks 累减
	            unfinished = self.unfinished_tasks - 1
	            if unfinished <= 0:
	                # 调用多次task_done则触发异常
	                if unfinished < 0:
	                    raise ValueError('task_done() called too many times')
	                self.all_tasks_done.notify_all()    # 释放所有等待该条件的线程
	            self.unfinished_tasks = unfinished
	        finally:
	            self.all_tasks_done.release()

	    def join(self):
	        """阻塞直到所有任务都处理完成
	        未完成的task会在put()累加，在task_done()累减, 为0时，join()非阻塞.
	        """
	        self.all_tasks_done.acquire()
	        try:
	            # 一直循环检查未完成数
	            while self.unfinished_tasks:
	                self.all_tasks_done.wait()
	        finally:
	            self.all_tasks_done.release()

	    def qsize(self):
	        """返回队列的近似大小（不可靠！）"""
	        self.mutex.acquire()
	        n = self._qsize()       # len(queue)
	        self.mutex.release()
	        return n

	    def empty(self):
	        """队列是否为空(不可靠)."""
	        self.mutex.acquire()
	        n = not self._qsize()
	        self.mutex.release()
	        return n

	    def full(self):
	        """队列是否已满(不可靠!)."""
	        self.mutex.acquire()
	        n = 0 < self.maxsize == self._qsize()
	        self.mutex.release()
	        return n

	    def put(self, item, block=True, timeout=None):
	        """添加元素.

	        如果可选参数block为True并且timeout参数为None(默认), 为阻塞型put().
	        如果timeout是正数, 会阻塞timeout时间并引发Queue.Full异常.
	        如果block为False为非阻塞put
	        """
	        self.not_full.acquire()
	        try:
	            if self.maxsize > 0:
	                if not block:
	                    if self._qsize() == self.maxsize:
	                        raise Full
	                elif timeout is None:
	                    while self._qsize() == self.maxsize:
	                        self.not_full.wait()
	                elif timeout < 0:
	                    raise ValueError("'timeout' must be a non-negative number")
	                else:
	                    endtime = _time() + timeout
	                    while self._qsize() == self.maxsize:
	                        remaining = endtime - _time()
	                        if remaining <= 0.0:
	                            raise Full
	                        self.not_full.wait(remaining)

	            self._put(item)
	            self.unfinished_tasks += 1
	            self.not_empty.notify()
	        finally:
	            self.not_full.release()

	    def put_nowait(self, item):
	        """
	        非阻塞put
	        其实就是将put第二个参数block设为False
	        """
	        return self.put(item, False)

	    def get(self, block=True, timeout=None):
	        """移除列队元素并将元素返回.

	        block = True为阻塞函数, block = False为非阻塞函数. 可能返回Queue.Empty异常
	        """
	        self.not_empty.acquire()
	        try:
	            if not block:
	                if not self._qsize():
	                    raise Empty
	            elif timeout is None:
	                while not self._qsize():
	                    self.not_empty.wait()
	            elif timeout < 0:
	                raise ValueError("'timeout' must be a non-negative number")
	            else:
	                endtime = _time() + timeout
	                while not self._qsize():
	                    remaining = endtime - _time()
	                    if remaining <= 0.0:
	                        raise Empty
	                    self.not_empty.wait(remaining)
	            item = self._get()
	            self.not_full.notify()
	            return item
	        finally:
	            self.not_empty.release()

	    def get_nowait(self):
	        """
	        非阻塞get()
	        也即是get()第二个参数为False
	        """
	        return self.get(False)

	    # Override these methods to implement other queue organizations
	    # (e.g. stack or priority queue).
	    # These will only be called with appropriate locks held

	    # 初始化队列表示
	    def _init(self, maxsize):
	        self.queue = deque()        # 将queue初始化为一个空的deque对象

	    def _qsize(self, len=len):      # 队列长度
	        return len(self.queue)

	    # Put a new item in the queue
	    def _put(self, item):
	        self.queue.append(item)

	    # Get an item from the queue
	    def _get(self):
	        return self.queue.popleft()


	class PriorityQueue(Queue):
	    """
	    继承Queue
	    构造一个优先级队列
	    maxsize设置队列大小的上界, 如果插入数据时, 达到上界会发生阻塞, 直到队列可以放入数据.
	    当maxsize小于或者等于0, 表示不限制队列的大小(默认).
	    优先级队列中, 最小值被最先取出
	    """

	    def _init(self, maxsize):
	        self.queue = []

	    def _qsize(self, len=len):
	        return len(self.queue)

	    def _put(self, item, heappush=heapq.heappush):
	        heappush(self.queue, item)

	    def _get(self, heappop=heapq.heappop):
	        return heappop(self.queue)


	class LifoQueue(Queue):
	    """
	    构造一LIFO(先进后出)队列
	    maxsize设置队列大小的上界, 如果插入数据时, 达到上界会发生阻塞, 直到队列可以放入数据.
	    当maxsize小于或者等于0, 表示不限制队列的大小(默认)
	    """
	    def _init(self, maxsize):
	        self.queue = []

	    def _qsize(self, len=len):
	        return len(self.queue)

	    def _put(self, item):
	        self.queue.append(item)

	    def _get(self):
	        return self.queue.pop()     # 与Queue相比，仅仅是 将popleft()改成了pop()


如下实例：

	import Queue
	import threading
	import random
	import time

	q = Queue.Queue(10)


	class Producer(threading.Thread):
	    def __init__(self):
	        super(Producer, self).__init__()

	    def run(self):
	        while not q.full():
	            # 一下子put一堆数据(10个)后生产者join()等待后退出，接下来等消费者消费
	            item = random.randint(1, 100)
	            q.put(item, block=True, timeout=3)
	            print 'size', q.qsize(), '-->', item

	        print 'over'


	class Customer_e(threading.Thread):
	    def __init__(self):
	        super(Customer_e, self).__init__()

	    def run(self):
	        # 消费者缓慢消费直到empty()后退出
	        while not q.empty():
	            time.sleep(1)
	            print 'value', q.get()
	            q.task_done()

	def main():
	    p = Producer()
	    p.start()
	    c = Customer_e()
	    c.start()
	    p.join()
	    c.join()
	    # do other things..
	    print 'all over!'

	if __name__ == '__main__':
	    main()

输出：

	size 1 --> 66
	size 2 --> 6
	size 3 --> 64
	size 4 --> 68
	size 5 --> 59
	size 6 --> 13
	size 7 --> 84
	size 8 --> 16
	size 9 --> 5
	size 10 --> 59
	over
	value 66
	value 6
	value 64
	value 68
	value 59
	value 13
	value 84
	value 16
	value 5
	value 59
	all over!

举一个爬虫的例子，爬豆瓣电影 http://movie.douban.com/top250?start=0, 例子参考http://www.jianshu.com/p/544d406e0875


	import urllib2
	import re
	import Queue
	import threading
	import time
	import sys

	reload(sys)
	sys.setdefaultencoding('utf-8')

	_DATA = []
	FILE_LOCK = threading.Lock()    # Lock
	SHARE_Q = Queue.Queue()         # 构造一个不限制大小的的队列
	_WORKER_THREAD_NUM = 4          # 设置线程的个数


	class Mythread(threading.Thread):
	    def __init__(self, func, thread_name=''):
	        super(Mythread, self).__init__(name=thread_name)
	        self.func = func        # 传入线程函数逻辑

	    def run(self):
	        self.func()


	def wroker():
	    global SHARE_Q
	    while not SHARE_Q.empty():
	        url = SHARE_Q.get()
	        page = get_page(url)
	        find_title(page)        # 获得当前页面的电影名
	        time.sleep(1)
	        SHARE_Q.task_done()


	def get_page(url):
	    try:
	        page = urllib2.urlopen(url).read().decode('utf-8')
	        return page
	    except urllib2.URLError, e:
	        pass


	def find_title(page):
	    temp_data = []
	    movie_items = re.findall(r'<span.*?class="title">(.*?)</span>', page, re.S)
	    for index, item in enumerate(movie_items) :
	        if item.find("&nbsp") == -1:
	            temp_data.append(item)
	    _DATA.append(temp_data)



	def main():
	    global SHARE_Q
	    threads = []
	    douban_url = "http://movie.douban.com/top250?start={page}&filter=&type="
	    for index in range(10):
	        SHARE_Q.put(douban_url.format(page=index * 25))

	    for i in range(_WORKER_THREAD_NUM):
	        t = Mythread(wroker, str(i))
	        t.start()
	        threads.append(t)

	    for t in threads:
	        t.join(3)

	    # 等待所有任务完成
	    SHARE_Q.join()

	    with open("movie.txt", "w+") as my_file :
	        for page in _DATA :
	            for movie_name in page:
	                my_file.write(movie_name + "\n")

	    print "Spider Successful!!!"

	if __name__ == '__main__':
	    s = time.time()
	    main()
	    print 'use time:', time.time() - s


