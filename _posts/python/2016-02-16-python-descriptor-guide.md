---
layout: post
title: "Python描述器的理解"
description: "Python描述器的理解"
category: "python"
tags: [python]
---

大概几小时前总结了[Python __get__, __getattr__和__getattribute区别](http://beginman.cn/python/2016/02/16/python-differnet-with-get-getattr-and-getattribute/),大概理解了`__getattr__`和`__getattribute__`的区别。在理解`__get__`时，其实涉及
到更加复杂的知识点，那就是**描述器(descriptor)**的概念。于是从[**1. Python描述器引导(翻译)**](http://pyzh.readthedocs.org/en/latest/Descriptor-HOW-TO-Guide.html#python)这篇文章开始学习。于是有了下面对这篇文章知识点的理解，简单说这是一篇对上篇文章的总结。

总结大纲如下：

1. 什么是描述器？
2. 描述器的具体作用？
3. python属性的访问控制
4. 描述器协议
5. 描述器的使用
    - 属性
    - 函数和方法
    - 静态方法和类方法
6. 描述器的应用

# 一.描述器
描述器(descripor)也可称为描述符，我在google这个词发现基本都涉及python,可能想生成器，迭代器一样，再搞一个描述器，我猜想基本同文件描述符，是一个用于表述指向xxx的引用的抽象化概念。

我看到这个博客[Python 黑魔法 --- 描述器（descriptor）](http://www.jianshu.com/p/250f0d305c35)称之为**黑魔法**。可以通过迭代器来理解描述器：

>迭代器是实现了`__iter__`迭代协议方法的对象， 那么描述器则是实现了`__get__`,`__set__`,`__delete__`描述协议方法的对象。

# 二.描述器的作用
作用就是：对象属性的访问控制。

像属性(property), 方法(bound和unbound method), 静态方法和类方法都是基于描述器协议的。

# 三.Python属性的访问控制

>默认对属性的访问控制是从对象的字典里面(`__dict__`)中获取(get), 设置(set)和删除(delete)它))

如`a.x`的查找顺序：

1. 查找`a.__dict__['x']`
2. 查找`type(a).__dict__['x']`
3. 查找`type(a)` 的父类(不包括元类(metaclass)).

如下测试：

    class Ts(object):
        def __init__(self):
            self.a = 100
            self.b = 200


    class TTs(object):
        def __init__(self):
            self.x = 1000
            self.y = 100
            self.z = 10

        x = Ts()
        y = 10
        a = 1


    if __name__ == '__main__':
        t = TTs()
        print t.__dict__
        print type(t)
        print type(t).__dict__
        print type(type(t))
        print t.x
        print t.y
        print t.a


实例t字典集合`__dict__`包含的实例属性，然后查找t.x, t.y, t.a则依照上述的查找顺序，结果如下：


    {'y': 100, 'x': 1000, 'z': 10}
    <class '__main__.TTs'>
    {'a': 1, '__module__': '__main__', '__dict__': <attribute '__dict__' of 'TTs' objects>, 'y': 10, 'x': <__main__.Ts object at 0x102ca0710>, '__weakref__': <attribute '__weakref__' of 'TTs' objects>, '__doc__': None, '__init__': <function __init__ at 0x102bbc2a8>}
    <type 'type'>
    1000
    100
    1

**如果查找到的值是一个描述器, Python就会调用描述器的方法来重写默认的控制行为,注意, 只有在新式类中时描述器才会起作用。(新式类是继承自 type 或者 object 的类)**

如下我们在Ts类中定义描述器：


    class Ts(object):
        def __init__(self):
            self.a = 100
            self.b = 200

        def __set__(self, instance, value):
            print '__set__', instance, value
            return self

        def __get__(self, instance, owner):
            print '__get__', instance, owner
            return self


    class TTs(object):
        def __init__(self):
            self.x = 1000
            self.y = 100
            self.z = 10

        x = Ts()
        y = 10
        a = 1


    if __name__ == '__main__':
        t = TTs()
        print t.__dict__
        print t.x
        print t.y
        print t.a

测试结果如下：

    __set__ <__main__.TTs object at 0x1079007d0> 1000
    {'y': 100, 'z': 10}
    __get__ <__main__.TTs object at 0x1079007d0> <class '__main__.TTs'>
    <__main__.Ts object at 0x107900750>
    100
    1

看的出来描述器控制了默认的查找行为。

# 四.描述器协议

一个对象具有任意一个`__get__`, `__set__`，`__delete__`方法就会成为描述器，从而在被当作对象属性时重写默认的查找行为。

这里注意的是：**资料描述器和非资料描述器的区别**：

- 资料描述器：同时定义了`__get__`和`__set__`, 对于同名属性优先使用资料描述器
- 非资料描述器:只定义了`__get__`，对于同名属性优先使用字典中的属性

这个例子已经在上面举出了，上面定义了资料描述器，在t对象中，t字典属性x和描述器属性同名x，则优先使用了资料描述器，所以t字典`__dict__`就没有x属性这一项，而上上例子中则有。
如果去掉`__set__`则t对象`__dict__`还如以前一样。

要想制作一个只读的资料描述器，需要同时定义` __set__` 和 `__get__`,并在` __set__` 中引发一个 `AttributeError` 异常。定义一个引发异常的 `__set__` 方法就足够让一个描述器成为资料描述器。

# 五.描述器的调用

- 直接调用： `d.__get__(obj)`
- 自动调用：描述器在属性访问时被自动调用.

实例：

    class RevealAccess(object):
        def __init__(self, initval=None, name='var'):
            self.val = initval
            self.name = name

        def __get__(self, instance, owner):
            print 'Retrieving', self.name
            return self.val

        def __set__(self, instance, value):
            print 'Updating', self.name
            self.val = value


    class MyClass(object):
        x = RevealAccess(10, 'nn')
        y = 5

    if __name__ == '__main__':
        m = MyClass()
        print m.x
        m.x = 100
        print m.x
        print m.y


    #output:

    Retrieving nn
    10
    Updating nn
    Retrieving nn
    100
    5


## 5.1 属性

在使用`property`时，如果作用在多个属性上，则需要定义一大堆`@property`,`@xxx.getter`,`@xxx.setter`等，不能复用，如果越到这种情况就要考虑使用描述器了。

在这篇文章[**Python描述符（descriptor）解密**](http://www.geekfan.net/7862/)把这种使用讲的真好。受益了很多。

实例如下：记录电影保证属性值不能为负数：

    class Movie(object):
        def __init__(self, title, rating, runtime, budget, gross):
            self.title = title
            self.rating = rating
            self.runtime = runtime
            self.budget = budget
            self.gross = gross

方法如下：

1. 在类定义中判断，如果实例化的属性为负数则触发异常，这个只能在初始化时有用，如果更改已存在实例的属性为负数则捕获不到
2. 使用`property`，需要对每个属性定义property，太臃肿。
3. 使用描述器，为重复的property逻辑编写单独的类来处理，最佳选择。

最佳代码如下：


    from weakref import WeakKeyDictionary


    class NonNegative(object):
        """避免负数的描述器"""
        def __init__(self, default):
            self.default = default
            self.data = WeakKeyDictionary()     # 使用WeakKeyDictionary来取代普通的字典以防止内存泄露

        def __get__(self, instance, owner):
            """calls x.d, 且d不为负数，x为instance, type(x)为owner"""
            return self.data.get(instance, self.default)

        def __set__(self, instance, value):
            if value < 0:
                raise ValueError("Negative value not allowed: %s" % value)
            # 使用字典弱引用确保实例的数据只属于实例本身，否则多个实例都共享相同的值
            self.data[instance] = value


    class Movie(object):
        # 把描述符放在类的层次上（class level）而非__init__中
        rating = NonNegative(0)
        runtime = NonNegative(0)
        budget = NonNegative(0)
        gross = NonNegative(0)

        def __init__(self, title, rating, runtime, budget, gross):
            self.title = title
            self.rating = rating
            self.runtime = runtime
            self.budget = budget
            self.gross = gross

        def profit(self):
            return self.gross - self.budget

    m = Movie('AA', 87, 102, 10000, 30000)
    print m.rating
    m.rating = -1

    #output:
    87
    Traceback (most recent call last):
    File "/Users/fangpeng/tmps/ts.py", line 47, in <module>
        m.rating = -1
    File "/Users/fangpeng/tmps/ts.py", line 24, in __set__
        raise ValueError("Negative value not allowed: %s" % value)
    ValueError: Negative value not allowed: -1

具体代码逻辑还是参考上面的文章吧。

## 5.2 函数和方法，静态方法和类方法

类的字典把方法当做函数存储，为了支持方法调用，函数包含一个 `__get__()` 方法以便在属性访问时绑定方法。这就是说所有的函数都是非资料描述器，它们返回绑定(bound)还是非绑定(unbound)的方法取决于他们是被实例调用还是被类调用.

简而言之，函数有个方法 `__get__()` ，当函数被当作属性访问时，它就会把函数变成一个实例方法。非资料描述器把`obj.f(*args)` 的调用转换成 `f(obj, *args)` 。 调用`klass.f(*args)` 就变成调用` f(*args)` 。

具体实现逻辑可阅读C代码。


# 六.描述器的应用

有如下应用：

- 属性缓存
- 类型检查控制
- 等..

描述器的作用主要在方法和属性的定义上,可以改变类的一些行为,如配合装饰器，写一个类属性的缓存。Flask的作者写了一个werkzeug网络工具库，里面就使用描述器的特性，实现了一个缓存器。


    class _Missing(object):
        def __repr__(self):
            return 'no value'

        def __reduce__(self):
            return '_missing'

    _missing = _Missing()


    class CachedProperty(object):
        def __init__(self, func, name=None, doc=None):
            self.__name__ = name or func.__name__
            self.__module__ = func.__module__
            self.__doc__ == doc or func.__doc__
            self.func = func

        def __get__(self, obj, type=None):
            if obj is None:
                return self
            value = obj.__dict__.get(self.__name__, _missing)
            if value is _missing:
                value = self.func(obj)
                obj.__dict__[self.__name__] = value

            return value


    class Foo(object):
        @CachedProperty
        def foo(self):
            print 'first calculate'
            result = 'VALUE'
            return result


    f = Foo()
    print f.foo
    print f.foo

    #output
    first calculate
    VALUE
    VALUE

first calculate只在第一次调用时候被计算之后就把结果缓存起来了。

在《Python Cookbook》，提供的一个类型检查的例子很不错，我调整如下：

- [ 使用描述器来进行数据模型的类型约束, field_type_check.py](https://github.com/BeginMan/pytool/blob/master/class-opreator/field_type_check.py)
- [推荐：数据模型的类型约束-版本2：装饰器， field_type_check_with_decorator.py](https://github.com/BeginMan/pytool/blob/master/class-opreator/field_type_check_with_decorator.py)

# 参考：

- [1. Python描述器引导(翻译)](http://pyzh.readthedocs.org/en/latest/Descriptor-HOW-TO-Guide.html#python)
- [Python 黑魔法 --- 描述器（descriptor）](http://www.jianshu.com/p/250f0d305c35)
- [**Python描述符（descriptor）解密**](http://www.geekfan.net/7862/)

# 修订历史

- 2016-02-16：初稿
- 2016-02-19：添加使用描述器类型检查控制的应用2个例子

