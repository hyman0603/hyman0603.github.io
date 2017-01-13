---
layout: post
title: "Python 面向对象继承与super"
category: "python"
header-img: "img/wtf.jpg"
tags: [python]
---
>`super()`并非继承代名词

修订与：2016-02-18
--

这里分两部分，一部分是Python OOP继承特性，另一部分是针对`super`的理解。分这两部分的原因是对`super`的误解，总以为`super`就是继承特性，在很多博客中也这么说，但实则不然。

修订的原因是在看[《Python CookBook》8.8 子类中扩展property](http://python3-cookbook.readthedocs.org/zh_CN/latest/c08/p08_extending_property_in_subclass.html)时发现的一个问题，就是代码中`super(SubPerson, SubPerson)`而非`super(SubPerson, self)`, 在以往经验中，就可能会觉得有问题，因为那个时候并没有好好看其源码。至于为什么这样用呢？在最后面解释说明吧。

--

关于Python面向对象的继承有以下几个需要注意的点：


- `__bases__`属性的理解: 包含父类集合的元祖
- 覆盖与继承，如果子类完全覆盖父类方法则不用显式基类方法；如果通过继承来覆盖则需要显式调用基类方法。
- `super()`方法的位置
- 关于不可变类型和可变类型的继承
- 多重继承


# 一. `__bases__`类属性
包含父类集合的元祖

	class A: pass
	class B(object): pass
	class C(object): pass
	class D(B, C): pass
	class F(dict): pass
	
	print A.__bases__           # (), 对于经典类则无
	print B.__bases__           # (<type 'object'>,)
	print D.__bases__           # (<class '__main__.B'>, <class '__main__.C'>)
	print F.__bases__           # (<type 'dict'>,)


# 二.继承覆盖

如果重写父类方法，则可以显式调用基类方法，有两种方式:
	
	# 方式一:
	BaseCls.method(self, *args, **kwargs)
	# 方式二：(推荐)
	super(ChildCls, self).method(*args, **kwargs)

对于重写`__init__`，我们也需要显式调用基类的`__init__`


如果我们把`super`位置决定从子类的哪个位置开始继承基类方法，**为了保证数据一致性，在继承的时候我们应该考虑继承优先的原则，即super()要放在子类方法第一位置。**

# 三.关于可变类型与不可变类型的继承

## 3.1 不可变类型的继承
对于不可变类型，如str,int,unicode,fload,tuple,forzenset等，`__init__()`方法是个伪方法，必须重新覆盖`__new__()`方法才能满足继承。
	
	class RoundFloat(float):
	    def __new__(cls, val, *args, **kwargs):
	        # return float.__new__(cls, round(val, 2))
	        return super(RoundFloat, cls).__new__(cls, round(val, 2))
	
	r = RoundFloat(1.8833)
	print r         # 1.88


注意区别：

- 对于`__new__()`使用`super`则需要我们显式传入类对象`cls`,如：`super(x, cls).__new__(cls)`
- 对于`__init__()`则super会自动传入实例对象`self`，如：`super(x, self).__init__()`

## 3.2 可变类型的继承
对于可变类型的子类化，可能不需要使用`__new__()`或`__init__()` 而是直接子类化其方法，应用的比较少，首先要确定你的业务逻辑是什么，有没有比子类化更简单的方式(如一个简单函数)等， 如下例子参考《Python核心编程》将keys()自动排序：

	class SortedKeyDict(dict):
	    def keys(self):
	        return sorted(super(SortedKeyDict, self).keys())
	
	data = (('fang',100), ('apple', 28), ('zone', 10), ('dig', 200))
	s = SortedKeyDict(data)
	print s.keys()      # ['apple', 'dig', 'fang', 'zone']


# 四.MRO与多重继承

所谓MRO(Method Resolution Order)是广度优先，而非深度优先算法，在python2.2引入。

**对于经典类，采用的是深度优先搜索; 对于新类则广度优先**, 如下实例：

	class A1: #(object)
	    def foo(self):
	        print 'A1.foo'
	
	class A2: #(object)
	    def foo(self):
	        print 'A2.foo'
	    def bar(self):
	        print 'A2.bar'
	
	class B1(A1, A2):
	    pass
	
	class B2(A1, A2):
	    def bar(self):
	        print 'B2.bar'
	
	class C(B1, B2):
	    pass

其继承关系图如下：

![](http://7fvf56.com1.z0.glb.clouddn.com/MRO.png)

经典类测试：
	
	c = C()
	c.foo()     # C(无) -> B1(无) -> A1(有, 不再继续搜索)
	c.bar()     # C(无) -> B1(无) -> A1(无, 已经深度搜索完B1左侧, 开始搜索B1右侧).. -> A2(有, 不再继续搜索)
	
结果如下：
	
	A1.foo
	A2.bar

新式类测试：
	
	c = C()
	c.foo()     # C(无) -> B1(无) -> B2(无, 继续下层搜索) -> A1
	c.bar()     # C(无) -> B1(无) -> B2(有, 不再继续搜索)

结果如下：

	A1.foo
	B2.bar

**新式类中`__mro__`属性可现实广度次序**

	print C.__mro__
	(<class '__main__.C'>, <class '__main__.B1'>, <class '__main__.B2'>, <class '__main__.A1'>, <class '__main__.A2'>, <type 'object'>)


修订与：2016-02-18
--

# 五.super原理

好了，开始我们的重头戏，`super()`.

第一：首先`super()`在2.x和3.x的不同，这个可参看:[PEP 3135 -- New Super](https://www.python.org/dev/peps/pep-3135/) 在3.x `super`的使用更加简洁，`super().foo(1, 2)`替代2.x的`super(Foo, self).foo(1, 2)`

其次，`super()`的理解并非限制在继承上，在[《Python Cookbook》8.7 调用父类方法](http://python3-cookbook.readthedocs.org/zh_CN/latest/c08/p07_calling_method_on_parent_class.html)书中，作者以直接调用父类和使用`super()`两种方式，通过从所谓的方法解析顺序(MRO)列表解释下Python是如何实现继承的。但是我觉得这篇文章并没有讲出具体的原理来。

书中介绍：“Raymond Hettinger为此写了一篇非常好的文章 “[Python’s super() Considered Super!](http://rhettinger.wordpress.com/2011/05/26/super-considered-super)” ， 通过大量的例子向我们解释了为什么 super() 是极好的。”

我觉得知乎上这篇laike9m回答：[**Python中既然可以直接通过父类名调用父类方法为什么还会存在super函数？**](https://www.zhihu.com/question/20040039/answer/57883315)讲的真不错。

总结如下：

**super 指的是 MRO 中的下一个类** 其实干的是这件事：

	def super(cls, inst):
		mro = inst.__class__.mro()
		return mro[mro.index(cls) + 1]

两个参数 cls 和 inst 分别做了两件事：

- **inst 负责生成 MRO 的 list**
- **通过 cls 定位当前 MRO 中的 index, 并返回 mro[index + 1]**

这两件事才是 super 的实质.如下实例：

	class Root(object):
	    def __init__(self):
	        print("Root")
	
	
	class B(Root):
	    def __init__(self):
	        print("enter B")
	        super(B, self).__init__()
	        print("leave B")
	
	
	class C(Root):
	    def __init__(self):
	        print("enter C")
	        super(C, self).__init__()
	        print("leave C")
	
	
	class D(B, C):
	    pass
	
	
	d = D()
	print(d.__class__.__mro__)
	
	enter B
	enter C
	Root
	leave C
	leave B
	(<class '__main__.D'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.Root'>, <type 'object'>)

根据`super`原理，流程如下：

1. d实例化，首先获取`self.__class__.__mro__`，注意这里的 self 是 D 的 instance
2. 因为 D 没有定义 `__init__`,会在 MRO 中找下一个类, 如上mro列出的，下一个类是B, 那么调用B的`__init__`
3. 在B的`__init__`中初始化打印"enter B"， 遇到`super `则通过 B 来定位 MRO 中的 index，并找到下一个。显然 B 的下一个是 C。于是，我们调用 C 的 `__init__`，打出 enter C。
4. C中遇到`super`,通过C定位MRO中的index,找到下一个Root,则打印Root. 然后紧接着C的`__init__`继续运行，打印leave C, 然后打印leave B
5. 整个d实例化后，最后打印d类的mro.

注意在B实例化中，如果认为 super 代表“调用父类的方法”，会想当然的认为下一句应该是“Root”而非"enter C"。


好了，弄清楚super的本质后，我会回归到最上面的问题，我们做个试验：
	
	class A(object):
	    m = 1
	
	    def __init__(self, name):
	        self.name = 10
	        self.pro_name = 1000
	
	    @classmethod
	    def ub(cls):
	        print("unbound")
	
	    @property
	    def pro_name(self):
	        return self._pro_name
	
	    @pro_name.setter
	    def pro_name(self, value):
	        self._pro_name = value
	
	
	class B(A):
	    m = 100
	
	    def __init__(self, name):
	        self.name = name
	        print super(B, B)
	        print super(B, self)
	        print super(B)
	
	        super(B, self).__init__(name)
	        super(B, B).ub()
	
	        print super(B, self).pro_name
	        print super(B, B).pro_name
	
	        print super(B, B).m
	        print A.m
	        print B.m
	
	
	b = B('good')
	print b.name

分别通过`super(B, B)`和`super(B, self)`测试，输出结果如下：
	
	<super: <class 'B'>, <B object>>
	<super: <class 'B'>, <B object>>
	<super: <class 'B'>, NULL>
	unbound
	1
	1000
	<property object at 0x1024ece10>
	1
	100
	10


这里注意，输出pro_name属性时，`super(B, B)`输出的是`<property ..>`而`super(B, self)`输出的则是值。

在`__builtin__.py`中，对`super`类的定义如下：
	
	class super(object):
	    """
	    super(type, obj) -> bound super object; requires isinstance(obj, type)
	    super(type) -> unbound super object
	    super(type, type2) -> bound super object; requires issubclass(type2, type)
	    Typical use to call a cooperative superclass method:
	    class C(B):
	        def meth(self, arg):
	            super(C, self).meth(arg)
	    """
	    
至此明了了：

- `super(Cls, self)`:  对应Cls MRO下一个类的实例
- `super(Cls, Cls)`: 对应Cls MRO下一个的类

# 参考

- [Python Cookbook 8.7 调用父类方法](http://python3-cookbook.readthedocs.org/zh_CN/latest/c08/p07_calling_method_on_parent_class.html)
- [Python中既然可以直接通过父类名调用父类方法为什么还会存在super函数？](https://www.zhihu.com/question/20040039/answer/57883315)
- [PEP 3135 -- New Super](https://www.python.org/dev/peps/pep-3135/)

# 修订历史

- 2015-06-12：初稿
- 2016-02-18：对`super()`的理解，更新子类中扩展property的问题

