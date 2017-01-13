---
layout: post
title: "Python __get__, __getattr__和__getattribute区别"
description: "Python __get__, __getattr__和__getattribute区别"
category: "python"
tags: [python]
---

在看[tomorrow](https://github.com/madisonmay/Tomorrow)发现一段代码如下：

    class Tomorrow():

        def __init__(self, future, timeout):
            self._future = future
            self._timeout = timeout

        def __getattr__(self, name):
            result = self._wait()
            return result.__getattribute__(name)

        def _wait(self):
            return self._future.result(self._timeout)

在`__getattr__`方法中又用到了`__getattribute__`方法，遂生疑，决定弄清楚它们之间的区别。

首先我测试代码如下：


    class Ts(object):
        def __init__(self, x, y):
            self.x = x
            self.y = y

        def method(self):
            pass

        def __getattr__(self, item):
            return item

        def __getattribute__(self, item):
            return item+'***'


    if __name__ == '__main__':
        t = Ts(100, 20)
        m = t.y + t.x
        print m
        print t.y
        print t.name

        t.name = 'JJJ'
        print t.name

这两个方法都有，在测试过程中发现，**`__getattribute__`方法会优先调用，且调用任何实例属性和方法都会调用`__getattribute__`,看的出来该方法其实就是
属性调用。**

如下测试结果：

    y***x***
    y***
    name***
    name***


如果将`__getattribute__`这段代码注释掉，则测试结果如下：

    120
    20
    name
    JJJ

发现**`__getattr__`只作用于不存在的属性。**

两种测试后总结如下：

1. `__getattr__(self, name)`:找不到attribute的时候，会调用getattr，返回一个值或AttributeError异常。 
2. `__getattribute__()`:在每次引用属性或方法名称时 Python 都调用它（特殊方法名称除外），不管属性或方法是否存在，也不管是否进行属性赋值等。

那么`__get__`怎么用呢？`object.__get__(self, instance, owner)`:如果class定义了它，则这个class就可以称为descriptor。owner是所有者的类，instance是访问descriptor的实例，如果不是通过实例访问，而是通过类访问的话，instance则为None。（descriptor的实例自己访问自己是不会触发__get__，而会触发__call__，只有descriptor作为其它类的属性才有意义。)

如下测试：


    class Ts(object):
        def __get__(self, instance, owner):
            print '__get__', instance, owner
            return self

        def __call__(self, *args, **kwargs):
            print '__call__', self
            return self


    class TTs(object):
        t = Ts()        # t作为TTs的属性

    if __name__ == '__main__':
        ts = Ts()
        print ts()
        print '*' * 30
        tts = TTs()
        print tts.t

测试结果：

    __call__ <__main__.Ts object at 0x10dc91690>
    <__main__.Ts object at 0x10dc91690>
    ******************************
    __get__ <__main__.TTs object at 0x10dc91710> <class '__main__.TTs'>
    <__main__.Ts object at 0x10dc91650>


`__getattr__`常用于**代理模式**

代理模式的实现有两种方式：

- 简单代理， 代理类中定义要代理的类属性
- `__getatt__`: 魔法方法实现代理

对于简单的代理，主要用于代理属性比较少的方案，如下：


	class A(object):
	    def foo(self): pass
	
	
	class B(object):
	    def __init__(self):
	        self.a = A()
	
	    def bar(self): pass
	    def foo(self): return self.a.foo()

如果有大量的方法需要代理， 那么使用 `__getattr__()` 方法或许或更好些：

	
	class A(object):
	    def foo(self): pass
	
	
	class B(object):
	    def __init__(self):
	        self.a = A()
	
	    def bar(self): pass
	
	    def __getattr__(self, name):
	        """这个方法在访问的attribute不存在的时候被调用"""
	        return getattr(self.a, name)
	
	b = B()
	b.bar()      # Calls B.bar() (exists on B)
	b.foo()      # Calls B.__getattr__('spam') and delegates to A.spam
	
如下常用的代理模式：

	
	class Proxy(object):
	    def __init__(self, obj):
	        self._obj = obj
	
	    def __getattr__(self, item):
	        return getattr(self._obj, item)
	
	    def __setattr__(self, key, value):
	        """
	        __setattr__() 和 __delattr__() 需要额外的魔法来区分代理实例和被代理实例 _obj 的属性。
	        一个通常的约定是只代理那些不以下划线 _ 开头的属性(代理类只暴露被代理类的公共属性)。
	        """
	        if key.startswith('_'):
	            super(Proxy, self).__setattr__(key, value)
	        else:
	            setattr(self._obj, key, value)
	
	    def __delattr__(self, item):
	        if item.startswith('_'):
	            super(Proxy, self).__delattr__(item)
	        else:
	            delattr(self._obj, item)
	
	
	class Spam(object):
	    def __init__(self, x):
	        self.x = x
	
	    def bar(self, y):
	        return 'Spam.bar', self.x, y
	
	
	s = Spam(2)
	p = Proxy(s)
	
	print p.x
	print p.bar(3)
	p.x = 100
	print p.x
	del p.x
	
	
# 参考

- [《Python Cookbook》8.15 属性的代理访问](http://python3-cookbook.readthedocs.org/zh_CN/latest/c08/p15_delegating_attribute_access.html)

# 修订历史

- 2016-02-16：初稿
- 2016-02-19：添加代理模式的应用
