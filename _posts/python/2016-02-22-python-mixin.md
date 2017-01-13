---
layout: post
title: "Python Mixin 扩展类功能"
description: "Python Mixin 扩展类功能"
category: "python"
tags: [python]
---

mixin是 mix in的意思，就是**混入，可以就任意一个对象的全部或部分属性拷贝到另一个对象上。**，在很多将设计模式中都有涉及。在 SocketServer.py中，常见Mixins模式：

	class ThreadingMixIn:
	    """Mix-in class to handle each request in a new thread."""
	    daemon_threads = False
	
	    def process_request_thread(self, request, client_address):
	        # ...
	        pass
	
	    def process_request(self, request, client_address):
	        # ...
	        pass
	
	class ForkingUDPServer(ForkingMixIn, UDPServer): pass
	class ForkingTCPServer(ForkingMixIn, TCPServer): pass
	

对于Mixin模式可总结：

- 这些类单独使用起来没有任何意义,也就是**混入类不能直接被实例化使用**
- Mixin类是单一职责
- **它们是用来通过多继承来和其他映射对象混入使用的**
- 混入类没有自己的状态信息，也就是说它们并没有定义`__init__()` 方法，并且没有实例属性
- 宿主类(如上ForkingTCPServer)的主体逻辑不会因为去掉 混入类(Mixin) 而受到影响，同时也不存在超类方法调用（super）以避免引入 MRO 查找顺序问题
- 还有一种实现混入类的方式就是使用类装饰器

# 参考
- [8.18 利用Mixins扩展类功能](http://python3-cookbook.readthedocs.org/zh_CN/latest/c08/p18_extending_classes_with_mixins.html)
- [Mixin是什么概念?](https://www.zhihu.com/question/20778853)
