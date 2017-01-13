---
layout: post
title: "python网络编程（三）python socket"
description: "python网络编程（三）python socket"
category: "Python"
tags: [Python]
---

<p>python socket是对linux socket的一个接口封装，入门版本可参考这个<a href="http://www.oschina.net/question/12_76126">Python 的 Socket 编程教程</a>.</p>

<p>然后给自己10分钟去入门吧.....</p>

<p>Python 提供了两个基本的 socket 模块。</p>

<p>第一个是 Socket，它提供了标准的 BSD Sockets API。</p>

<p>第二个是 SocketServer， 它提供了服务器中心类，可以简化网络服务器的开发。</p>

<p>那么今天先总结Socket吧。</p>

<p>从上一节明确了socket执行流程，那么在python中也无异如此，下面列出python中socket函数一览表吧：</p>

<!--more-->

<p><strong>服务端socket函数：</strong></p>

<p><code>s.bind(address)</code>: 将套接字绑定到地址, 在AF_INET下,以元组（host,port）的形式表示地址.</p>

<p><code>s.listen(backlog)</code>: 开始监听TCP传入连接。backlog指定在拒绝连接之前，操作系统可以挂起的最大连接数量。该值至少为1，大部分应用程序设为5就可以了。</p>

<p><code>s.accept()</code>: 接受TCP连接并返回（conn,address）,其中conn是新的套接字对象，可以用来接收和发送数据。address是连接客户端的地址。</p>

<p><strong>客户端socket函数:</strong></p>

<p><code>s.connect(address)</code>: 连接到address处的套接字。一般address的格式为元组（hostname,port），如果连接出错，返回socket.error错误。</p>

<p><code>s.connect_ex(adddress)</code>: 功能与connect(address)相同，但是成功返回0，失败返回errno的值。</p>

<p><strong>公共socket函数:</strong></p>

<p><code>s.recv(bufsize[,flag])</code>:接受TCP套接字的数据。数据以字符串形式返回，bufsize指定要接收的最大数据量。flag提供有关消息的其他信息，通常可以忽略。</p>

<p><code>s.send(string[,flag])</code>:发送TCP数据。将string中的数据发送到连接的套接字。返回值是要发送的字节数量，该数量可能小于string的字节大小。</p>

<p><code>s.sendall(string[,flag])</code>:完整发送TCP数据。将string中的数据发送到连接的套接字，但在返回之前会尝试发送所有数据。成功返回None，失败则抛出异常。</p>

<p><code>s.recvfrom(bufsize[.flag])</code>:接受UDP套接字的数据。与recv()类似，但返回值是（data,address）。其中data是包含接收数据的字符串，address是发送数据的套接字地址。</p>

<p><code>s.sendto(string[,flag],address)</code>:发送UDP数据。将数据发送到套接字，address是形式为（ipaddr，port）的元组，指定远程地址。返回值是发送的字节数。</p>

<p><code>s.close()</code>:关闭套接字。</p>

<p><code>s.getpeername()</code>:返回连接套接字的远程地址。返回值通常是元组（ipaddr,port）。</p>

<p><code>s.getsockname()</code>:返回套接字自己的地址。通常是一个元组(ipaddr,port)</p>

<p><code>s.setsockopt(level,optname,value)</code>:设置给定套接字选项的值。</p>

<p><code>s.getsockopt(level,optname[.buflen])</code>:返回套接字选项的值。</p>

<p><code>s.settimeout(timeout)</code>:设置套接字操作的超时期，timeout是一个浮点数，单位是秒。值为None表示没有超时期。一般，超时期应该在刚创建套接字时设置，因为它们可能用于连接的操作（如connect()）</p>

<p><code>s.gettimeout()</code>: 返回当前超时期的值，单位是秒，如果没有设置超时期，则返回None。</p>

<p><code>s.fileno()</code>:返回套接字的文件描述符。</p>

<p><code>s.setblocking(flag)</code>:如果flag为0，则将套接字设为非阻塞模式，否则将套接字设为阻塞模式（默认值）。非阻塞模式下，如果调用recv()没有发现任何数据，或send()调用无法立即发送数据，那么将引起socket.error异常。</p>

<p><code>s.makefile()</code>:创建一个与该套接字相关连的文件</p>

<p><strong>用Python Socket实现多线程简陋的多人聊天室：</strong></p>

<pre><code># coding=utf-8
# 服务器端
__author__ = 'beginman'
import socket
import threading

conn_list = []  # 所有的已连接的TCP列表
conn_list_msg = []  # tcp msg列表
#所有已连接的TCP消息分发
def TaskHandler():
    while conn_list_msg:
        for i in conn_list_msg:
            for c in conn_list:
                c.sendall(i)
            conn_list_msg.remove(i)



#Socket服务
class SocketServer(object):
    conn = None

    def __init__(self, ip, port=8923):  #Use a port number larger than 1024 (recommended)
        self.ip = ip
        self.port = port

        self.socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_STREAM)
        try:
            self.socket.bind((self.ip, self.port))
            print 'IP:%s,  PORT:%s' % (ip, port)
            self.socket.listen(10)

        except Exception, e:
            print 'invaild ip&amp;port', e
            pass


    @staticmethod
    def dataHandler(conn):
        #接受TCP套接字的数据
        while 1:
            rec_msg = conn.recv(1024)
            print rec_msg
            #完整发送TCP数据
            conn_list_msg.append(rec_msg)

            # conn.sendall(rec_msg)
            TaskHandler()
        conn.close()


    #socket运行器
    @property
    def run(self):
        while 1:
            conn, addr = self.socket.accept()
            print '已连接客户端:', addr
            if conn:
                #添加连接列表中
                conn_list.append(conn)
                #多线程启动单个TCP连接
                ThreadServer(SocketServer.dataHandler, conn).start()

        self.socket.close()


#多线程处理socket连接
class ThreadServer(threading.Thread):
    def __init__(self, func, *args):
        self.func = func
        self.args = args
        threading.Thread.__init__(self)

    def run(self):
        apply(self.func, self.args)



if __name__ == '__main__':
    server = SocketServer('127.0.0.1').run
</code></pre>

<p>下面是客户端的实现：</p>

<pre><code># coding=utf-8
__author__ = 'beginman'
import socket
import datetime

class SocketClient(object):
    def __init__(self, ip, port=8923):
        self.ip = ip
        self.port = port
        self.socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_STREAM)
        self.name = ''
        #注册姓名
        self.register()
        try:
            self.socket.connect((self.ip, self.port))
            print '%s已连接服务器 %s:%s' % (self.name, ip, port)
        except Exception, e:
            print 'invaild port:%s  ip:%s' % (ip, port)
            print 'error', e


    #注册姓名
    def register(self):
        while not self.name:
            self.name = raw_input('请输入您的姓名：').strip()


    #客户端socket启动器
    @property
    def run(self):
        while 1:
            try:
                msg = raw_input('发送消息:').strip()
                if msg:
                    now = datetime.datetime.now().strftime('%m-%d %H:%M:%S')
                    msg = '[%s %s]:%s' % (now, self.name, msg)
                    self.send(msg)
                    print self.read()
                else:
                    print self.read()
            except Exception, e:
                print 'error', e
        self.close()

    def send(self, msg):
        self.socket.sendall(msg)

    def read(self):
        msg = self.socket.recv(1024)
        return msg

    def close(self):
        self.socket.close()

if __name__ == '__main__':
    SocketClient('127.0.0.1').run
</code></pre>

<p>代码比较简单，就不在啰嗦了。</p>

<pre><code>➜  socket_test  python socketServer.py
IP:127.0.0.1,  PORT:8923
已连接客户端: ('127.0.0.1', 62421)
已连接客户端: ('127.0.0.1', 62422)
[12-11 19:03:01 李四]:你好
[12-11 19:04:08 李四]:shan
[12-11 19:04:09 李四]:s
[12-11 19:04:10 李四]:fadsfa
[12-11 19:04:20 张三]:haod
[12-11 19:04:23 李四]:sss

➜  socket_test  python socketClient.py
请输入您的姓名：张三  
张三已连接服务器 127.0.0.1:8923
发送消息:
[12-11 19:03:01 李四]:你好
发送消息:

[12-11 19:04:08 李四]:shan
发送消息:[12-11 19:04:09 李四]:s
发送消息:haod

➜  socket_test  python socketClient.py
请输入您的姓名：李四
李四已连接服务器 127.0.0.1:8923
发送消息:你好
[12-11 19:03:01 李四]:你好
发送消息:shan
[12-11 19:04:08 李四]:shan
发送消息:s
[12-11 19:04:09 李四]:s
</code></pre>

<p>代码有些bug，实现的还是很简陋的，就当练手吧。</p>
