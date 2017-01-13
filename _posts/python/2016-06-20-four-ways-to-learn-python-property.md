---               
layout: post                 
title: "Python property四部曲"
description: ""
category: "python"
tags: [property]
---

Python property的学习，四步搞定。

# 1.初级：只当做属性

加个装饰器`@property`将类方法变成类属性，但是试图修改该属性则发一个`AttributeError`错误

	class Person:
	    def __init__(self):
	        self._fee = None
	
	    @property
	    def do_something(self):
	        return None
	
# 2.入门：能修改属性
	
	class Person:
	    def __init__(self):
	        self._fee = None
	
	    def get_fee(self):
	        return self._fee
	
	    def set_fee(self, v):
	        self._fee = v
	
	p = Person()        # None
	print p.get_fee()
	p.set_fee(100)
	print p.get_fee()   # 100

# 3.进级：简化：使用property函数设置属性

	class Person:
	    def __init__(self):
	        self._fee = None
	
	    def get_fee(self):
	        return self._fee
	
	    def set_fee(self, v):
	        self._fee = v
	
	    # 注意一致性，fee, _fee
	    fee = property(get_fee, set_fee)
	
	p = Person()
	print p.fee     # None
	p.fee = 100
	print p.fee     # 100

# 4.高级：@property装饰器

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/5BD6AFEE-C01F-4032-B8F5-FE03865E4EFE.png)

