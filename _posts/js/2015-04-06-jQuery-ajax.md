---
layout: post
title: "jQuery ajax小结"
description: "jQuery ajax小结"
category: "jQuery"
tags: [jQuery]
---

<h2>jQuery.ajax(url, [data], [callback])</h2>

<p><strong>载入远程HTML文件代码并插入DOM中，注意跨域情况</strong></p>

<pre><code>load(url, [data], [callback])
</code></pre>

<p><code>url</code>: url链接地址或文件，注意可以指定请求的html的DOM插入，如请求'/register'下html中id为pwd2的DOM元素，只将其插入进去，如果不指定DOM元素则插入整个DOM结构。</p>

<p><code>data</code>:如果不存在默认请求方式是get,如果存在则自动转为POST方式，</p>

<p><code>callback</code>: 请求完成的回调函数。</p>

<!--more-->

<p>如下测试：</p>

<pre><code>html
&lt;div class="box"&gt;&lt;/div&gt;

js
//请求url
&lt;script&gt;
$(function(){
    ajaxLoad();     //load
})

//load
function ajaxLoad(){
    //这里加载指定DOM
    $('.box').load('/register #pwd2',function(responseText, textStatus, XMLRequest){
        this;// 这里的this指当前DOM对象即$('.box')
        console.log(responseText);//请求返回的内容
        console.log(textStatus);//请求返回的状态 success,error
        console.log(XMLRequest);//XMLRequest对象
    })
}

//如果请求文件可以这样：

$('.box').load('../static/main.js',function(responseText, textStatus, XMLRequest){....}
</code></pre>

<h2>jQuery.get(url, [data], [callback])</h2>

<p>用get方式进行异步请求</p>

<pre><code>jQuery.get(url, [data], [callback])
</code></pre>

<p><code>url</code>: url链接</p>

<p><code>data</code>: 以QueryString形式附加到url中</p>

<p><code>callback</code>: <strong>请求成功时的回调函数</strong>，只处理成功的时候，不捕获error,如果要处理就用jQuery.ajax.载入成功时回调函数(只有当Response的返回状态是success才是调用该方法)</p>

<pre><code>//get
function ajaxGet(){
    $('.btn').click(function(){
        $.get('/demo/testajax', {name:'fang', age:23}, function(data, textStatus){
            this;   //ajax请求的选项配置信息
            console.log(this);  //输出： Object {url: "/demo/testajax?name=fang&amp;age=23", type: "GET", ....
            console.log(data);//请求成功返回的数据
            console.log(textStatus);//返回的状态，这里只能捕获success,而error时不会运行该回调函数. 这里返回success
        })
    })
}
</code></pre>

<h2>jQuery.post(url, [data], [callback], [type])</h2>

<p>使用post的方式进行异步请求</p>

<pre><code>jQuery.post(url, [data], [callback], [type])
</code></pre>

<p>url,同上，data是Post形式传递.</p>

<p><code>callback</code>: 载入成功时回调函数(只有当Response的返回状态是success才是调用该方法)</p>

<p><code>type</code> (String) : (可选)官方的说明是：Type of data to be sent。其实应该为客户端请求的类型(JSON,XML,等等)</p>

<pre><code>//post
function ajaxPost(){
    datas = {}
    datas._xsrf = getCookie('_xsrf');
    datas.name = 'fang'
    $.post('/demo/ajax',datas, function(data, textStatus){
        this;// ajax请求信息
        //如果你设置了请求的格式为"json"，此时你没有设置Response回来的ContentType 为：Response.ContentType = "application/json"; 那么你将无法捕捉到返回的数据。
        //由于设置了Accept报头为“json”，这里返回的data就是一个对象，并不需要用eval()来转换为对象。

        console.log(data);      //Object {name: "fang"}
        console.log(textStatus);
    }, 'json')
}
</code></pre>

<h2>jQuery.getScript( url, [callback] )</h2>

<p>通过get方式请求并执行一个js文件</p>

<pre><code>jQuery.getScript( url, [callback] ) 
</code></pre>

<p>url：js文件路径</p>

<p>callback:成功载入后回调函数</p>

<pre><code>//getScript
function ajax_getScript(){
    $('.getscript').click(function(){
        $.getScript('../static/test.js', function(){
            alert('test.js载入成功');
        })
    })
}
</code></pre>

<p>jquery 1.2后可以跨域调用js文件</p>

<h2>jQuery.ajax</h2>

<p>通过 HTTP 请求加载远程数据</p>

<p>这是底层的jquery ajax封装，$.ajax() 返回其创建的 XMLHttpRequest 对象。</p>

<p>jQuery 1.2 中，您可以跨域加载 JSON 数据，使用时需将数据类型设置为 JSONP。</p>

<p>参数列表如下：</p>

<p><code>url</code>:  String|(默认: 当前页地址) 发送请求的地址.</p>

<p><code>type</code>:  String|get,post等请求方式</p>

<p><code>timeout</code>:  Number|设置请求超时时间（毫秒）。此设置将覆盖全局设置。</p>

<p><code>async</code>: Boolean|(默认: true) 默认设置下，所有请求均为异步请求。如果需要发送同步请求，请将此选项设置为 false。注意，同步请求将锁住浏览器，用户其它操作必须等待请求完成才可以执行。</p>

<p><code>beforeSend</code>:  Function|发送请求前可修改 XMLHttpRequest 对象的函数，如添加自定义 HTTP 头。XMLHttpRequest 对象是唯一的参数。</p>

<p><code>cache</code>: Boolean|(默认: true) jQuery 1.2 新功能，设置为 false 将不会从浏览器缓存中加载请求信息。</p>

<p><code>complete</code>: Function|请求完成后回调函数 (请求成功或失败时均调用)。参数： XMLHttpRequest 对象，成功信息字符串。</p>

<p><code>contentType</code>: String|(默认: "application/x-www-form-urlencoded") 发送信息至服务器时内容编码类型。默认值适合大多数应用场合。</p>

<p><code>data</code>:  Object,String|发送到服务器的数据。将自动转换为请求字符串格式。GET 请求中将附加在 URL 后。查看 processData 选项说明以禁止此自动转换。必须为 Key/Value 格式。如果为数组，jQuery 将自动为不同值对应同一个名称。如 {foo:["bar1", "bar2"]} 转换为 '&amp;foo=bar1&amp;foo=bar2'。</p>

<p><code>dataType</code>: String|预期服务器返回的数据类型。如果不指定，jQuery 将自动根据 HTTP 包 MIME 信息返回 responseXML 或 responseText，并作为回调函数参数传递，可用值:xml,script,html,json,jsonp</p>

<p><code>error</code>: Function|(默认: 自动判断 (xml 或 html)) 请求失败时将调用此方法。这个方法有三个参数：XMLHttpRequest 对象，错误信息，（可能）捕获的错误对象。function (XMLHttpRequest, textStatus, errorThrown)</p>

<p><code>success</code>: function|请求成功后回调函数。这个方法有两个参数：服务器返回数据，返回状态function (data, textStatus) {...</p>

<p>其他不常用的参数具体见文档，这些Ajax事件里面的 this 都是指向Ajax请求的选项信息的。</p>

<pre><code>$.ajax({
            type: 'post',
            url: '/demo/testajax',
            data: {name:'fang', age:23},
            dataType: 'json',
            beforeSend:function(XMLHttpRequest){
                //ShowLoading
                alert('加载中....')
            },
            success:function(data, textStatus){
                result = eval("(" + data + ")");
                console.log(result);
                alert(result)
            },
            complete:function(XMLHttpRequest, textStatus){
                //HideLoading
                alert('加载完成...')
            },
            error:function(XMLHttpRequest, textStatus, errorThrown){
                console.log(textStatus);
                console.log(errorThrown);
            }

        })
</code></pre>

<p>参考</p>

<p><a href="http://www.cnblogs.com/qleelulu/archive/2008/04/21/1163021.html">jQuery Ajax 全解析</a></p>
