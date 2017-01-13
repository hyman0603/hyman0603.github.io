---
layout: post
title: "jquery插件开发1：基础结构"
description: "jquery插件开发1：基础结构"
category: "jQuery"
tags: [jQuery]
---

<p>jquery插件开发的两种方式：</p>

<p>1.jQuery命名空间下的静态方法，<code>$.extend(dest,src1,src2,src3...);</code></p>

<p>2.jQuery原型下的方法：<code>$.fn.extend(target)</code></p>

<p>接下了对extend方法进行总结。</p>

<!--more-->

<h2>1.$.extend</h2>

<p>extend方法主要做的就是将 src1,scr2...合并到dest中，并返回新合并的对象，此时改变了dest的结构，如果不想改变dest的结构则将"{}"作为dest参数。</p>

<pre><code>var newSrc=$.extend({},src1,src2,src3...)
</code></pre>

<p>extend会再jQuery命名空间下挂载静态方法</p>

<pre><code>//将hello 方法挂在jquery全局对象(jquery命名空间下：$.**)下作为静态方法
$.extend({
    hello: function() {alert("hello");} 
});

//调用
$.hello();              //jquery命名空间
</code></pre>

<p>也可以在jQuery对象扩展其他命名空间</p>

<pre><code>//在jquery对象中扩展一个namespace的命名空间($.namespace.**)
$.extend({ namespace:{} });

//在namespace的命名空间扩展hello方法
$.extend($.namespace, {
    hello: function(){alert('namespace-hello')}
});

//调用
$.namespace.hello();    //jquery下的namespace命名空间
</code></pre>

<p>也可以将方法扩展到jquery原型中($.fn)</p>

<pre><code>$.extend($.fn, {
    hello: function(){alert('fn-hello')}
});

//调用
$.fn.hello();
</code></pre>

<p>合并多个对象：</p>

<pre><code>var Css1={size: "10px",style: "oblique"}
var Css2={size: "12px",style: "oblique",weight: "bolder"}
var newCs = $.extend(Css1, Css2);   //Css2覆盖和嵌入到Css1
console.log('size:'+newCs.size+' '+'style:'+newCs.style+'weight:'+newCs.weight);    //size:12px

var newCs2 = $.extend({}, Css1, Css2);//传递一个空对象作为第一个参数,不会破坏Css1的结构
</code></pre>

<p>深度嵌套：</p>

<p>原型是：<code>extend(boolean,dest,src1,src2,src3...)</code>,第一个参数boolean代表是否进行深度拷贝，其余参数和前面介绍的一致，所谓深度嵌套就是嵌套了子对象，如src1嵌套子对象location:{city:"Boston"}.如下实例：</p>

<pre><code>var result=$.extend( true,  {},  
    { name: "John", location: {city: "Boston",county:"USA"} },  
    { last: "Resig", location: {state: "MA",county:"China"} } 
); 
console.log(JSON.stringify(result));
//合并后的结果：result={name:"John",last:"Resig",location:{city:"Boston",state:"MA",county:"China"}}
</code></pre>

<p>非深度嵌套：</p>

<pre><code>var result=$.extend( false, {},  
    { name: "John", location:{city: "Boston",county:"USA"} },  
    { last: "Resig", location: {state: "MA",county:"China"} }  
); 
console.log(JSON.stringify(result));
//非深度嵌套合并的结果: {"name":"John","last":"Resig","location":{"state":"MA","county":"China"}}
</code></pre>

<h2>2.$.fn.extend(target)</h2>

<p><strong>$.fn本质上是等于jQuery的原型，即$.fn = $.prototype</strong></p>

<pre><code>//将hello1,hello2方法添加到jquery原型中
$.fn.extend({
    hello1: function(){console.log('hello1')},
    hello2: function(){console.log('hello2')},
})

//添加单个方法到jQuery原型中，可使用$.fn.pluginName方法添加
$.fn.myhello = function(){
    console.log('myhello');
};

$.fn.hello1();
$.fn.hello2();
$.fn.myhello();
</code></pre>

<p>下一节学习jquery插件的设计模式。</p>
