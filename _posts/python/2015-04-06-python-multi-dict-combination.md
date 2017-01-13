---
layout: post
title: "Python技巧（1）：合并字典对象"
description: "Python技巧（1）：合并字典对象"
category: "python"
tags: [python技巧]
---

<p>Python多个字典的合并是项目中常遇到的需求，接下来就总结一番。</p>

<h2>方式1.items()</h2>

<p>字典对象的items()方法返回k-v组成的元祖,通过合并多个字典对象的items()返回的元祖，然后使用内建函数<code>dict()</code>即可组成。</p>

<pre><code>&gt;&gt;&gt; dic1
{'name': 'fang'}
&gt;&gt;&gt; dic2
{'age': 23}
&gt;&gt;&gt; dic1.items()
[('name', 'fang')]
&gt;&gt;&gt; dict(dic1.items() + dic2.items())
{'age': 23, 'name': 'fang'}
</code></pre>

<!--more-->

<h2>方式2.dict内建函数</h2>

<p>首先看下dict的源码：</p>

<pre><code>....省略
    def __init__(self, seq=None, **kwargs): 
    # known special case of dict.__init__
    """
    1.dict() -&gt; 一个新的空字典

    2.dict(mapping) -&gt; new dictionary initialized from a mapping object's
        (key, value) pairs

    3.dict(iterable) -&gt; new dictionary initialized as if via:
        d = {}
        for k, v in iterable:
            d[k] = v

    4.dict(**kwargs) -&gt; new dictionary initialized with the name=value pairs
        in the keyword argument list.  For example:  dict(one=1, two=2)
    # (copied from class doc)
    """
    pass
</code></pre>

<p>dict()从2.3版本起可以接受字典或关键字参数进行调用，但这种调用方式，dict()只接受一个参数（或一组name=value的可变参数），而不会再接受一个字典：</p>

<pre><code>&gt;&gt;&gt; dict(one=1, two=2)
{'two': 2, 'one': 1}

&gt;&gt;&gt; dict(dic1,dic2)
Traceback (most recent call last):
File "&lt;stdin&gt;", line 1, in &lt;module&gt;
TypeError: dict expected at most 1 arguments, got 2
</code></pre>

<p>但是如果第二个参数是<strong>基于字典的可变长函数参数</strong>的话，那么会有意想不到的效果：</p>

<pre><code>&gt;&gt;&gt; dict(dic1, **dic2)
{'age': 23, 'name': 'fang'}
</code></pre>

<p>在这里，**的意思是基于字典的可变长函数参数。</p>

<h2>方式3.update()</h2>

<pre><code>&gt;&gt;&gt; dic1.update(dic2)
&gt;&gt;&gt; dic1
{'age': 23, 'name': 'fang'}
</code></pre>
