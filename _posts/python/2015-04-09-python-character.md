---
layout: post
title: "Python字符处理方式"
description: "Python字符处理方式"
category: "python"
tags: [python技巧]
---

<p>python 字符串中文处理都经常会出现异常，如：<code>decode</code>:</p>

<pre><code>UnicodeDecodeError: 'ascii' codec can't decode byte 0xe6 in position 0: ordinal not in range(128)
</code></pre>

<p>或者：<code>encode</code></p>

<pre><code>UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-1: ordinal not in range(128)
</code></pre>

<p>像这种UnicodeEncodeError和UnicodeDecodeError的异常，再或者就是一些乱码问题，往往就是对Python字符集处理的不得当。接下来就要好好分析一下。</p>

<!--more-->

<h2>一.字符集与字符编码</h2>

<p>计算机中储存的信息都是用二进制数表示的，以何种方式存储字符则称为<strong>编码</strong>，将存储的二进制数据展示出来就叫<strong>解码</strong>。如果编码不当则会异常，解码不当则也会异常或乱码。</p>

<h3>1.字符集</h3>

<p>计算机对字符的处理依赖于<strong>字符集(Charset)</strong>，所谓字符集就是各类字符的集合，<strong>常见字符集名称：ASCII字符集、GB2312字符集、BIG5字符集、 GB18030字符集、Unicode字符集等</strong></p>

<p><strong>ASCII:（American Standard Code for Information Interchange， 美国信息互换标准编码）</strong>：是基于罗马字母表的一套电脑编码系统。主要面向于西欧，可显示字符：英文大小写字符、阿拉伯数字和西文符号。以<strong>7位一个字符，共128字符，字符值从0到127，ASCII扩展字符集使用8位(bits)表示一个字符，则共256个字符</strong></p>

<p><strong>GB2312：</strong>，全称为《信息交换用汉字编码字符集·基本集》，由于ASCII主要面向罗马字符，则对于汉字是无法处理的，因此国标码GB2312才就此诞生。</p>

<p><strong>Unicode:(Universal Multiple-Octet Coded Character Set, 通用多八位编码字符集)</strong>:支持现今世界各种不同语言的书面文本的交换、处理及显示.(⊙v⊙)嗯，解决了各国编码混乱和跨平台的问题~。它为每种语言中的每个字符设定了统一并且唯一的二进制编码，以满足跨语言、跨平台进行文本转换、处理的要求。</p>

<p><strong>UTF-32、UTF-16和 UTF-8 是 Unicode 标准的编码字符集的字符编码方案，UTF是 Unicode Tranformation Format的意思，即把Unicode转做某种格式的意思。UTF-8（8-bit Unicode Transformation Format）是一种针对Unicode的可变长度字符编码，又称万国码</strong></p>

<h3>2.字符编码</h3>

<p>字符编码（英语：Character encoding）是把字符集中的字符编码为指定集合中某一对象（例如：比特模式、自然数序列、8位元组或者电脉冲），以便文本在计算机中存储和通过通信网络的传递。</p>

<h2>二.Python字符处理</h2>

<p>Python对字符的处理有str和unicode两种方式，都是basestring的子类。</p>

<pre><code>#判断是否是字符串
def is_string(s):
    return isinstance(s, basestring)


if is_string("你好"): print u"是中文"
</code></pre>

<h3>1.表示方式</h3>

<h4>1.1 str</h4>

<p><strong>str是字节串，由unicode经过编码(encode)后的字节组成的:</strong></p>

<pre><code>unicode -&gt; encode('the_coding_you_want') -&gt; str
</code></pre>

<p>声明方式：</p>

<pre><code>&gt;&gt;&gt; s = '你好'
&gt;&gt;&gt; s2 = u'你好'.encode('utf-8')
&gt;&gt;&gt; s == s2
True
&gt;&gt;&gt; type(s), type(s2)
(&lt;type 'str'&gt;, &lt;type 'str'&gt;)
&gt;&gt;&gt; print s
你好
&gt;&gt;&gt; s
'\xe4\xbd\xa0\xe5\xa5\xbd'
&gt;&gt;&gt; len(s)
6
</code></pre>

<h4>1.2 unicode</h4>

<pre><code>str  -&gt; decode('the_coding_of_str') -&gt; unicode
</code></pre>

<p>声明方式：</p>

<pre><code>&gt;&gt;&gt; u = u'你好'
&gt;&gt;&gt; u2 = '你好'.decode('utf-8')      #unicode才是真正意义上的字符串，由字符串解码，当个字符组成
&gt;&gt;&gt; u3 = unicode('你好', 'utf-8')
&gt;&gt;&gt; u == u2 == u3
True
&gt;&gt;&gt; type(u), type(u2), type(u3)
(&lt;type 'unicode'&gt;, &lt;type 'unicode'&gt;, &lt;type 'unicode'&gt;)
&gt;&gt;&gt; len(u)
2
&gt;&gt;&gt; print u
你好
&gt;&gt;&gt; u
u'\u4f60\u597d'
</code></pre>

<h4>1.3 str和unicode转换</h4>

<p>通过上面代码可知，两者之间的转换通过<code>encode</code>,<code>decode</code>来实现。</p>

<p><strong>str转换unicode</strong>:</p>

<pre><code>str  -&gt; decode('the_coding_of_str') -&gt; unicode
</code></pre>

<p><strong>unicode转换str</strong>:</p>

<pre><code>unicode -&gt; encode('the_coding_you_want') -&gt; str
</code></pre>

<p>其中<a href="http://www.tutorialspoint.com/python/string_decode.htm">decode</a>和<a href="http://www.tutorialspoint.com/python/string_encode.htm">encode</a>语法如下：</p>

<pre><code>def decode(self, encoding=None, errors=None): # real signature unknown; restored from __doc__
    """
    S.decode([encoding[,errors]]) -&gt; object

    Decodes S using the codec registered for encoding. encoding defaults
    to the default encoding. errors may be given to set a different error
    handling scheme. Default is 'strict' meaning that encoding errors raise
    a UnicodeDecodeError. Other possible values are 'ignore' and 'replace'
    as well as any other name registered with codecs.register_error that is
    able to handle UnicodeDecodeErrors.
    """
    return object()

def encode(self, encoding=None, errors=None): # real signature unknown; restored from __doc__
    """
    S.encode([encoding[,errors]]) -&gt; object

    Encodes S using the codec registered for encoding. encoding defaults
    to the default encoding. errors may be given to set a different error
    handling scheme. Default is 'strict' meaning that encoding errors raise
    a UnicodeEncodeError. Other possible values are 'ignore', 'replace' and
    'xmlcharrefreplace' as well as any other name registered with
    codecs.register_error that is able to handle UnicodeEncodeErrors.
    """
    return object() 
</code></pre>

<p>如下实例：</p>

<pre><code>&gt;&gt;&gt; str = "你好"
&gt;&gt;&gt; str = str.encode('base64', 'strict')
&gt;&gt;&gt; str
'5L2g5aW9\n'
&gt;&gt;&gt; str.decode('base64')
'\xe4\xbd\xa0\xe5\xa5\xbd'
&gt;&gt;&gt; print str.decode('base64')
你好
&gt;&gt;&gt; print str.decode('base64', 'strict')
你好
</code></pre>

<p>其中<a href="http://docs.python.org/library/codecs.html#standard-encodings">encoding可选项点击查看</a></p>

<h4>1.4问题重现</h4>

<p>简单原则：不要对str使用encode，不要对unicode使用decode</p>

<pre><code>&gt;&gt;&gt; '中文'.encode('utf-8')
Traceback (most recent call last):
File "&lt;stdin&gt;", line 1, in &lt;module&gt;
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe4 in position 0: ordinal not in range(128)

&gt;&gt;&gt; u'中文'.decode('utf-8')
Traceback (most recent call last):
File "&lt;stdin&gt;", line 1, in &lt;module&gt;
File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/encodings/utf_8.py", line 16, in decode
return codecs.utf_8_decode(input, errors, True)
UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-1: ordinal not in range(128)
</code></pre>

<p><strong>不同编码转换,使用unicode作为中间编码</strong></p>

<pre><code>#s是code_A的str
s.decode('code_A').encode('code_B')
</code></pre>

<h4>1.5 编码建议</h4>

<p><strong>Python中代码中所有字符串都统一使用unicode，而不是str</strong>,对环境编码，IDE/文本编辑器, 文件编码，数据库数据表编码要统一编码。</p>

<p>如Py文件默认是ASCII编码，如果输入非ASCII编码，如输入中文则就报错，处理方式：</p>

<pre><code># -*- coding: utf-8 -*-
或者
#coding=utf-8
</code></pre>

<p>在处理字符串的时候，如：</p>

<pre><code>if s == u'中文':  #而不是 s == '中文'
    pass
#注意这里 s到这里时，确保转为unicode
</code></pre>

<p>要统一编码。</p>

<h2>二.python字符流处理</h2>

<p>对于文件，IDE等字符流，在<a href="http://www.wklken.me/posts/2013/08/31/python-extra-coding-intro.html">wklken</a>的博客中很形象的表示为：</p>

<blockquote>
  <p>python看做一个水池，一个入口，一个出口,入口处，全部转成unicode, 池里全部使用unicode处理，出口处，再转成目标编码(当然，有例外，处理逻辑中要用到具体编码的情况)</p>
</blockquote>

<p><strong>也就是把unicode作为中间码。</strong></p>

<p>如下流程：</p>

<ol>
<li><p>外部输入编码，decode转成unicode</p></li>
<li><p>处理(内部编码，统一unicode)</p></li>
<li><p>encode转成需要的目标编码</p></li>
<li><p>写到目标输出(文件或控制台)</p></li>
</ol>

<p>IDE和控制台报错，原因是print时，编码和IDE自身编码不一致导致</p>

<p>输出时将编码转换成一致的就可以正常输出</p>

<pre><code>&gt;&gt;&gt; print u'中文'.encode('gbk')
����
&gt;&gt;&gt; print u'中文'.encode('utf-8')
中文
</code></pre>

<h2>三.关于Python字符常用处理方式</h2>

<h3>1.获得和设置系统默认编码</h3>

<p>将系统编码设置成utf-8</p>

<pre><code>&gt;&gt;&gt; import sys
&gt;&gt;&gt; sys.getdefaultencoding()
'ascii'

&gt;&gt;&gt; reload(sys)
&lt;module 'sys' (built-in)&gt;
&gt;&gt;&gt; sys.setdefaultencoding('utf-8')
&gt;&gt;&gt; sys.getdefaultencoding()
'utf-8'
</code></pre>

<p>这样的话，默认的编码就是unicode的utf-8形式的了，那么可以直接使用:<code>str.encode('other_coding')</code> 它的流程基本如下：</p>

<pre><code>#str_A为utf-8
str_A.encode('gbk')

#执行的操作是
str_A.decode('sys_codec').encode('gbk')
#这里sys_codec即为上一步 sys.getdefaultencoding() 的编码
</code></pre>

<h3>2.chardet</h3>

<p><a href="https://pypi.python.org/pypi/chardet">chardet</a> 对文件编码方式检测</p>

<pre><code>pip install chardet
</code></pre>

<p>使用：</p>

<pre><code>&gt;&gt;&gt; import chardet
&gt;&gt;&gt; f = open('test.txt','r')
&gt;&gt;&gt; result = chardet.detect(f.read())
&gt;&gt;&gt; result
{'confidence': 0.99, 'encoding': 'utf-8'}
</code></pre>

<h2>参考文档</h2>

<p><a href="http://zh.wikipedia.org/zh/%E5%AD%97%E7%AC%A6%E7%BC%96%E7%A0%81">1.WiKi-字符编码</a></p>

<p><a href="http://baike.baidu.com/view/51987.htm">2.百度百科-字符集</a></p>

<p><a href="http://www.wklken.me/posts/2013/08/31/python-extra-coding-intro.html">3.PYTHON-进阶-编码处理小结</a></p>
