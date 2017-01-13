---               
layout: post                 
title: "重温 Python `__getattribute__`"
description: ""
category: "python"
tags: [python, OOP, 属性]
---

之前我费心费力的总结了：**[Python `__get__`, `__getattr__`和`__getattribute__`区别](http://beginman.cn/python/2016/02/16/python-differnet-with-get-getattr-and-getattribute/)**, 今天在《Python面向对象编程指南》TOP3.3小节中又刷选了新认知，与其说刷选不如说我之前理解的不透彻，编程这玩意儿，熟能生巧。

书中说：

> “`__getattribute__()`方法提供了**对属性更底层的一些操作**。默认的实现逻辑是先从内部的`__dict__`（或`__slots__`）中查找已有的属性。如果属性没有找到则调用`__getattr__()`函数。如果值是一个修饰符（参见3.5“创建修饰符”），对修饰符进行处理。否则，返回当前值即可。”

通过重写这个方法，可以达到以下目的：

- 可以有效阻止属性访问。在这个方法中，抛出异常而非返回值。相比于在代码中仅仅使用下划线（`_`）为开头来把一个名字标记为私有的方式，这种方法使得属性的封装更透彻。
- 可仿照`__getattr__()`函数的工作方式来创建新属性。在这种情况下，可以绕过`__getattribute__()`的实现逻辑。
- 可以使得属性执行单独或不同的任务。但这样会降低程序的可读性和可维护性，这是个很糟糕的想法。
- 可以改变修饰符的行为。虽然技术上可行，改变修饰符的行为却是个糟糕的想法。

当实现`__getattribute__()`方法时，将阻止任何内部属性访问函数体，这一点很重要。如果试图获取self.name的值，**会导致无限递归。**`__getattribute__ ()`函数不能包含任何`self.name`属性的访问，因为会导致无限递归。

为了获得`__getattribute__()`方法中的属性值，必须显式调用object基类中的方法，像如下代码这样。

    object.__getattribute__(self, name)

可以通过使用`__getattribute__()`方法阻止对内部`__dict__`属性的访问来实现不可变。以下代码中的类定义隐藏了所有名称以下划线（`_`）为开头的属性。”

```python
def __getattribute__(self, name):
   if name.startswith('_'):
       raise AttributeError('Cannot get private {name}'.format(name=name))
   return object.__getattribute__(self, name)
```






