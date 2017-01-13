---
layout: post
title: "Python 数据结构和算法小结"
description: "Python 数据结构和算法小结"
category: "python"
tags: [python]
---
>“只要你还在担心别人会怎么看你，他们就能奴役你；只有你再也不用从自身之外寻求肯定，才能成为自己的主人。” -- 尼尔·唐纳德·沃尔什

内置数据结构，包括列表，集合以及字典等，对于理论性学习(算法，数据结构)不是一蹴而就的，我个人总结对Python数据结构和算法的学习流程如下(这也是我下一步要学习的)：

1. 打牢基础，熟悉内置数据结构的使用方法，在《Python核心编程》和《Python 学习手册》都有详尽的解释说明。
2. 熟悉常用的算法，如查询，排序和过滤等，可参考《Python Cookbook》和《啊哈算法》(C语言实现)，[Data Structures and Algorithms with Object-Oriented Design Patterns in Python](http://www.brpreiss.com/)值得好好研究研究；[Problem Solving with Algorithms and Data Structures](http://interactivepython.org/courselib/static/pythonds/index.html)是一本nice的python版本算法电子书；[《Python Algorithms: Mastering Basic Algorithms in the Python Language》](http://link.springer.com/book/10.1007%2F978-1-4302-3238-4)国内不知道有没有翻译出书，售价￥539.00有点吓人。博客系列[经典排序算法总结与实现](http://wuchong.me/blog/2014/02/09/algorithm-sort-summary/)和[qiwsir/algorithm](https://github.com/qiwsir/algorithm)
3. 熟悉Python常用的库，如：`collections`,`heapq`,`operator`等

# 一.数据结构
这节算是对《Python Cookbook》第一章的总结，关于例子，已经放在github上。[pytool.datastruct](https://github.com/BeginMan/pytool/tree/master/datastruct).


## 1.1 解压
**解压赋值可以用在任何可迭代对象上面，而不仅仅是列表或者元组。 包括字符串，文件对象，迭代器和生成器。**

	>>> data = [ 'ACME', 50, 91.1, (2012, 12, 21) ]
	>>> name, shares, price, date = data
	>>> name
	'ACME'
	>>> date
	(2012, 12, 21)
	>>> name, shares, price, (year, mon, day) = data

	>>> s = 'Hello'
	>>> a, b, c, d, e = s
	>>> a
	'H'

可以使用不常用的，如`_`做占位变量名，丢弃其他的值。

## 1.2 变长的处理

当我们对元素的个数不确定时，一定要记住用`*`或`**`, **星号表达式在迭代元素为可变长元组的序列时是很有用的**

	def drop_first_last(grades):
	    first, *middle, last = grades
	    return avg(middle)

## 1.3 你应该掌握collections模块
看这里我之前总结的[pythonStdlib/collections.md](https://github.com/BeginMan/pythonStdlib/blob/master/collections.md)

## 1.4 最大和最小N个元素

三种方式：

1. `heapq`模块两个函数：`nlargest()` 和 `nsmallest()`
2. `max()`和`min()`
3. 排序后处理`sorted(items)[:N]`或`sorted(items)[-N:]`

**`max()`,`min()`,`sum()`,`sorted()`都可以有一个关键字参数 key ，可以传入一个 callable 对象给它
这个 callable 对象对每个传入的对象返回一个值，这个值会被用来处理这些对象。**

可参考这些[示例代码 finding-the-largest-or-smallest-N-items.py](https://github.com/BeginMan/pytool/blob/master/datastruct/finding-the-largest-or-smallest-N-items.py)

## 1.5 你需要掌握heapq模块
[关于heapq模块参考](https://github.com/qiwsir/algorithm/blob/master/heapq.md)

下面代码[利用heapq模块实现一个优先级队列](https://github.com/BeginMan/pytool/blob/master/datastruct/Implementing-a-Priority-Queue.py)

## 1.6 字典初始化
**collections模块`defaultdict`来始化每个 key 刚开始对应的值,也可通过`setdefault`来处理。**

可通过[如下代码](https://github.com/BeginMan/pytool/blob/master/datastruct/mapping-keys-to-multiple-values-in-a-dictionary.py)演示

## 1.7 字典排序
为了能控制一个字典中元素的顺序，你可以使用 collections 模块中的 `OrderedDict` 类.[实例1](https://github.com/BeginMan/pytool/blob/master/datastruct/sorting-a-list-of-dictionaries-by-a-common-key.py),对于不支持原生比较的对象的排序，可[这样处理](https://github.com/BeginMan/pytool/blob/master/datastruct/sorting-objects-without-native-comparison-support.py)

## 1.8 字典运算
字典的运算,如求最小值、最大值、排序等最佳解决方案是`zip`化后再操作，`keys()`和`values()`的结果可进行集合并、交、差运算，可看[如下代码1](https://github.com/BeginMan/pytool/blob/master/datastruct/calculating-with-dictionaries.py)和[代码2](https://github.com/BeginMan/pytool/blob/master/datastruct/finding-commonalities-in-two-dictionaries.py)

## 1.9 字典分组
需要排序后配合itertools模块的`groupby()`函数来处理,[实例代码1](https://github.com/BeginMan/pytool/blob/master/datastruct/grouping-records-together-based-on-a-field.py),[实例代码2](https://github.com/BeginMan/pytool/blob/master/datastruct/dict_group.py)

## 1.10 过滤元素
有如下处理方式：

- 列表推导
- 生成器表达式迭代过滤
- 内建`filter()`函数
- `itertools.compress()` 过滤工具

可参考[1.16 过滤序列元素](http://python3-cookbook.readthedocs.org/zh_CN/latest/c01/p16_filter_sequence_elements.html)

## 1.11 映射名称到序列元素
可通过`collections.namedtuple()`构建键值对的映射，更加友好地处理数据。可[参考这里](http://python3-cookbook.readthedocs.org/zh_CN/latest/c01/p18_map_names_to_sequence_elements.html)
