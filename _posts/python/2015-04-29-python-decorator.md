---
layout: post
title: "python装饰器小结"
description: "python装饰器小结"
header-img: "img/in-post/geek.jpg"
category: "Python"
tags: [python]
---

>学而时习之，多么简明的道理，可惜啊，很多人都不明白。

装饰器是Python高级应用之一，算是用的最多的魔法吧。下面来分析下装饰器的用法吧

# 一. 函数对象作为参数


    def deco(fn):
        print "bef..."
        fn()
        print "end..."
        return fn           # 返回原函数对象

    def func():
        print 'fun'

    myfun = deco(func)      # 将原函数对象func赋值给变量myfun
    print '---------'
    myfun()                 # 执行原函数对象func
    print '*********'
    myfun()                 # 执行原函数对象func


运行后的结果如下：

    bef...
    fun
    end...
    ---------
    fun
    *********
    fun


该例中`deco()`打印bef,end,执行原函数(`fn()`)，然后返回原函数对象(`fn`), 那么`myfun`就是返回的原函数对象`fn`。再看第二个例子：


    def deco(fn):
        def wrapper():      # 在实例1基础上又包装了一层函数
            print "bef..."
            fn()
            print "end..."
                                 # 这里不再返回原函数对象
        return wrapper           # 返回wrapper函数对象

    def func():
        print 'fun'

    myfun = deco(func)          # 将wrapper函数对象赋值给myfun
    print '--------'
    myfun()                     # 执行wrapper函数
    print '*********'
    myfun()                     # 执行wrapper函数


运行后的结果：

    ---------
    bef...
    fun
    end...
    *********
    bef...
    fun
    end...


两种代码不同之处在于：

- 代码1.发现新函数只在第一次被调用，且原函数多调用了一次
- 代码2.装饰函数返回内嵌包装函数对象保证了每次新函数都被调用

**如上所见如果我们要装饰一个函数，一定要定义装饰函数(如deco)接收被装饰的函数(如func)作为参数，如`def deco(fn)`，并返回内部的包装函数对象(`return wrapper`)**

# 二.语法糖形式的装饰器

## 2.1 语法糖

如果将`myfun = deco(func)`变相以下，就成了如下方式：

    @deco
    def func():
        .....

**这种变相的方式就称为`装饰器`，所谓的装饰器就是`@`语法糖- Syntactic Sugar的形式来包装一个函数。这种包装作用就是在函数执行前处理某某，在函数执行后处理某某。**

如下实例：

    def deco(fn):
        def wrapper(*args, **kwargs):
            return fn(*args, **kwargs)

        return wrapper

    def fun(a, b):
        return a+b

    # 将函数作为参数的直接形式
    myfun = deco(fun)               # 将wrapper函数对象赋值给myfun
    print myfun(100, 200)           # 调用wrapper函数,返回fn回调函数的值

    
    # 装饰器形式
    @deco
    def foo(a, b):
        return a+b

    print foo(100,200)          # 300

## 2.2 让装饰器带参数
让装饰器带参数，则需要在原先的基础上的最外层再包裹一层函数，用于接收参数。

    def deco(*args, **kwargs):
        # 内嵌一个真正的装饰函数
        def true_deco(fn):
            def wrapper(*args, **kwargs):
                # 返回原函数执行的结果
                return fn(*args, **kwargs)

            # 返回wrapper函数装饰对象
            return wrapper

        print 'the deco values is:', args, kwargs
        # 返回真正的装饰函数 true_deco
        return true_deco


    @deco(1,2)
    def fun(a, b):
        return a + b

    print fun(100, 200)

执行结果如下：

    the deco values is: (1, 2) {}
    300

**总结：无论包装函数包裹了多少层，一定要返回一个真正的包装函数**, 如下：

    def deco1(*args, **kwargs):
        def deco1__(fn):
            print u'deco1__'
            def wrapper(*args, **kwargs):
                print u'wrapper....'
                return fn(*args, **kwargs)

            return wrapper
        print 'deco1....%d' % (sum(args))
        return deco1__

    def foo(a, b):
        return 'foo---%d' % (a + b)

    # 以函数对象传参形式
    f = deco1(1, 3)         # deco1....
    ff = f(foo)             # deco1__
    fff = ff(100, 200)      # wrapper....
    print fff               # foo---300

如果以装饰器则：

    @deco1(1, 3)  # 返回 deco1__函数对象, 然后并将foo函数对象作为参数(`fn`)，返回wrapper函数对象
    def foo(a, b):
        return 'foo---%d' % (a + b)

    # 运行结果
    deco1....4
    deco1__

    # 执行新的包装函数
    print foo(100, 200)
    # 运行结果
    wrapper....
    foo---300


## 2.3 多个包装函数

    def deco1(*args, **kwargs):
        def deco1__(fn):
            print u'deco1__'
            def wrapper(*args, **kwargs):
                print u'wrapper....'
                return fn(*args, **kwargs)

            return wrapper
        print 'deco1....%d' % (sum(args))
        return deco1__


    def deco2(fn):
        def wrapper(*args, **kwargs):
            print 'deco2..wrapper..'
            return fn(*args, **kwargs)

        print u'deco2.....'
        return wrapper


    @deco1(1, 3)        # 返回 deco1__函数对象, 然后并将deco2函数对象作为参数(`fn`)，返回wrapper函数对象
    @deco2              # deco2函数将foo对象传入
    def foo(a, b):
        return a + b

    print '-------------------'
    print foo(100, 200)


执行结果：

    deco1....4
    deco2.....
    deco1__
    -------------------
    wrapper....
    deco2..wrapper..
    300

上面装饰器写法等同于：

    myfoo = deco1(1, 2)(deco2(foo))
    print myfoo(100, 200)

# 三.类装饰器

满足条件：

- `__init__` 传入函数做参数
- `__call__` 装饰处理

如下：

    class ClassDeco(object):
        def __init__(self, fn, *args, **kwargs):
            self.fn = fn
            self.arg = args
            self.kwargs = kwargs

        def __call__(self, *args, **kwargs):
            return self.fn(*args, **kwargs)


    @ClassDeco
    def fuc(a,b):
        return a + b

    print fuc(1, 2)         # 3

    myfunc = ClassDeco(fuc)
    print myfunc(1, 2)      # 3

类装饰器实现方式2：

    class ClassDeco(object):
        def __init__(self, *args, **kwargs):
            self.arg = args
            self.kwargs = kwargs

        def __call__(self, fn, *args, **kwargs):
            def wrapper(*args, **kwargs):
                return fn(*args, **kwargs)

            return wrapper

    @ClassDeco(100,200)
    def fuc(a,b):
        return a + b

    print fuc(1, 2)         # 3

    myfunc = ClassDeco(100,200)(fuc)
    print myfunc(1, 2)      # 3

如上实现了2个类装饰器，实现要点如下：

如果类装饰器不需要参数：

- `__init__`定义被装饰的函数
- `__call__`成为装饰函数，调用`init中被装饰的函数

如果类装饰器需要参数:

- `__init__`初始化参数，不再定义被装饰的函数
- `__call__`成为装饰函数，同时被装饰的函数作为其参数传入

# 四.装饰器带来的副作用

副作用就是：**被装饰的函数转换成了另一个函数**

    def deco(fn):
        def wrapper():
            print fn.__name__       # foo
        return wrapper

    @deco
    def func():
        print 'hello'

    func()

    print func.__name__     # wrapper

这里就要用到`warps`装饰器了，**它可以把被封装函数的name、module、doc和 dict等元信息都复制到封装函数去(模块级别常量WRAPPER_ASSIGNMENTS, WRAPPER_UPDATES)

    from functools import wraps
        def deco(fn):
            @wraps(fn)
            def wrapper():
                print fn.__name__   # func
            return wrapper

    @deco
    def func():
        print 'hello'

    func()

    print func.__name__     # func

可参考：[functools.wraps](https://docs.python.org/3/library/functools.html#functools.wraps)文档。

**更新于2016/03/01**

## (1).技巧1：在类定义的内部和外部使用装饰器

在Python3.x中新增`__wrapped__ `属性表示被装饰的函数，如上面类装饰中`__call__`中可替换为：

	...
	def __call__(self, func, *arg, **kwargs):
		return self.__wrapped__(*args, **kwargs)


如果定义装饰器包装一个函数，返回一个可调用的实例，可以在类定义的内部和外部使用，那么满足的条件是：

- `__init__`
- `__call__()`
- `__get__()`:描述器协议,目的是创建一个绑定方法对象

如下：

	import types
	from functools import wraps
	
	
	class Profiled(object):
	    def __init__(self, func):
	        wraps(func)(self)
	        self.func = func
	
	    def __call__(self, *args, **kwargs):
	        return self.__wrapped__(*args, **kwargs)          # 3.2 new add, `__wrapped__` attribute
	        # return self.func(*args, **kwargs)                   # 2.x
	
	    def __get__(self, instance, owner):
	        if instance is None:
	            return self
	        else:
	            return types.MethodType(self, instance)         # 手动创建绑定方法
	
	
	@Profiled
	def add(x, y):
	    return x + y
	
	
	class Spam:
	    @Profiled
	    def bar(self, x):
	        return x


`__get__()` 方法是为了确保绑定方法对象能被正确的创建。 

`type.MethodType()` 手动创建一个绑定方法来使用。只有当实例被使用的时候绑定方法才会被创建。 如果这个方法是在类上面来访问， 那么 `__get__()` 中的instance参数会被设置成None并直接返回 Profiled 实例本身。 

## (2).技巧2：为类方法或静态方法提供装饰器

很简单，**直接添加但是要确保装饰器在 `@classmethod` 或 `@staticmethod` 之前, 因为它俩实际上并不会创建可直接调用的对象， 而是创建特殊的描述器对象， 所以你调换它们的顺序就会出错。**。

	class A:
		@classmethod
		@decorator
		def foo(cls): pass
		
		
		@staticmethod
		@decorator
		def bar(): pass
		
		

# 五.实践应用

- [mysql 装饰器](https://gist.github.com/BeginMan/1139628e64d654b67e36)
- [高效带缓存的斐波那契数列](https://gist.github.com/BeginMan/a8ea401eca61de41e18e)
- [python程序运行计时装饰器](https://gist.github.com/BeginMan/d40a08a2a9bf35cc9f02)
- [日志打印装饰类](https://gist.github.com/BeginMan/bf229030727d2cff9e21)

# 参考资料

- [Python修饰器的函数式编程-陈皓](http://coolshell.cn/articles/11265.html)
- 《Python Cookbook》

# 修订历史

- 2014/xx/xx：...(具体日期忘了)初稿
- 2016/03/01：添加装饰器同时工作在类定义的内部和外部实现和为类方法或静态方法提供装饰器