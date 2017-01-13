---
layout: post
title: "python dict to object"
description: "python dict to object"
category: "python"
tags: [python奇技淫巧]
---
<p>使字典对象具有<strong>句点操作符</strong>的特性，可以从<code>setattr()</code> or <code>__setattr__()</code>方面实现</p>

<pre><code>d = {'a': 1, 'b': {'c': 2}, 'd': ["hi", {'foo': "bar"}]}

class dict2obj(object):
    def __init__(self, dic):
        for k, v in dic.items():
            # if isinstance(v, (tuple, list)):
            #     setattr(self, k, [dict2obj(i) if isinstance(i, dict) else i for i in v])
            # else:
            #     setattr(self, k, dict2obj(v) if isinstance(v, dict) else v)

            if isinstance(v, (tuple, list)):
                self.__setattr__(k, [dict2obj(i) if isinstance(i, dict) else i for i in v])
            else:
                self.__setattr__(k, dict2obj(v) if isinstance(v, dict) else v)


dd = dict2obj(d)
print dd.a
print dd.b.c
print dd.d[0]
print dd.d[1].foo
</code></pre>
