---
layout: post
title: "jsonp原理及在tornado的应用"
category: "web"
tags: [web,tornado]
---
<h2>一.JSONP理解</h2>

<p>对于跨域请求，首先要清楚以下两点：</p>

<ol>
<li>ajax不能跨域请求</li>
<li>凡是拥有"src"这个属性的标签都拥有跨域的能力，比如script、img、iframe</li>
</ol>

<p>清楚了之后在<a href="http://www.cnblogs.com/dowinning/archive/2012/04/19/json-jsonp-jquery.html">【原创】说说JSON和JSONP，也许你会豁然开朗，含jQuery用例</a>中详细介绍了为什么script src这个属性有跨域的能力，以及一些例子，这里不累述。直接上代码吧。</p>

<pre><code>jQuery(document).ready(function(){ 
        $.ajax({
             type: "get",
             async: false,
             url: "http://flightQuery.com/jsonp/flightResult.aspx?code=CA1998",
             dataType: "jsonp",
             jsonp: "callback",//传递给请求处理程序或页面的，用以获得jsonp回调函数名的参数名(一般默认为:callback)
             jsonpCallback:"flightHandler",//自定义的jsonp回调函数名称，默认为jQuery自动生成的随机函数名，也可以写"?"，jQuery会自动为你处理数据
             success: function(json){
                 alert('您查询到航班信息：票价： ' + json.price + ' 元，余票： ' + json.tickets + ' 张。');
             },
             error: function(){
                 alert('fail');
             }
         });
     });
</code></pre>

<p>关于jsonp的原理，整理如下：</p>

<blockquote>
  <p>摘自知乎：本站脚本创建一个“script”元素，地址指向第三方的API网址，形如： 
  “<script src="http://www.example.net/api?param1=1&param2=2"></script> ”
  并提供一个回调函数来接收数据（函数名可约定，或通过地址参数传递）。 
  第三方产生的响应为json数据的包装（故称之为jsonp，即json padding），形如： 
  callback({"name":"hax","gender":"Male"}) 
  这样浏览器会调用callback函数，并传递解析后json对象作为参数。本站脚本可在callback函数里处理所传入的数据。</p>
</blockquote>

<p><strong>在使用jsonp过程中要注意几点：</strong></p>

<ol>
<li>只能get方式</li>
<li>dataType:jsonp,而非json.</li>
<li>ajax和jsonp虽然这两种技术在调用方式上“看起来”很像，目的也一样，都是请求一个url，然后把服务器返回的数据进行处理，因此jquery和ext等框架都把jsonp作为ajax的一种形式进行了封装；其实本质上是不同的东西。ajax的核心是通过XmlHttpRequest获取非本页内容，而jsonp的核心则是动态添加“script”标签来调用服务器提供的js脚本。</li>
</ol>

<h2>二.Tornado JSNOP使用</h2>

<p>明白jsnop原理无非就是动态创建script，在tornado中可这样处理：</p>

<pre><code>from tornado.escape import json_encode
obj = { 
    'foo': 'bar',
    '1': 2,
    'false': True 
    }
self.write(json_encode(obj))
outputs:

{"1": 2, "foo": "bar", "false": true}


For a JSONP response:

callback = self.get_argument('callback')
//处理数据
obj = doSomething.... 

jsonp = "{jsfunc}({json});".format(jsfunc=callback,json=json_encode(obj))
self.set_header('Content-Type', 'application/javascript')
self.write(jsonp)
</code></pre>
