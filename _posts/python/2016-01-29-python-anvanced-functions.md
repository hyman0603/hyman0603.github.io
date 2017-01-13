---
layout: post
title: "python 函数高级应用"
description: "python 函数高级应用"
category: "python"
tags: [python]
---
高级？我也不知什么才算高级，应该是难点吧。汇总如下：


1. 函数使用技巧
2. 闭包
3. 装饰器
4. 函数式编程
	1. 匿名函数与lambda
	2. 内建函数 apply（）、filter（）、map（）、reduce（）
	3. 偏函数应用
5. 回调
6. 生成器与协程
7. 递归

这真是个大工程啊，算是复习总结吧。这里涉及python2.x和python3.x，如果在mac下安装python3则可以使用`pyenv`.

	brew install pyenv
	pyenv install -v 3.3.1
	
安装可参考[pyenv的安装和使用](http://v2in.com/pyenv-installation-and-usage.html),安装过程有问题则看[Common build problems](https://github.com/yyuu/pyenv/wiki/Common-build-problems)。

	
# No1.函数使用技巧
`*`或`**`参数构造接受任意数量参数的函数。注意在2.x只能这样用：

	def a(x, y, *args, **kwargs): pass
	
但是在3.x 还可以在`*`参数后面仍然可以定义其他参数, 如：

	Python 3.3.1 (default, Jan 27 2016, 15:20:22) 
	>>> def a(x, *args, y):pass
	... 
	>>> def b(x, *args, y, **kwargs): pass
	... 

这种参数形式在3.x 就是**强制关键字参数**, 将强制关键字参数放到某个`*`参数或者当个`*`后面就能达到这种效果:

	# python 3.x
	def recv(maxsize, *, block): pass
	
	recv(1024, True) # TypeError
	recv(1024, block=True) # Ok

3.x 给函数添加注解等元信息很有意思，当然2.x就不能这样用了，因为语法都™变了,注意仅仅是注解而已，然并卵。

	# python 3.x
	>>>def add(x:int, y:int) -> int:pass
	... 
	>>> help(add)
	>>> add.__annotations__
	{'x': <class 'int'>, 'y': <class 'int'>, 'return': <class 'int'>}

# No2.闭包
>就是使内部函数可以访问定义在外部函数中的变量

在《python cookbook》[**7.9 将单方法的类转换为函数**](http://python3-cookbook.readthedocs.org/zh_CN/latest/c07/p09_replace_single_method_classes_with_functions.html) 上的例子特别好。用类的好处是我可以记录被定义的变量在方法中使用，如果类很简单的话，用闭包更加优雅些。

>简单来讲，一个闭包就是一个函数， 只不过在函数内部带上了一个额外的变量环境。闭包关键特点就是它会记住自己被定义时的环境。任何时候只要你碰到需要给某个函数增加额外的状态信息的问题，都可以考虑使用闭包。

# No3.装饰器

陈皓老师的这篇[《Python修饰器的函数式编程》](http://coolshell.cn/articles/11265.html)是我学习装饰器的启蒙，写的太好了。

装饰器就是一个闭包的应用，可拆分为函数装饰器和类装饰器，基本含义就是：

- 函数装饰器： 不管嵌套多少层闭包函数，如果第一层函数无额外参数，则都是将要装饰的函数作为参数引入；如果有额外参数则你第二层函数必须则都是将要装饰的函数作为参数引入。 说的太晦涩了，本质就是**函数作为参数引入然后执行。**， 你可参考[我这个项目用的装饰器](https://github.com/BeginMan/theme-english-api/blob/master/Tenglish/db/__init__.py)
- 类装饰器：需要`__init__()`给某个函数decorator时被调用，需要有一个`fn`的参数，也就是被decorator的函数。同时定义`__call__()`，这个方法是在我们调用被decorator函数时被调用的。

python装饰器的例子一大堆，各种web框架也有。

# No4.函数式编程
说实话，我确实不熟悉函数式编程， 写这篇博客是总结和复习。想要了解更多除了google外还需要多看别人的代码。这里推荐：[**Python函数式编程指南：目录和参考**](http://www.cnblogs.com/huxi/archive/2011/07/15/2107536.html)

## 4.1 lambda
对lambda的理解就是：

- 匿名函数，不用def定义和return显式返回
- lambda表达式允许你定义简单函数，使用有限制。
- 只能指定单个表达式，它的值就是最后的返回值

如：

	>>> sorted(names, key=lambda name: name.split()[-1].lower())

name是参数，name.split()[-1].lower()是返回值。

在使用lambda表达式会出现捕获变量值的异常，如下：

	>>> x = 10
	>>> a = lambda y: x+y
	>>> x = 100
	>>> b = lambda y: x+y
	>>> a(10)
	110
	>>> b(10)
	110

原因是：

>lambda表达式中的x是一个自由变量，在运行时绑定值，而不是定义时就绑定，这跟函数的默认值参数定义是不同的。 因此，在调用这个lambda表达式的时候，x的值是执行时的值。

想让某个匿名函数在定义时就捕获到值，可以将那个参数值定义成默认参数即可：
	
	>>> x = 10
	>>> b = lambda y, x=x: x+y
	>>> x = 1000
	>>> b(10)
	20

此类问题还会出现在列表推导上：
	
	>>> funcs = [lambda x: x+n for n in range(5)]
	>>> for f in funcs:
	... print(f(0))
	...
	4
	4
	4
	4
	4
	>>>

## 4.2 filter
内置函数，`help(filter)`查看详情。filter的意思就是过滤，过滤条件就是filter第一个参数是函数或None, 过滤内容就是第二个参数sequence. 返回过滤后的sequence。

    filter(function or None, sequence) -> list, tuple, or string  

注意：

- 如果第一个参数为function,那么返回条件为真的序列(列表，元祖或字符串)
- 如果第一个参数为None的话,那么返回序列中所有为True的项目

如下实例：
	
	>>> filter(None, [1, 2, 0, True, False])
	[1, 2, True]
	>>> filter(lambda x: x.endswith('.py'), ['a.c', 'app.py', 'demo.js'])
	['app.py']
                  	  
## 4.3 map
map意思是匹配，如何匹配，第一个参数func就是how, 对一个及多个序列(第二个参数seq)执行同一个操作(func)，返回一个列表。	

    map(function, sequence[, sequence, ...]) -> list  

注意：

- 如果function为None则seqs组合
- 如果function不为None则seqs执行同一操作
- 如果多个seq则function需要对应的多个参数

如下实例：

	>>> map(lambda x: x+1,[1,2,3,4])  
	[2, 3, 4, 5]
	
	>>> map(lambda x, y: x+y+1,[1,2,3,4], [5,6,7,8])
	[7, 9, 11, 13]
	
	>>> map(None, [1,2,3,4], [5, 6])
	[(1, 5), (2, 6), (3, None), (4, None)]

	>>> import operator
	>>> map(operator.gt, [1, 2, 4], [0, 4, 2])
	[True, False, True]

	# 求1-10直接偶数的平方列表
	>>>map(lambda x: x**2, filter(lambda x: x%2 == 0, range(1, 10)))
	[4, 16, 36, 64]
	
## 4.4 reduce

reduce是减少的意思，如何减少，就是第一个参数function的逻辑了，它只能是一个**二元函数**，减少的对象这是第二个参数seq。注意function有两个参数，第一个是初始值init，如果没有则是seq的第一个元素，那么第二个参数则是seq的第二个元素。

	reduce(function, sequence[, initial]) -> value  
	
注意:

- function不能是None, 只能有两个参数
- 只能有一个sequence
- 在Python3.0里面必须导入functools模块,from functools import reduce

如下实例：
	
	>>> reduce(lambda x, y: x+y, [1, 2, 3])
	6
	>>> reduce(lambda x, y: x+y, [1, 2, 3], 100)
	106


## 4.5 apply
apply是应用的意思，这个。。不好编下去了，相当于给一堆乐高，自己搭一个屋子一样，需要第一个参数是房子的模型，这是是object， 第二个参数是乐高素材，这是是参数(args,kwargs).

    apply(object[, args[, kwargs]]) -> value  

如下实例：

	>>> def func1(): pass
	... 
	>>> def func2(*args, **kwargs): pass
	... 
	>>> apply(func1)
	>>> apply(func2, (1, 2, 3), {"name":"BeginMan", "city": "BeiJing"})
		
这个我们在多进程，多线程中经常用。

## 4.6 偏函数应用
从来不知道偏函数是个什么鸟，维基百科也没有解释，应该不算是计算机科学上通用的东西，python的functools模块的partial函数，就是偏函数，Partial的中文意思是：(adj. 局部的；不公平的；偏爱的) 难道是因为这个yy成偏函数？？那它到底是个什么意思呢？偏，偏爱，偏偏....

**它能够固定函数值**， 那么默认参数也可以啊，但是如果这样就不行了：
	
	>>> def add(n=1, m):
	...     pass
	... 
	  File "<stdin>", line 1
	SyntaxError: non-default argument follows default argument

不管在2.x还是3.x上述代码都无法执行， **如果想不受约束，自由的给函数参数赋默认值，那么就要使用偏函数partial**

	>>>from functools import partial
	
	>>> def same(a, b, c, d): 
		... print(a, b, c, d)
	
	>>> s1 = partial(same, 1)
	>>> s1
	<functools.partial object at 0x10755fb50>
	
	>>> s1(2,3,4)
	(1, 2, 3, 4)
	
	>>> s2 = partial(same, d=100)
	
	>>> s2(1, 2, 3)
	(1, 2, 3, 100)
	
	>>> s3 = partial(same, 1, 2, d=100)
	
	>>> s3(1)
	(1, 2, 1, 100)
	
	# 对于有关键字参数
	bin2dec = partial( int, base=2 )
	print bin2dec( '0b10001' )  # 17
	print bin2dec( '10001' )  # 17
	 
	hex2dec = partial( int, base=16 )
	print hex2dec( '0x67' )  # 103
	print hex2dec( '67' )  # 103

如上代码的演示，可知：

>可以看出 `partial()` 固定某些参数并返回一个新的callable对象。这个新的callable接受未赋值的参数， 然后跟之前已经赋值过的参数合并起来，最后将所有参数传递给原始函数。
>
>偏函数是将所要承载的函数作为`partial()`函数的第一个参数，原函数的各个参数依次作为`partial()`函数后续的参数，除非使用关键字参数。
	
《Python Cookbook》提供的例子比较不错，使用 `multiprocessing` 来异步计算一个结果值， 然后这个值被传递给一个接受一个result值和一个可选logging参数的回调函数：
	
	import logging
	from functools import partial
	from multiprocessing import Pool
	
	
	def output_result(result, log=None):
	    if log is not None:
	        log.debug('got:%r', result)
	
	
	def add(x, y):
	    return x + y
	
	
	if __name__ == '__main__':
	    logging.basicConfig(level=logging.DEBUG)
	    log = logging.getLogger('test')
	    p = Pool()
	    p.apply_async(add, (3, 4), callback=partial(output_result, log=log))
	    p.close()
	    p.join()	


# No5.回调
回调比较常见了，在tornado和node.js里很多回调。[tornado.gen](http://tornadokevinlee.readthedocs.org/en/latest/gen.html)例子回调可以用协程`yield`形式代替，往往回调需要**带额外状态信息**， 上面闭包的例子已经说明了，**可以用类或闭包**来带额外的状态信息，在tornado中一般都是在类中，这样的话额外状态信息好处理些，如果类简单的话，用闭包则是更加优雅的方式。

带额外状态信息的回调函数的处理可以总结为：

1. 使用一个绑定方法来代替一个简单函数。就是我们说的类处理方式
2. 作为类的替代，可以使用一个闭包捕获状态值
3. 协程

这个可参考[Python Cookbook 7.10 带额外状态信息的回调函数](http://python3-cookbook.readthedocs.org/zh_CN/latest/c07/p10_carry_extra_state_with_callback_functions.html)

**注意，如果使用闭包的形式，python 3.x 有`nonlocal`声明语句用来指示接下来的变量会在回调函数中被修改。如果没有这个声明，代码会报错。在Python2.x中没有该语法的支持，则可以用可变对象来代替，如列表。**

关于这个例子，可以参考[pytool/func/callback.py](https://github.com/BeginMan/pytool/blob/master/func/callback.py#L39).和[协程这里](https://github.com/BeginMan/pytool/blob/master/func/callback.py#L56)


	
# 参考：

- 《Python Cookbook》
- 《Python 参考手册》
- [ Python常用内置函数介绍【filter,map,reduce,apply,zip】](http://blog.csdn.net/jerry_1126/article/details/41143579)
- [Python函数式编程——偏函数](http://www.pythoner.com/54.html)