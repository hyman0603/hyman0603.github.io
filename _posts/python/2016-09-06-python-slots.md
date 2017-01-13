---               
layout: post                 
title: "Python `__slots__`理解与应用"
description: ""
category: "python"
tags: [python,内存]
---

类对象属性存储在dict里，如果要更改这种方式就用`__slots__`, 限制class的属性. 只有绑定在`__slots__` 定义的元祖或列表内的属性才可处理， 否则触发`AttributeError`. `__slots__`定义的属性仅对当前类起作用，对继承的子类是不起作用的。

```python
class MyClass(object):
    __slots__ = ['name', 'identifier']
    def __init__(self, name, identifier):
        self.name = name
        self.identifier = identifier

a = MyClass("jack", 'fla')
a.name = "Rose"
a.age = 10      # AttributeError: 'MyClass' object has no attribute 'age'
```

`__slots__`会使得对象内部的`__dict__`对象不再有效并阻止对其他属性的访问。下面来自《Python面向对象编程指南》的不可变属性的处理：

```python
class BlackJack(object):
    __slots__ = ('rank', 'suit', 'hard', 'soft')

    def __init__(self, rank, suit, hard, soft):
        super(BlackJack, self).__setattr__('rank', rank)
        super(BlackJack, self).__setattr__('suit', suit)
        super(BlackJack, self).__setattr__('hard', hard)
        super(BlackJack, self).__setattr__('soft', soft)

    def __str__(self):
        return "{0.rank}{0.suit}".format(self)

    def __setattr__(self, key, value):
        raise AttributeError("'{__class__.__name__}' has no "
                             "attribute '{name}'".format(
            __class__=self.__class__, name=key))
```

我们做了如下3处明显的修改。

1. 把`__slots__`设为唯一被允许操作的属性。这会使得对象内部的`__dict__`对象不再有效并阻止对其他属性的访问。
2. 在`__setattr__()`函数中，代码逻辑仅仅是抛出异常。
3. 在`__init__()`函数中，调用了基类中`__setattr__()`实现，为了确保当类没有包含有效的`__setattr__()`函数时，属性依然可被正确赋值。

最重要的是它能节省内存。这篇**[slots magic](http://book.pythontips.com/en/latest/__slots__magic.html)**, 写的很牛逼，我总结如下：

**Python类通过dict存储对象实例属性，可动态添加，更改和删除。灵活性很强，但是字典存储使用内存，一旦对象太多，内存使用也高，因为Python不能只分配一个静态内存对象创建存储的所有属性，对于已知属性的对象来说，我们可使用`__slots__`告诉python不要使用dict来存储，只对一组固定的属性分配空间。**

