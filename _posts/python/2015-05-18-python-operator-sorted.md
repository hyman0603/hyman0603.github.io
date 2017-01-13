---
layout: post
title: "python operator.itemgetter函数与sorted的妙用"
description: "python operator.itemgetter函数与sorted的妙用"
category: "python"
tags: [python奇技淫巧]
---

<p><code>operator</code>模块提供<code>itemgetter</code>函数用于获取对象的哪些维的数据或者哪些key对应的数据,参数就是索引号或key值.可以设置多个索引号或key值。</p>

<p>文档描述如下：</p>

<pre><code>class itemgetter(object):
    """
    itemgetter(item, ...) --&gt; itemgetter object

    Return a callable object that fetches the given item(s) from its operand.
    After f = itemgetter(2), the call f(r) returns r[2].
    After g = itemgetter(2, 5, 3), the call g(r) returns (r[2], r[5], r[3])
    """
</code></pre>

<p>作用对象是<strong>可迭代对象item</strong> ，包括字典，列表，元祖等.</p>

<!--more-->

<p><strong>1.对列表的操作：</strong></p>

<pre><code>import operator
a = ['a','b','c']
b = operator.itemgetter(1)      # 定义b函数，获取对象的1索引值
print b #  &lt;operator.itemgetter at 0x10db69b50&gt;
print b(a) # 'b'

b = operator.itemgetter(1,2)
print b(a) # ('b', 'c')
</code></pre>

<p><strong>2.对字典的操作</strong></p>

<pre><code>students = [{'name':'fang', 'age':24}, {'name':'job', 'age':20}, {'name':'zen', 'age':40}]
b = operator.itemgetter('name', 'age')
for i in students:
    print b(i)
    ....:     

('fang', 24)
('job', 20)
('zen', 40)
</code></pre>

<p><strong>要注意，operator.itemgetter函数获取的不是值，而是定义了一个函数，通过该函数作用到对象上才能获取值。</strong></p>

<p>其多与sorted函数一块使用</p>

<pre><code>In [38]: students = [{'jack':89}, {'rose':40},{'bils':70}, {'zend':30}]

In [39]: sorted(students)
Out[39]: [{'bils': 70}, {'jack': 89}, {'rose': 40}, {'zend': 30}]

In [40]: sorted(students, key=lambda x:x.keys())
Out[40]: [{'bils': 70}, {'jack': 89}, {'rose': 40}, {'zend': 30}]

In [41]: sorted(students, key=lambda x:x.values())
Out[41]: [{'zend': 30}, {'rose': 40}, {'bils': 70}, {'jack': 89}]
</code></pre>

<p>当操作是列表对象时，可以把key 指定的lambda函数换成<code>operator.itemgetter(index)</code></p>

<pre><code>In [43]: students = [('john', 'A', 15), ('jane', 'B', 12), ('dave', 'B', 10)]

# 通过student的第三个域排序
In [44]: sorted(students, key=lambda student : student[2])
Out[44]: [('dave', 'B', 10), ('jane', 'B', 12), ('john', 'A', 15)]

# operator.itemgetter的形式通过student的第三个域排序
In [46]: sorted(students, key=operator.itemgetter(2))
Out[46]: [('dave', 'B', 10), ('jane', 'B', 12), ('john', 'A', 15)]

# 根据第二个域和第三个域进行排序
In [47]: sorted(students, key=operator.itemgetter(1,2)) 
Out[47]: [('john', 'A', 15), ('dave', 'B', 10), ('jane', 'B', 12)]
</code></pre>
