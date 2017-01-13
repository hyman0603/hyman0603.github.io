---               
layout: post   
title: "Python闭包"
description: ""
category: "python"
tags: [python, 闭包]
---

ps; 内容绝大部分属于网络搬运工，自己没什么好总结的。

# 一.闭包概念

概念：**内部函数可以使用外部函数变量的行为，就叫闭包**

```python
def func(name):
    def inner_func(age):
        print ("name:%s, age:%d" % (name, age))
    return inner_func

me = func("Jack")
me(26)

# 上面调用func则产生一个闭包(inner_func), 且持有(捕获)一个自由变量`name`, 当func的生命周期结束后
# name 变量依然存在, 以为它被闭包引用了,不会被回收。
```

**在 python 的函数内，可以直接引用外部变量，但不能改写外部变量，因此如果在闭包中直接改写父函数的变量，就会发生错误：**

![](http://beginman.qiniudn.com/2016-10-17-14764575298235.jpg)

解决办法：**在函数内使用 `global` 语句，但全局变量在任何语言中都不被提倡，因为它很难控制。**

```python
count = 0

def foo():
    def inner():
        global count
        count+=100
        print (count)
    return inner

foo()()         # 100
print count     # 100
```

python 3 中引入了 `nonlocal` 语句解决了这个问题：

```python
def foo():
    count = 0
    def inner():
        nonlocal count
        count+=100
        print (count)
    return inner

foo()()         # 100
```

# 二. 闭包与偏函数的作用

```python
def get_stuff(user, pwd, stuff_id):
    print("get_stuff called with user:%s, pw:%s, stuff_id:%s"
          % (user, pwd, stuff_id))

def partial(fn, *args, **kwargs):
    # 偏函数
    def fn_part(*fn_args, **fn_kwargs):
        kwargs.update(fn_kwargs)
        return fn(*args + fn_args, **kwargs)
    return fn_part

my_stuff = partial(get_stuff, "Jack", "123456")
my_stuff(10)

my_stuff = partial(get_stuff, "Tom")
my_stuff("111111", 100)
```

在`functools`模块中已经写好了`partial`，直接调用即可。

```python
from functools import partial
my_stuff = partial(get_stuff, "Jack")
my_stuff("111", 10)
```

# 三.闭包与装饰器
这个最常见，不BB了。

# 四.闭包作用
>**闭包的最大特点是可以将父函数的变量与内部函数绑定，并返回绑定变量后的函数（也即闭包），此时即便生成闭包的环境（父函数）已经释放，闭包仍然存在，这个过程很像类（父函数）生成实例（闭包），不同的是父函数只在调用时执行，执行完毕后其环境就会释放，而类则在文件执行时创建，一般程序执行完毕后作用域才释放，因此对一些需要重用的功能且不足以定义为类的行为，使用闭包会比使用类占用更少的资源，且更轻巧灵活。** -- 来源：[Python 的闭包和装饰器](https://segmentfault.com/a/1190000004461404)

# 五.闭包常见的问题

[以下的代码的输出将是什么? 说出你的答案并解释？](https://segmentfault.com/a/1190000000618513#articleHeader3)

```python
def multipliers():
    return [lambda x : i * x for i in range(4)]

print [m(2) for m in multipliers()]
```

这里输出[6,6,6,6] 而不是期望的[0, 2, 4, 6]。原因就是内部lambda函数捕获了外部变量`i`, 形成了**闭包**。在执行 `for m in multipliers()`虽然执行了`multipliers()`函数但是变量`i`并未在函数执行后释放，因为此时的内部Lambda函数并未执行，外部函数的`for`循环已经完成了，`i`最后的值是3, 因此，每个返回的函数 multiplies 的值都是 3。

这段代码在知乎上[Python 闭包代码理解？](https://www.zhihu.com/question/31792789)问题有所反馈，将lambda匿名函数改成具名函数会更加清晰写。

```
def multipliers():
    fns = []
    for i in range(4):
        def fn(x):
            return x*i
        fns.append(fn)
    return fns

print [m(2) for m in multipliers()]         # [6, 6, 6, 6]
print m.__closure__[0].cell_contents        # 打印闭包值 即i的值 =3
```

这里我分享了[@胡子](https://www.zhihu.com/people/hu-zi-91-29)的答案，我觉得他讲的非常好。

>1.当函数存在嵌套，并且子函数引用了父函数中的变量，可以访问这些变量的作用域就形成闭包。
>2.如果子函数没有访问父函数中的变量，就不存在闭包。
>打个比方:一个大盒子，内部有一个小盒子，小盒子里用到一些东西是来自这个大盒子，那么这些来自大盒子的东西，就是闭包。

在上面的例子中，变量`i`并没有在内部`fn`函数中定义，所以`fn` 和外部变量`i` 构成闭包，`i`在`range`最后取值为3，因此在`return fns` 这一行的时候，这个闭包里`i` 的值确定了，都是3, 所以在调用内部函数时，结果都是[6,6,6,6].

解决方案：

1. **通过使用默认参数绑定外部变量作为接力棒来消除闭包的影响。**
2. **使用 偏函数`functools.partial`**

先说下第一种方案：

```python
def multipliers():
    fns = []
    for i in range(4):
        def fn(x, j=i):     # 使用中间参数j作为接力棒来暂存外部变量i
            return x*j      # 内部函数则使用中间参数j而非i
        fns.append(fn)
    return fns

print [m(2) for m in multipliers()]         # [0, 2, 4, 6]
print m.__closure__        # 打印闭包值 None, 没有闭包，因为外部变量i已经传值给默认参数j了
```

>`i`每个阶段的值，通过默认参数传入`j`，这时候相当于`j`拿下了这个接力棒，把中间值都保存下来了，这时候每一个内部函数`fn`的构成，没有任何闭包，return之后i就销毁了。

改成lambda的形式则如下：

```python
def multipliers():
    return [lambda x, j=i: x*j for i in range(4)]
```

第二种使用`functools.partial` 函数

```python
from functools import partial

def mul(x, i):
    return x * i

def multipliers():
    return [partial(mul, i) for i in range(4)]

print [m(2) for m in multipliers()]         # [0, 2, 4, 6]
```

这里偏函数存储变量i作为默认参数。






