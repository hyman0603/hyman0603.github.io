---
layout: post
title: "Python 猴子补丁"
description: "Python 猴子补丁"
category: "python"
tags: [python技巧]
---

<p>我们知道Python是动态类型的编程语言，当我们在定义类后对类或实例的操作往往可以动态改变它，如下：</p>

<pre><code>class Foo(object):
    def bar(self):
        print 'FOO.bar'

def bar(self):
    print 'Module.bar'

def other(self):
    print 'Other things'

Foo().bar()             # FOO.bar

# 动态修改
Foo.bar = bar
Foo().bar()             # Module.bar

# 动态添加
Foo.other = other
Foo().other()           # Other things

# 动态删除
del Foo.bar
print Foo.__dict__      # {'other': &lt;function other at 0x106a492a8&gt;, ...}
</code></pre>

<p>像这样<strong>在动态语言中，不去改变源码而对功能进行追加和变更就叫做<code>Monkey Patching</code>（猴子补丁）</strong>,实现这个得益于：</p>

<ul>
<li>动态类型的特性</li>
<li>Python一切皆对象，函数在Python中可以像变量一样传递</li>
<li>Python namespace开放性，这样可以任意替换模块</li>
</ul>

<p>使用猴子补丁目的：</p>

<ul>
<li>追加功能 </li>
<li>功能变更 </li>
<li>修正程序错误 </li>
<li>增加钩子，在执行某个方法的同时执行一些其他的处理，如打印日志，实现AOP等， </li>
<li>缓存，在计算量很大，结算之后的结果可以反复使用的情况下，在一次计算完成之后，对方法进行替换可以提高处理速度。 </li>
</ul>

<p>这样就达到了<code>hot patch</code>的特性，猴子补丁这种东西充分利用了动态语言的灵活性，可以对现有的语言Api进行追加，替换，修改Bug，甚至性能优化等等。比如<code>gevent</code>的猴子补丁就可以对ssl、socket、os、time、select、thread、subprocess、sys等模块的功能进行了增强和替换.</p>

<p><b style="color:red">todo: 研究gevent以及其中猴子补丁的实现</b></p>

<p>在使用猴子补丁的时候，还应注意如下事项：</p>

<ol>
<li>基本上只追加功能，尽量避免大规模的API覆盖 </li>
<li>进行功能变更时要谨慎，尽可能的小规模 </li>
<li>注意相互调用</li>
</ol>

<p>参考：<a href="http://ningandjiao.iteye.com/blog/1567759">Ruby之猴子补丁</a></p>
