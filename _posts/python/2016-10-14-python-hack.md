---               
layout: post   
title: "跳过Python的坑点"
description: ""
category: "python"
tags: [python, 面试题, 奇技淫巧]
---

Python小技巧真的很多，而且有些还是导致BUG或模糊定义。这篇文章总结下，避免踩坑。

根据Python数据结构分类如下：

- 列表相关


# 一. 列表相关

## 1.1 超出索引不一定就报错
这有点不可思议，超出列表索引一般都会报IndexError异常，如下：

```python
>>> list = ['a', 'b', 'c', 'd', 'e']
>>> list[100]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
IndexError: list index out of range
```

下面来个反常的：

```python
>>> list[100:]
[]
>>> list[100:300]
[]
```

奇怪了吧。**对于任何可迭代对象的切片操作超出索引不触发异常而是返回空对象（如列表则返回空列表，字符串则返回空字符串, 元祖则返回空元祖等）。**， 如下字符串演示：

```python
>> "abcd"[100:200]
''
>>> "abcd"[100]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
IndexError: string index out of range

>>> (1,2,3)[100:200]
()
```

**这样理解或许更好些：索引返回一个项目， 如 list[n], 如果超出容器则触发异常，但切片返回容器的子容器而已，表示一个范围的对象，超出这个范围就返回空的容器。**

## 1.2 list做参数

```python

def fn(val, list=[]):
    list.append(val)
    return list


l1 = fn(1)
l2 = fn(2, [])
l3 = fn(3)

print l1
print l2
print l3
```

结果是[1, 3]、[2]、[1, 3] 而不是期望的[1]、[2]、[3].**原因就是list做参数误认为每次被调用的时候会被设置成它的默认值 []。其实新的默认列表仅仅只在函数被定义时创建一次。随后当 函数没有被指定的列表参数调用的时候，其使用的是同一个列表。这就是为什么当函数被定义的时候，表达式是用默认参数被计算，而不是它被调用的时候。**

因此，l1 和 l3 是操作的相同的列表。而 l2是操作的它创建的独立的列表（通过传递它自己的空列表作为list参数的值）。

fn 函数的定义可以做如下修改，但，当没有新的 list 参数被指定的时候，会总是开始一个新列表，这更加可能是一直期望的行为。

```python
def fn(val, list=None):
    if list is None:
        list = []
        
    list.append(val)
    return list
```

~更新中..




