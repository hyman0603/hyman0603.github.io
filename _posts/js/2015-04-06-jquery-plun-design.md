---
layout: post
title: "jquery插件开发2：设计模式"
description: "jquery插件开发2：设计模式"
category: "jQuery"
tags: [jQuery]
---

<h2>$.extend</h2>

<p><code>$.extend(){...}</code>,在jQuery命名空间添加静态方法，可以通过$符号调用($.yourfunc()),而不需要DOM元素($('#dom').yourfunc()).</p>

<p>这种方式主要是jQuery辅助功能，并不能利用jQuery强大的选择器.</p>

<pre><code>$.extend({
    sayHi: function(name){
        console.log(name);
    },
    //日志输出
    log: function(msg){
        var now = new Date();
        y = now.getFullYear();
        m = now.getMonth()+1;
        d = now.getDate();
        h = now.getHours()
        min = now.getMinutes();
        s = now.getSeconds();
        time = y+'/'+m+'/'+d+' '+h+':'+min+':'+s;
        console.log(time + ':' + msg)
    }
});

$(function(){
    $.sayHi('fang');
    $.log('great');
})
</code></pre>

<!--more-->

<h2>$.fn.plunName</h2>

<h3>1.入门</h3>

<p><code>$.fn.plunName = function(){...}</code>,往$.fn里添加方法，名字是我们插件的名字.</p>

<pre><code>#所有a链接加红
$.fn.myPlugin = function(){
    //this;       //指代jQuery选择器返回的集合
    this.css('color', 'red')
}

$('a').myPlugin()
</code></pre>

<blockquote>
  <p>我们已经知道this指代jQuery选择器返回的集合，那么通过调用jQuery的.each()方法就可以处理合集中的每个元素了，但此刻要注意的是，在each方法内部，this指带的是普通的DOM元素了，如果需要调用jQuery的方法那就需要用$来重新包装一下。</p>
</blockquote>

<pre><code>$.fn.myPlugin = function() {
    //在这里面,this指的是用jQuery选中的元素
    this.css('color', 'red');
    this.each(function() {
        //对每个元素进行操作
        $(this).append(' ' + $(this).attr('href'));
    }))
}
</code></pre>

<h3>2.支持链式调用</h3>

<p>链式操作的原理就是方法返回对象本身(return this)供下一个方法调用，下一个方法又会返回对象本身(return this)...</p>

<p>所以如果编写插件要支持链式调用，则需要return.</p>

<pre><code>$.fn.myPlugin = function(){
    //添加return使之链式
    return this.css('color', 'red');
}

//然后我们连式操作
$('a').myPlugin().addClass('.btn')
</code></pre>

<p>如果没有在最后return 则上述代码会报错如下： Uncaught TypeError: Cannot read property 'addClass' of undefined</p>

<h3>3.让插件接收参数</h3>

<p>插件的参数最好设计默认参数，可选参数，必需参数。</p>

<blockquote>
  <p>在处理插件参数的接收上，通常使用jQuery的extend方法，上面也提到过，但那是给extend方法传递单个对象的情况下，这个对象会合并到jQuery身上，所以我们就可以在jQuery身上调用新合并对象里包含的方法了，像上面的例子。当给extend方法传递一个以上的参数时，它会将所有参数对象合并到第一个里。同时，如果对象中有同名属性时，合并的时候后面的会覆盖前面的。</p>
  
  <p>利用这一点，我们可以在插件里定义一个保存插件参数默认值的对象，同时将接收来的参数对象合并到默认对象上，最后就实现了用户指定了值的参数使用指定的值，未指定的参数使用插件默认值。</p>
</blockquote>

<pre><code>$.fn.myPlugin = function(options){
    var defaults = {
        'color': 'red',
        'font_': '18px'
    };
    var settings = $.extend(defaults, options);
    return this.css({
        'color':settings.color,
        'fontSize':settings.font_
    });
}

$('a').myPlugin({'color': '#2C9929'})
</code></pre>

<p><strong>使用extend可使默认值改变，为了保护默认值不被感染，一个好的做法是将一个新的空对象做为$.extend的第一个参数，defaults和用户传递的参数对象紧随其后，这样做的好处是所有值被合并到这个空对象上，保护了插件里面的默认值。</strong></p>

<pre><code>....
var settings = $.extend({},defaults, options);//将一个空对象做为第一个参数
</code></pre>

<h3>4.面向对象的插件开发</h3>

<p>面向对象的方式就是使得代码整洁，有组织。如下实例</p>

<pre><code>var Beautifier = function(ele, opt){
    this.$element = ele,
    this.defaults = {
        'color': 'red',
        'font':'13px',
        'textDesc':'none'
    },
    this.options = $.extend({}, this.defaults, opt)
}
//定义Beautifier方法
Beautifier.prototype = {
    beautify:function(){
        return this.$element.css({
            'color':this.options.color,
            'fontSize':this.options.font,
            'textDecoration':this.options.textDesc
        });
    }
}

//在插件使用Beautifier对象
$.fn.beau=function(options){
    //创建Beautifier实例
    var fun = new Beautifier(this, options);
    //调用其方法
    return fun.beautify()
}

//使用
$('a').beau({'font':'14px'})
</code></pre>

<p>通过上面这样一改造，我们的代码变得更面向对象了，也更好维护和理解，以后要加新功能新方法，只需向对象添加新变量及方法即可，然后在插件里实例化后即可调用新添加的东西</p>

<h3>5.匿名函数</h3>

<p>Javascript中定义函数的方式有多种，函数直接量就是其中一种。如var fun = function(){},这里function如果不赋值给fun那么它就是一个匿名函数。好，看看匿名函数的如何被调用。</p>

<pre><code>    //方式1.调用函数，得到返回值，强制运算符使函数调用执行
    (function(x, y){
        console.log(x+y);
        return x+y;
    }(3,4));

    //方式2.调用函数，得到返回值，强制函数直接量执行再返回一个引用，引用再去调用执行

    (function(x, y){
        console.log(x+y);
        return x+y;
    }) (3,40);

    //方式3.使用void
    void function(x){
        console.log(x);
    } (100);
    //方式4.使用-/+运算符
    // +function(x,y){...}(value_x, value_y);
    // --function(x,y){...}(value_x, value_y);
    // ++function(x,y){...}(value_x, value_y);
    -function(x, y){
        console.log(x+y);
        return x+y;
    } (100,1);

    //方式5.使用波浪符(~)
    ~function(x, y){
        console.log(x+y);
        return x+y;
    } (1,2);

    //方式6.匿名函数放在中括号内
    [function(){
        console.log(this);  //window
    }(this)];

    //方式7.匿名函数前加typeof
    typeof function(x, y){
        console.log(x+y);
        return x+y;
    } (-1, 1);

    //方式8.匿名函数前加delete
    delete function(x ,y){
        console.log(x+y);
        return x+y;
    } (100,200);

    //方式9.void function(x){..}(value_x);
    //方式10.new function(x){..}(value_x);
    //方式11.逗号运算符
    1,function(x, y){
        console.log(x+y);
        return x+y;
    }(100,100);

    //方式12.按位异或 1^function(x){..}(value_x);
    //方式13.比较运算符 1&gt;function(x){..}(value_x);
</code></pre>

<h3>6.命名空间</h3>

<p><strong>不要污染全局命名空间，一个好的做法是始终用自调用匿名函数包裹你的代码，这样就可以完全放心，安全地将它用于任何地方了，绝对没有冲突。</strong></p>

<p>也就是将命名空间放在函数内。</p>

<pre><code>(function() {
    ....原先代码..

})();
</code></pre>

<h3>7.将系统变量保存起</h3>

<p><strong>在匿名函数开头加上<code>;</code>防止匿名函数之前的代码因忘加分号而导致匿名函数无法解析</strong></p>

<pre><code>//代码开头加一个分号，
;(function(){
    ...
})()
</code></pre>

<p>为了防止系统变量被污染，我们最好将系统变量传递到匿名函数中。</p>

<pre><code>;(function($, window, document,undefined) {
    ....
}) (jQuery, window, document)
</code></pre>

<p>这样一个安全，结构良好，组织有序的插件编写完成。</p>

<p>全部代码见下：</p>

<pre><code>//使用匿名函数包裹
;(function($, window, document, undefined){
    var Beautifier = function(ele, opt){
        this.$element = ele,
        this.defaults = {
            'color': 'red',
            'font':'13px',
            'textDesc':'none'
        },
        this.options = $.extend({}, this.defaults, opt)
    };
    //定义Beautifier方法
    Beautifier.prototype = {
        beautify:function(){
            return this.$element.css({
                'color':this.options.color,
                'fontSize':this.options.font,
                'textDecoration':this.options.textDesc
            });
        }
    };

    //在插件使用Beautifier对象
    $.fn.beau=function(options){
        //创建Beautifier实例
        var fun = new Beautifier(this, options);
        //调用其方法
        return fun.beautify()
    }

})(jQuery, window, document);
</code></pre>

<p>插件发布这块暂不考虑。</p>

<p>参考:</p>

<p><a href="http://www.cnblogs.com/wayou/p/jquery_plugin_tutorial.html">1.jQuery插件开发精品教程，让你的jQuery提升一个台阶</a></p>

<p><a href="http://www.cnblogs.com/snandy/archive/2011/02/28/1966664.html">2.Javascript中匿名函数的多种调用方式</a></p>
