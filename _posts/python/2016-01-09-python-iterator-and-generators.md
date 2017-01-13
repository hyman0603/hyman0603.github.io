---
layout: post
title: "Python迭代器和生成器"
description: "Python迭代器和生成器"
category: "python"
tags: [python]
---

重点：

- 理解迭代原理
- 理解生成器原理，yield使用方法
- itertools模块的掌握


# 一.迭代协议

我们常用 forloop 用来遍历一个可迭代对象,如果需要对迭代做更加精准的控制，必须要了解底层迭代机制。

1. 调用`iter(items)`或`items.__iter__()`来获取iterator。
2. 使用`next()` 或 `it.__next__()`
3. `StopIteration` 用来指示迭代的结尾

如下测试，手动遍历可迭代对象,[manual_iter.py](https://github.com/BeginMan/pytool/blob/master/iterator_and_generators/manual_iter.py)

在任何可迭代对象中执行迭代操作只需要定义一个 __iter__() 方法，将迭代操作代理到容器内部的对象上去.

如下：

	class Node(object):
	    def __init__(self, name):
	        self.name = name
	        self._children = []

	    def __repr__(self):
	        return '<Node: %r>' % self.name

	    def __iter__(self):
	        # 将迭代请求传递给内部的 _children 属性。
	        return iter(self._children)

	    def __add__(self, other):
	        self._children.append(other)


	root = Node('root')
	child_a = Node('a')
	child_b = Node('b')
	root + child_a
	root + child_b

	for obj in root:
	    print obj


	# outputs:
	# <Node: 'a'>
	# <Node: 'b'>


>迭代器协议需要`__iter__()`方法实现一个`__next__()`方法的迭代器对象。

如果你只是迭代遍历其他容器的内容，你无须担心底层是怎样实现的。你所要做的只是传递迭代请求既可。

这里`iter(s)` 只是简单的通过调用 `s.__iter__()` 方法来返回对应的迭代器对象。

# 二. 自定义迭代模式
如果你想实现一种新的迭代模式，使用一个生成器函数来定义它,通过`yield`语句来实现。

## 2.1 yield原理

关于yield,这篇文章很好[ **(译)Python关键字yield的解释(stackoverflow)¶**](http://pyzh.readthedocs.org/en/latest/the-python-yield-keyword-explained.html)

## 2.2 自定义一个高效的反向迭代
使用内置的 `reversed()` 函数,往往需要将对象转换为一个列表，可迭代对象元素很多的话，转换为一个列表要**消耗大量的内存**。

如何生成一个高效的反向迭代呢？我们可以**自定义类上实现 `__reversed__()` 方法来实现反向迭代,如实例[iterating_in_reverse.py](https://github.com/BeginMan/pytool/blob/master/iterator_and_generators/iterating_in_reverse.py)

## 2.3 迭代器和生成器通用切片

>迭代器和生成器不能使用标准的切片操作，因为它们的长度事先我们并不知道(并且也没有实现索引)。

	>>> def count(n):
	...     while n > 0:
	...             yield n
	...             n -= 1
	... 
	>>> n = count(10)
	>>> n[2: 5]
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	TypeError: 'generator' object has no attribute '__getitem__'

函数 `itertools.islice()` 正好适用于在迭代器和生成器上做切片操作:

	>>> from itertools import islice
	>>> list(islice(n, 2, 5))
	[8, 7, 6]


注意： `islice()` 会消耗掉传入的迭代器中的数据。 必须考虑到迭代器是不可逆的这个事实。

所以如果你需要之后再次访问这个迭代器的话，那你就得先将它里面的数据放入一个列表中。

	# 接上
	>>> n.next()
	5
	>>> n.next()
	4

## 2.4 熟练掌握 itertools 模块
参考这里[PYTHON-进阶-ITERTOOLS模块小结](http://www.wklken.me/posts/2013/08/20/python-extra-itertools.html)

# 三.总结

## enumerate

`enumerate()`常用返回可迭代对象的索引和值，其返回的是一个 enumerate 对象实例， 它是一个迭代器，返回连续的包含一个计数和一个值的元组。这种情况在你遍历文件时想在错误消息中使用行号定位时候非常有用：如用户上传excel处理，如发现错误则记录行号反馈给用户。

	with open(filename, 'rt') as f:
	    for lineno, line in enumerate(f, 1):
	    	# todo.

## zip VS itertools.zip_longest 

两者都可同时**迭代多个序列**

`zip()`会创建一个迭代器来作为结果返回，可配合`list`, 'dict'等使用

使用`zip()`则迭代长度跟参数中最短序列长度一致：

	>>> a = [1, 2, 3]
	>>> b = ['w', 'x', 'y', 'z']
	>>> for i in zip(a,b):
	...     print(i)
	...
	(1, 'w')
	(2, 'x')
	(3, 'y')

使用`itertools.zip_longest()`(Python3.x，如果是python2.6+, 则是`izip_longest`)则迭代长度跟参数中最长序列长度一致：


	>>> from itertools import izip_longest
	>>> list(izip_longest(a,b))
	[(1, 'w'), (2, 'x'), (3, 'y'), (None, 'z')]
	>>> list(izip_longest(a,b, fillvalue=0))
	[(1, 'w'), (2, 'x'), (3, 'y'), (0, 'z')]

注意，还可以使用`map()`：

	>>> map(None, a, b)
	[(1, 'w'), (2, 'x'), (3, 'y'), (None, 'z')]

## itertools.chain() Vs add

	>>> from itertools import chain
	>>> chain(a, b)
	<itertools.chain object at 0x10e22a110>
	
	>>> list(chain(a, b))
	[1, 2, 3, 'w', 'x', 'y', 'z']
	
	>>> a+b
	[1, 2, 3, 'w', 'x', 'y', 'z']

`itertools.chain()` 接受一个或多个可迭代对象最为输入参数。 然后**创建一个迭代器**，依次连续的返回每个可迭代对象中的元素。 **这种方式要比先将序列合并再迭代要高效的多**

>a + b 操作会创建一个**全新的序列并要求a和b的类型一致**,`chian()` 不会有这一步，所以如果输入序列非常大的时候会很**省内存**。 并且当可迭代对象类型不一样的时候 chain() 同样可以很好的工作。


ref:

- [Python Cookbook 迭代器与生成器](http://python3-cookbook.readthedocs.org/zh_CN/latest/chapters/p04_iterators_and_generators.html)
- [3. (译)Python关键字yield的解释(stackoverflow)](http://pyzh.readthedocs.org/en/latest/the-python-yield-keyword-explained.html)
- [converting “yield from” statement to python 2.7 code](http://stackoverflow.com/questions/17581332/converting-yield-from-statement-to-python-2-7-code)
