---
layout: post
title: "python网络编程（四）python SocketServer"
description: "python网络编程（四）python SocketServer"
category: "Python"
tags: [Python]
---

<p>SocketServer模块简化了编写网络服务程序的任务。同时SocketServer模块也是Python标准库中很多服务器框架的基础。</p>

<p><strong>服务类：</strong></p>

<p>SocketServer提供了5个基本的服务类：</p>

<p><code>BaseServer</code>: 基础类，由于下面四个网络服务类的继承</p>

<p><code>TCPServer</code>:针对TCP套接字流</p>

<p><code>UDPServer</code>:针对UDP数据报套接字</p>

<p><code>UnixStreamServer</code>:处理流式套接字,与TCPServer配合</p>

<p><code>UnixDatagramServer</code>:处理数据报套接字,与UDPServer配合</p>

<!--more-->

<p>它们继承关系如下：</p>

<pre><code>+------------+
| BaseServer |
+------------+
    |
    v
+-----------+        +------------------+
| TCPServer |-------&gt;| UnixStreamServer |
+-----------+        +------------------+
    |
    v
+-----------+        +--------------------+
| UDPServer |-------&gt;| UnixDatagramServer |
+-----------+        +--------------------+
</code></pre>

<p><strong>异步处理类：</strong></p>

<p>这个四个服务类都是同步处理请求的。一个请求没处理完不能处理下一个请求。要想支持异步模型，可以利用多继承让server类继承ForkingMixIn 或 ThreadingMixIn。</p>

<p><code>ForkingMixIn</code>: 利用<strong>多进程</strong>（分叉）实现异步。(Mix-in class to handle each request in a new process)</p>

<p><code>ThreadingMixIn</code>: 利用<strong>多线程</strong>实现异步。(Mix-in class to handle each request in a new thread)</p>

<p><strong>请求处理类：</strong></p>

<p>要实现一项服务，还必须派生一个handler请求处理类，并重写父类的handle()方法。handle方法就是用来专门是处理请求的。该模块是通过服务类和请求处理类组合来处理请求的。</p>

<p>SocketServer模块提供的请求处理类有<code>BaseRequestHandler</code>，以及它的派生类<code>StreamRequestHandler</code>和<code>DatagramRequestHandler</code>。从名字看出可以一个处理流式套接字，一个处理数据报套接字。</p>

<p><strong>一个简单的例子</strong></p>

<pre><code>#服务器端
    # coding=utf-8
#SocketServer
__author__ = 'fang'
from SocketServer import TCPServer,StreamRequestHandler,\
    ThreadingMixIn, ForkingMixIn



#定义请求处理类
class Handler(StreamRequestHandler):
    def handle(self):
        addr = self.request.getpeername()
        print 'connection:', addr
        while 1:
            self.request.sendall(self.request.recv(1024))


#实例化服务类对象
server = TCPServer(
    server_address=('127.0.0.1', 8123),     # address
    RequestHandlerClass=Handler             # 请求类
)

#开启服务
server.serve_forever()
</code></pre>

<p>客户端：还是简单的socket连接：</p>

<pre><code># coding=utf-8
__author__ = 'fang'
import socket

def socketClient():
    so = socket.socket()
    so.connect(('127.0.0.1', 8123))
    # so.close()
    while 1:
        so.sendall(raw_input('msg'))
        print so.recv(1024)

if __name__ == '__main__':
    socketClient()
</code></pre>

<p><strong>一个多线程连接的例子</strong></p>

<p>客户端一样，服务器如下：</p>

<pre><code># coding=utf-8
#SocketServer
__author__ = 'fang'
from SocketServer import TCPServer,StreamRequestHandler,\
    ThreadingMixIn, ForkingMixIn


#定义基于多线程的服务类
class Server(ThreadingMixIn, TCPServer):
    pass


#定义请求处理类
class Handler(StreamRequestHandler):
    def handle(self):
        addr = self.request.getpeername()
        print 'connection:', addr
        while 1:
            self.request.sendall(self.request.recv(1024))


#实例化服务类对象
server = Server(
    server_address=('127.0.0.1', 8123),     # address
    RequestHandlerClass=Handler             # 请求类
)

#开启服务
server.serve_forever()
</code></pre>

<p><strong>源码分析：</strong></p>

<p>SocketServer源码仅700多行，那么从baseserver分析开始，其他的都是继承于此，就不贴出全部了。</p>

<pre><code>"""普通的Socket服务类.

socket服务:

- address family:
        - AF_INET{,6}: IP (Internet Protocol) sockets (default)
        - AF_UNIX: Unix domain sockets
        - others, e.g. AF_DECNET are conceivable (see &lt;socket.h&gt;
- socket type:
        - SOCK_STREAM (reliable stream, e.g. TCP)
        - SOCK_DGRAM (datagrams, e.g. UDP)

请求服务类 (including socket-based):

- 客户端地址验证之前进一步查看请求
        (实际上是一个请求处理的钩子在请求之前，例如logging)
- 如何处理多个请求:
        - synchronous (同步：同一时间只能有一个请求)
        - forking (分叉：每个请求分配一个新的进程)
        - threading (线程：每个请求分配一个新的线程)



五个类的继承关系如下:

        +------------+
        | BaseServer |
        +------------+
              |
              v
        +-----------+        +------------------+
        | TCPServer |-------&gt;| UnixStreamServer |
        +-----------+        +------------------+
              |
              v
        +-----------+        +--------------------+
        | UDPServer |-------&gt;| UnixDatagramServer |
        +-----------+        +--------------------+



通过ForkingMixIn创建进程，通过ThreadingMixIn创建线程，如下实例：

        class ThreadingTCPServer(ThreadingMixIn, TCPServer): pass

"""

__version__ = "0.4"


import socket
import select
import sys
import os
import errno
try:
    import threading
except ImportError:
    import dummy_threading as threading

__all__ = ["TCPServer","UDPServer","ForkingUDPServer","ForkingTCPServer",
           "ThreadingUDPServer","ThreadingTCPServer","BaseRequestHandler",
           "StreamRequestHandler","DatagramRequestHandler",
           "ThreadingMixIn", "ForkingMixIn"]

#family参数代表地址家族，比较常用的为AF_INET或AF_UNIX。
#AF_UNIX用于同一台机器上的进程间通信，AF_INET对于IPV4协议的TCP和UDP 。           
if hasattr(socket, "AF_UNIX"):
    __all__.extend(["UnixStreamServer","UnixDatagramServer",
                    "ThreadingUnixStreamServer",
                    "ThreadingUnixDatagramServer"])

def _eintr_retry(func, *args):
    """重新启动系统调用EINTR中断"""
    while True:
        try:
            return func(*args)
        except (OSError, select.error) as e:
            if e.args[0] != errno.EINTR:
                raise

class BaseServer:

    """服务类的基类.

    调用方法:

    - __init__(server_address, RequestHandlerClass)
    - serve_forever(poll_interval=0.5)
    - shutdown()
    - handle_request()  # if you do not use serve_forever()
    - fileno() -&gt; int   # for select()

    可以被重写的方法:

    - server_bind()
    - server_activate()
    - get_request() -&gt; request, client_address
    - handle_timeout()
    - verify_request(request, client_address)
    - server_close()
    - process_request(request, client_address)
    - shutdown_request(request)
    - close_request(request)
    - handle_error()

    派生类(derived classes)方法:

    - finish_request(request, client_address)

    可以由派生类或重写类变量实例:

    - timeout
    - address_family
    - socket_type
    - allow_reuse_address

    实例变量:

    - RequestHandlerClass
    - socket

    """

    timeout = None

    def __init__(self, server_address, RequestHandlerClass):
        """初始化，能被扩展但不要重写."""
        self.server_address = server_address                # 地址元祖如('127.0.0.1', 8123)
        self.RequestHandlerClass = RequestHandlerClass      # 请求处理类
        self.__is_shut_down = threading.Event()             # 多线程通信机制
        self.__shutdown_request = False

    def server_activate(self):
        """通过构造函数激活服务器.可被重写."""
        pass

    def serve_forever(self, poll_interval=0.5):
        """在一个时间段内处理一个请求直到关闭.

        处理请求，直到一个明确的shutdown()请求。每poll_interval秒轮询一次shutdown。
        忽略self.timeout。如果你需要做周期性的任务，建议放置在其他线程。
        """

        self.__is_shut_down.clear()
        #Event是Python多线程通信的最简单的机制之一.一个线程标识一个事件,其他线程一直处于等待状态。
        #一个事件对象管理一个内部标示符,这个标示符可以通过set()方法设为True,通过clear()方法重新设为False,wait()方法则使线程一直处于阻塞状态,直到标示符变为True
        #也就是说我们可以通过 以上三种方法来多个控制线程的行为。
        try:
            while not self.__shutdown_request:
                #考虑使用其他文件描述符或者连接socket去唤醒它取代轮询
                #轮询减少在其他时间我们响应了关闭请求CPU。
                r, w, e = _eintr_retry(select.select, [self], [], [],
                                       poll_interval)
                if self in r:
                    self._handle_request_noblock()
        finally:
            self.__shutdown_request = False
            self.__is_shut_down.set()

    def shutdown(self):
        """终止serve_forever的循环.

        阻塞直到循环结束. 当serve_forever()方法正运行在另外的线程中必须调用它，否则会发生死锁.
        """
        self.__shutdown_request = True
        self.__is_shut_down.wait()


    # - handle_request() 是顶层调用.  它调用select,get_request(),verify_request()和process_request()
    # - get_request() 不同于流式和报文socket
    # - process_request() 产生进程的位置，或者产生线程去结束请求
    # - finish_request() 请求处理类的实例，此构造都将处理请求本身

    def handle_request(self):
        """处理一个请求, 可能阻塞.考虑self.timeout."""
        # Support people who used socket.settimeout() to escape
        # handle_request before self.timeout was available.
        timeout = self.socket.gettimeout()  # 返回当前超时期的值，如果没有设置超时期，则返回None
        if timeout is None:
            timeout = self.timeout
        elif self.timeout is not None:
            timeout = min(timeout, self.timeout)
        fd_sets = _eintr_retry(select.select, [self], [], [], timeout)
        if not fd_sets[0]:
            self.handle_timeout()
            return
        self._handle_request_noblock()

    def _handle_request_noblock(self):
        """处理一个请求, 非阻塞."""
        try:
            request, client_address = self.get_request()
        except socket.error:
            return
        if self.verify_request(request, client_address):
            try:
                self.process_request(request, client_address)
            except:
                self.handle_error(request, client_address)
                self.shutdown_request(request)

    def handle_timeout(self):
        """超时处理。默认对于forking服务器是收集退出的子进程状态，threading服务器则什么都不做"""
        pass

    def verify_request(self, request, client_address):
        """
        返回一个布尔值，如果该值为True ，则该请求将被处理，反之请求将被拒绝。
        此功能可以重写来实现对服务器的访问控制。
        默认的实现始终返回True。client_address可以限定客户端，比如只处理指定ip区间的请求。 常用。
        """
        return True

    def process_request(self, request, client_address):
        """调用finish_request.被 ForkingMixIn and ThreadingMixIn重写
        如果用户提供handle()方法抛出异常，将调用服务器的handle_error()方法。
        如果self.timeout内没有请求收到， 将调用handle_timeout()并返回handle_request()。

        """
        self.finish_request(request, client_address)
        self.shutdown_request(request)

    def server_close(self):
        """关闭并清理server."""
        pass

    def finish_request(self, request, client_address):
        """通过请求类的实例结束请求，实际处理RequestHandlerClass发起的请求并调用其handle()方法。 常用."""
        self.RequestHandlerClass(request, client_address, self)

    def shutdown_request(self, request):
        """关闭结束一个单独的请求."""
        self.close_request(request)

    def close_request(self, request):
        pass

    def handle_error(self, request, client_address):
        """优雅的操作错误，可重写，默认打印异常并继续
        """
        print '-'*40
        print 'Exception happened during processing of request from',
        print client_address
        import traceback
        traceback.print_exc() # XXX But this goes to stderr!
        print '-'*40
</code></pre>

<p>参考：</p>

<p><a href="http://blog.csdn.net/candcplusplus/article/details/9166255">利用Python的SocketServer框架编写网络服务程序</a></p>
