---               
layout: post   
title: "Python浮点除法VS整除"
description: ""
category: "python"
tags: [python, 面试题]
---

在看[5 个很好的 Python 面试题](https://segmentfault.com/a/1190000000618513)这篇文章好，发现自己的基础真是渣渣。其中有一道关于浮点除法和整除的题，也就是对 `/`和`//`的理解，说实话在实际开发中我很少用`//`,正因如此，才知道对这个知识点的模糊不清。

原题如下：

>以下的代码的输出将是什么? 说出你的答案并解释？

```python
def div1(x,y):
    print("%s/%s = %s" % (x, y, x/y))

def div2(x,y):
    print("%s//%s = %s" % (x, y, x//y))

div1(5,2)
div1(5.,2)
div2(5,2)
div2(5.,2.)
```

这依赖Python版本，**在Python3中所有的除法操作都是浮点除法，也就是真正的除法。在Python2.x中的`/`属于整除，往往在文件头部导入`from __future__ import division` 来重载 做到与Py3一样的效果。**

在py3中：

```python
>>> div1(5, 2)
5/2=2.5
>>> div1(5., 2)
5.0/2=2.5
```

在Py2中:

```python
>>> div1(5, 2)
5/2=2
>>> div1(5., 2)
5.0/2=2.5
```

**在Py2中一旦除法操作的任何一个数是浮点型则变成了真正的除法， 否则都是整除。**

接下来看下 双划线`//`操作符。

py3:

```python
>>> div2(5, 2)
5//2=2
>>> div2(5., 2)
5.0//2=2.0
```

Py2:

```python
>>> div2(5,2)
5//2=2
>>> div2(5.,2)
5.0//2=2.0
```

**效果一样，`//`操作符将一直执行整除，而不管操作数的类型，这就是为什么 5.0//2.0 值为 2.0。**

![](http://beginman.qiniudn.com/2016-10-14-14764388624924.jpg)

在官方文档[PEP 238: Changing the Division Operator¶](https://docs.python.org/3/whatsnew/2.2.html#pep-238-changing-the-division-operator) 更加详细：

