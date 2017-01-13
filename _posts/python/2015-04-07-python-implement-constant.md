---
layout: post
title: "Python常量的实现"
description: "Python常量的实现"
category: "python"
tags: [python技巧]
---
<h1>一.Python常量</h1>

<p>常量指不能改变的量,在Python中没有提供常量的定义方法，因为Python是动态类型的，对于常量这种类型而言没有多大的意义去定义它，在实际项目中我们几乎很少用到。但Python能够提供方法去定义。</p>

<p><img src="http://edutech.xmu.edu.cn/hongen/pc/oa/ac2k/img/ac2k1604.gif" alt="" /></p>

<p>图片来源：<a href="http://edutech.xmu.edu.cn/hongen/pc/oa/ac2k/ac2k1603.htm">洪恩在线 -变量和常量</a></p>

<p>python提供的内置常量有以下几种：<code>False</code>,<code>True</code>,<code>None</code>等，详见<a href="https://docs.python.org/2/library/constants.html"> Built-in Constants </a></p>

<!--more-->

<p>对于常量的定义规则，在PEP 8中这样说：</p>

<blockquote>
  <p>Constants are usually defined on a module level and written in all capital letters with underscores separating words. Examples include MAX_OVERFLOW and TOTAL.</p>
</blockquote>

<p><a href="http://legacy.python.org/dev/peps/pep-0008/#constants">http://legacy.python.org/dev/peps/pep-0008/#constants</a></p>

<p><strong>一种规范：</strong></p>

<blockquote>
  <p>在《改善Python程序的91个建议》中讲到：将常量集中到一个文件中便于维护和修改。</p>
</blockquote>

<h1>二.常量定义的方法</h1>

<h2>1&#46;通过PEP 8命名风格提这类变量代表常量</h2>

<p>这种没有解决根本原因，只不过挂羊头卖狗肉而已，如：</p>

<pre><code>&gt;&gt;&gt; NAME = "JACK"
&gt;&gt;&gt; bool(False)
True
&gt;&gt;&gt; False = 100
&gt;&gt;&gt; bool(False)
True
</code></pre>

<h2>2&#46;通过定义常量类</h2>

<p>在Python文档中讲到<a href="http://docspy3zh.readthedocs.org/en/latest/reference/datamodel.html#attribute-access">自定义属性权限</a> :可以通过重载<code>__setattr__</code>,<code>__getattr__</code>, <code>__delattr__</code>来定制类实例的属性。如：</p>

<pre><code>[python]
#!/usr/bin/env python
# coding=utf-8
class Foo(object):
    #  __getattr__ 只有在访问不存在的成员时才会被调用
    def __getattr__(self, name):
        print &amp;quot;__getattr__&amp;quot;
        return None

    # __setattr__在属性要被赋值时调用
    def __setattr__(self, name, value):
        print '__setattr__'
        # 保存实例字典中， name 是属性名, vaule 是要赋的值
        self.__dict__[name] = value 

    # __delattr__删除属性才被调用
    def __delattr__(self, name):
        print '__delattr__'
        return None

a = Foo()
a.x
a.x = 100
del a.x
[/python]
</code></pre>

<p>运行后结果：</p>

<pre><code>__getattr__
__setattr__
__delattr__
</code></pre>

<p><strong>通过上面实例，接下来定义常量类：</strong></p>

<pre><code>#!/usr/bin/env python
# coding=utf-8
class _const:
    class ConstTypeError(TypeError): pass          # 异常类
    class ConstError(ConstTypeError): pass         # 异常类

    def __setattr__(self, name, value):
        #判断该对象是否存在属性name，若存在则抛出自定义异常ConstTypeError，否则创建该属性。
        if self.__dict__.has_key(name):          
            raise self.ConstTypeError, "Can't rebind const instance attribute (%s)" % name
        # 判断常量名是否大写，若不是则抛出自定义异常ConstError
        if not name.isupper():
            raise self.ConstError, "Constants (%s) must uppercase" % name

        self.__dict__[name] = value

import sys
sys.modules[__name__] = _const()
</code></pre>

<blockquote>
  <p>上述创建一个名为const.py的文件，包含定义的常量类，将_const实例化的对象赋值sys.modules[<strong>name</strong>]，const模块被绑定成_const对象。<strong>name</strong>在首次载入const过程中为’const’，而sys.modules是模块名与已加载模块的dict。</p>
  
  <p>然后在创建一个useConst.py的文件用于集中保存所有常量,使用如下：</p>
</blockquote>

<pre><code>import const
const.name="BeginMan"     
const.NAME='BeginMan'
const.NAME="Jack"

# 运行结果如下：
(1).const.ConstError: Constants (name) must uppercase  
(2).正常
(3).const.ConstTypeError: Can't rebind const instance attribute (NAME)
</code></pre>
