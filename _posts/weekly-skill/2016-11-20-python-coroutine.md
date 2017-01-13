---
layout: post
title: "Python协程"
category: "python"
tags: [python,协程,生成器,迭代器]
---

>任何使用`yield`的函数都称为**生成器**，调用生成器函数将创建一个对象，该对象通过连续调用`next()`方法（在Python3中是`__next__()`）生成结果序列。`next()`调用使生成器函数一直运行到下一条`yield`语句为止。此时`next()`将返回值传递给`yield`, 而且函数将暂时中止执行。再次调用`next()`时，函数将继续执行yield之后的语句。此过程持续到函数返回为止。

**生成器是基于处理管道、流或数据流的一种强大方式。**，如下使用生成器函数模拟`tail -f`命令的行为：

```python

import time


def tail(f):
    # 模拟tail命令
    f.seek(0, 2)    # 移动到EOF
    while True:
        line = f.readline()
        if not line:
            time.sleep(0.1)
            continue
        yield line


def grep(lines, searchtext):
    # 模拟grep 命令
    for line in lines:
        if searchtext in line:
            yield line

"""
# 打开另一个终端，不断地 echo 内容到 test.txt
>>> file = tail(open("test.txt"))
>>> # 模拟 tail -f
>>> for f in file:
        print f

>>> # 模拟 tail -f | grep xxx
>>> file = tail(open("test.txt"))
>>> for f in grep(file, "xxx"):
        print f

"""
```

![](http://beginman.qiniudn.com/2016-11-20-14796329393757.jpg)

# 协程

>通常，函数运行时要使用一组输入参数，但是，也可把函数编写为一个任务，从而能处理发送给它的一系列输入。这类函数称为**协程**，可使用`yield`语句并以表达式`(yield)`的形式创建协程，也就是说将yield语句用于赋值运算符的形式的函数称为**协程**，它的执行是为了响应发送给它的值。


```python
In [30]: def print_matches(matchtext):
    ...:     print "Looking for ", matchtext
    ...:     while 1:
    ...:         line = (yield)   # 获得一行文本
    ...:         if matchtext in line:
    ...:             print line
    ...:

In [31]: matcher = print_matches("py")

In [32]: matcher.next()  # 向前执行到第一条(yield)语句
Looking for  py

In [33]: matcher.send("Hello")  # 然后使用send()给它发送数据

In [34]: matcher.send("python")
python

In [35]: matcher.close()  # 关闭协程

In [36]: matcher.send("python")
---------------------------------------------------------------------------
StopIteration                             Traceback (most recent call last)
<ipython-input-36-06b318d009ca> in <module>()
----> 1 matcher.send("python")

StopIteration:

```

使用`send()`为协程发送某个值之前，协程会暂时中止，传递给`send()`的值由协程中的`(yield)`表达式返回。此时，协程中的`(yield)`表达式将返回这个值，而接下来的语句将会处理它。处理直到遇到下一个`(yield)`表达式才会结束，也就是函数暂时中止的地方。正如上一个例子所示，这个过程将会继续下去，直到协程函数返回或者调用它的`close()`方法为止。

**基于生产者-消费者模型编写并发程序时，协程十分有用。**

```python
In [37]: matchers = [   # 一组协程
    ...: print_matches("python"),
    ...: print_matches("go"),
    ...: print_matches("js")
    ...: ]

In [38]: for m in matchers:   # 通过next()准备
    ...:     m.next()
    ...:
Looking for  python
Looking for  go
Looking for  js

In [39]: file = tail(open('test.txt'))

In [40]: for line in file:
    ...:     for m in matchers:
    ...:         m.send(line)  # 将数据发送到每个协程中
    ...:
# 等待消费   
```

![](http://beginman.qiniudn.com/2016-11-20-14796240005569.jpg)


在上面的例子中，会发现首先`next()`操作，在协程中需要首先调用`next()`这件事很容易被忽略，经常成为错误之源，因此建议使用一个能自动完成`next()`的装饰器来包装协程。

```python
def coroutine(func):
    """协程装饰器"""
    @wraps(func)
    def start(*args, **kwargs):
        g = func(*args, **kwargs)
        g.next()
        return g
    return start



@coroutine
def receiver():
    print("Ready to receive")
    try:
        while 1:
            n = (yield)
            # do stuff..
            print ("Got %s" % n)
    except GeneratorExit:
        print("Receiver done!")
```

实验下：

```python

In [53]: r = receiver()
Ready to receive

In [54]: r.send("hello")
Got hello

In [58]: r.close()
Receiver done!
```

协程的运行是`while True`的，无限循环，除非它被显式关闭或自己退出，调用`close()`即可关闭输入流。关闭后如果继续操作协程则会引发`StopIteration`异常，`close()`操作将会在协程内部引发`GeneratorExit`异常。

如上的生成器对象一图，还可`throw()`一个异常，`r.throw(RuntimeError, "you're hosed!")`。 协程可选择捕获异常并以正确方式处理它们。**使用`throw()`方法作为给协程的异步信号并不安全，应该禁止从单独的执行线程或信号程序调用这个方法。**

## yield同时接收和发出返回值

>如果yield表达式提供了值，协程可以使用`yield`语句同时接收和发出返回值。

```python
@coroutine
def line_splitter(delimiter=None):
    print("Ready to split")
    result = None
    while 1:
        print "result:", result
        line = yield result
        print "....."
        result = line.split(delimiter)
```

这里 `line=yield result` , 实例运行如下：

```python
In [95]: r = line_splitter(",")  # 被装饰器next()处理，此时在yield处挂起
Ready to split
result: None

# send一个值后，协程继续，从上一步next()在yield处挂起的位置处继续执行
# 然后后续的split处理等
# 直到执行到yield处又被挂起
In [96]: r.send('A,B')   
.....               
result: ['A', 'B']
Out[96]: ['A', 'B']
```

理解这个例子的先后顺序至关重要：

1. 首个`next()`调用让协程向前执行到`yield result`, 这时将返回result的初始值None
2. 接下来`send(xxx)`调用，接收到的值被放在line中并开始split
3. **`send()`的返回值就是传递给下一条yield语句的值，也就是说`send()`方法的返回值来自下一个yield表达式，而不是接收send传递的值的yield表达式。或者这样理解，在下一次for循环中遇到yield时返回。**

## 协程异常处理

除了可以向协程中`send`发送值以外，也可以通过`throw`函数向协程中抛出异常，而这个异常像普通的异常一样，也可以通过`try-except`来捕获。

```python

@coroutine
def line_splitter(delimiter=None):
    print("Ready to split")
    result = None
    while 1:
        print "result:", result
        try:
            line = yield result
        except RuntimeError as e:
            print("Catch %s" % e)
            result = e
            continue

        print "....."
        result = line.split(delimiter)
```


## 协程与生成器区别

生成器和协程都是通过python中的yield的关键字实现的，不同的是，生成器只会调用next来不断地生成数据，而协程却会调用next和send来返回结果和接收参数。


# 参考

- 《Python参考手册》


