---
layout: post
title: "43个超实用的JavaScript技巧"
description: "43个超实用的JavaScript技巧"
category: "javascript"
tags: [javascript]
---

<p>长夜漫漫，实在孤寂，浏览网页发现如此美文，遂整理分享之：</p>

<p><img src="http://www.admin10000.com/UploadFiles/Document/201312/27/20131227113356289215.JPG" alt="" /></p>

<p>　　</p>

<h3>1.第一次给变量赋值时，别忘记var关键字</h3>

<p>给一个未声明的变量赋值，该变量会被自动创建为全局变量，在JS开发中，应该避免使用全局变量。</p>

<h3>2.使用===替换==</h3>

<p><code>==</code> (equality) 等同,两边值类型不同的时候，要先进行类型转换，再比较。</p>

<p><code>===</code> (identity) 恒等,不做类型转换，类型不同的一定不等。</p>

<pre><code>[10] === 10    // is false
[10]  == 10    // is true
'10' == 10     // is true
'10' === 10    // is false
[]   == 0     // is true
[] ===  0     // is false
'' == false   // is true but true == "a" is false
'' ===   false // is false
</code></pre>

<h3>3.使用分号来作为行终止字符</h3>

<p>在行终止的地方使用分号是一个很好的习惯，即使开发人员忘记加分号，编译器也不会有任何提示，因为在大多数情况下，JavaScript解析器会自动加上。</p>

<h3>4.使用构造函数创建JavaScript对象</h3>

<p>语法：</p>

<pre><code>var object=new objectname();

//var -- 声明对象变量
//object -- 对象的名称
//new -- new的关键词(JavaScript关键词)
//objectname -- 构造函数名称
</code></pre>

<p>如下例子：</p>

<pre><code>//定义构造函数
function Site(url, name)
{
    this.url = "www.beginman.cn";
    this.name ="BeginMan";
}
//使用构造函数产生一个JavaScript对象的实例
var mysite = new Site();
alert(mysite.url);
</code></pre>

<h3>5.应当小心使用typeof、instanceof和constructor</h3>

<pre><code>var arr = ["a", "b", "c"];
typeof arr;   // return "object" 
arr  instanceof Array // true
arr.constructor();  //[]
</code></pre>

<!--more-->

<h3>6.创建一个Self-calling函数</h3>

<p>这通常会被称为自我调用的匿名函数或立即调用函数表达式（LLFE）。当函数被创建的时候就会自动执行，好比下面这个：</p>

<pre><code>(function(){
    // some private code that will be executed automatically
})();  
(function(a,b){
    var result = a+b;
    return result;
})(10,20)
</code></pre>

<h3>7.给数组创建一个随机项</h3>

<pre><code>var items = [12, 548 , 'a' , 2 , 5478 , 'foo' , 8852, , 'Doe' , 2145 , 119];

var  randomItem = items[Math.floor(Math.random() * items.length)];
</code></pre>

<h3>8.在特定范围里获得一个随机数</h3>

<p>下面这段代码非常通用，当你需要生成一个假的数据用来测试时，比如在最低工资和最高之前获取一个随机值。</p>

<pre><code>var x = Math.floor(Math.random() * (max - min + 1)) + min;
</code></pre>

<h3>9.在数字0和最大数之间生成一组随机数</h3>

<pre><code>var numbersArray = [] , max = 100;

for( var i=1; numbersArray.push(i++) &lt; max;);  // numbers = [0,1,2,3 ... 100]
</code></pre>

<h3>10.生成一组随机的字母数字字符</h3>

<pre><code>function generateRandomAlphaNum(len) {
    var rdmstring = "";
    for( ; rdmString.length &lt; len; rdmString  += Math.random().toString(36).substr(2));
    return  rdmString.substr(0, len);

}
</code></pre>

<h3>11.打乱数字数组</h3>

<pre><code>var numbers = [5, 458 , 120 , -215 , 228 , 400 , 122205, -85411];
numbers = numbers.sort(function(){ return Math.random() - 0.5});
/* the array numbers will be equal for example to [120, 5, 228, -215, 400, 458, -85411, 122205]  */
</code></pre>

<h3>12.字符串tim函数</h3>

<p>trim函数可以删除字符串的空白字符，可以用在Java、C#、PHP等多门语言里。</p>

<pre><code>String.prototype.trim = function(){return this.replace(/^\s+|\s+$/g, "");};
</code></pre>

<h3>13.数组追加</h3>

<pre><code>var array1 = [12 , "foo" , {name "Joe"} , -2458];

var array2 = ["Doe" , 555 , 100];
Array.prototype.push.apply(array1, array2);
/* array1 will be equal to  [12 , "foo" , {name "Joe"} , -2458 , "Doe" , 555 , 100] */
</code></pre>

<h3>14.将参数对象转换为数组</h3>

<pre><code>var argArray = Array.prototype.slice.call(arguments);
</code></pre>

<h3>15.验证一个给定参数是否为数字</h3>

<pre><code>function isNumber(n){
    return !isNaN(parseFloat(n)) &amp;&amp; isFinite(n);
}
</code></pre>

<h3>16.验证一个给定的参数为数组</h3>

<pre><code>function isArray(obj){
    return Object.prototype.toString.call(obj) === '[object Array]' ;
}
</code></pre>

<p>注意，如果toString()方法被重写了，你将不会得到预期结果。或者你可以这样写</p>

<pre><code>Array.isArray(obj); // its a new Array method
</code></pre>

<p>同样，如果你使用多个frames，你可以使用instancesof，如果内容太多，结果同样会出错。</p>

<pre><code>var myFrame = document.createElement('iframe');
document.body.appendChild(myFrame);

var myArray = window.frames[window.frames.length-1].Array;
var arr = new myArray(a,b,10); // [a,b,10]  

// instanceof will not work correctly, myArray loses his constructor 
// constructor is not shared between frames
arr instanceof Array; // fals
</code></pre>

<h3>17.从数字数组中获得最大值和最小值</h3>

<pre><code>var  numbers = [5, 458 , 120 , -215 , 228 , 400 , 122205, -85411]; 
var maxInNumbers = Math.max.apply(Math, numbers); 
var minInNumbers = Math.min.apply(Math, numbers);
</code></pre>

<h3>18.清空数组</h3>

<pre><code>var myArray = [12 , 222 , 1000 ];  
myArray.length = 0; // myArray will be equal to [].
</code></pre>

<h3>19.不要用delete从数组中删除项目</h3>

<p>开发者可以使用split来代替使用delete来删除数组项。与其删除数组中未定义项目，还不如使用delete来替代。</p>

<pre><code>var items = [12, 548 ,'a' , 2 , 5478 , 'foo' , 8852, , 'Doe' ,2154 , 119 ]; 
items.length; // return 11 
delete items[3]; // return true 
items.length; // return 11 
/* items will be equal to [12, 548, "a", undefined × 1, 5478, "foo", 8852, undefined × 1, "Doe", 2154,       119]   */
</code></pre>

<p>或者：</p>

<pre><code>var items = [12, 548 ,'a' , 2 , 5478 , 'foo' , 8852, , 'Doe' ,2154 , 119 ]; 
items.length; // return 11 
items.splice(3,1) ; 
items.length; // return 10 
/* items will be equal to [12, 548, "a", 5478, "foo", 8852, undefined × 1, "Doe", 2154,       119]   */
</code></pre>

<p><strong>delete方法应该删除一个对象属性</strong></p>

<h3>20.使用length属性缩短数组</h3>

<p>如上文提到的清空数组，开发者还可以使用length属性缩短数组。</p>

<pre><code>var myArray = [12 , 222 , 1000 , 124 , 98 , 10 ];  
myArray.length = 4; // myArray will be equal to [12 , 222 , 1000 , 124].
</code></pre>

<p>如果你所定义的数组长度值过高，那么数组的长度将会改变，并且会填充一些未定义的值到数组里，数组的length属性不是只读的。</p>

<pre><code>myArray.length = 10; // the new array length is 10 
myArray[myArray.length - 1] ; // undefined
</code></pre>

<h3>21.使用逻辑符号&amp;&amp;或者||进行条件判断</h3>

<pre><code>var foo = 10;  
foo == 10 &amp;&amp; doSomething(); // is the same thing as if (foo == 10) doSomething(); 
foo == 5 || doSomething(); // is the same thing as if (foo != 5) doSomething();
</code></pre>

<p>也可以用来设置函数参数的默认值：</p>

<pre><code>Function doSomething(arg1){ 
    Arg1 = arg1 || 10; // arg1 will have 10 as a default value if it’s not already set
}
</code></pre>

<h3>22.使用map()方法来遍历数组</h3>

<pre><code>var squares = [1,2,3,4].map(function (val) {  
    return val * val;  
}); 
// squares will be equal to [1, 4, 9, 16]
</code></pre>

<h3>23.舍入小数位数</h3>

<pre><code>var num =2.443242342;
num = num.toFixed(4);  // num will be equal to 2.4432
</code></pre>

<h3>24.浮点数问题</h3>

<pre><code>0.1 + 0.2 === 0.3 // is false 
9007199254740992 + 1 // is equal to 9007199254740992  
9007199254740992 + 2 // is equal to 9007199254740994
</code></pre>

<p>0.1+0.2等于0.30000000000000004，为什么会发生这种情况？根据IEEE754标准，你需要知道的是所有JavaScript数字在64位二进制内的都表示浮点数。开发者可以使用toFixed()和toPrecision()方法来解决这个问题。</p>

<h3>25.使用for-in loop检查遍历对象属性</h3>

<pre><code>//下面这段代码主要是为了避免遍历对象属性。
for (var name in object) {  
    if (object.hasOwnProperty(name)) { 
        // do something with name                    
    }  
}
</code></pre>

<h3>26.逗号操作符</h3>

<pre><code>var a = 0; 
var b = ( a++, 99 ); 
console.log(a);  // a will be equal to 1 
console.log(b);  // b is equal to 99
</code></pre>

<h3>27.计算或查询缓存变量</h3>

<p>在使用jQuery选择器的情况下，开发者可以缓存DOM元素</p>

<pre><code>var navright = document.querySelector('#right'); 
var navleft = document.querySelector('#left'); 
var navup = document.querySelector('#up'); 
var navdown = document.querySelector('#down');
</code></pre>

<h3>28.在将参数传递到isFinite()之前进行验证</h3>

<pre><code>isFinite(0/0) ; // false 
isFinite("foo"); // false 
isFinite("10"); // true 
isFinite(10);   // true 
isFinite(undifined);  // false 
isFinite();   // false 
isFinite(null);  // true  !!!
</code></pre>

<h3>29.在数组中避免负向索引</h3>

<pre><code>var numbersArray = [1,2,3,4,5]; 
var from = numbersArray.indexOf("foo") ;  // from is equal to -1 
numbersArray.splice(from,2);    // will return [5]
</code></pre>

<p>确保参数传递到indexOf()方法里是非负向的。</p>

<h3>30.（使用JSON）序列化和反序列化</h3>

<pre><code>var person = {name :'Saad', age : 26, department : {ID : 15, name : "R&amp;D"} }; 
var stringFromPerson = JSON.stringify(person); 
/* stringFromPerson is equal to "{"name":"Saad","age":26,"department":{"ID":15,"name":"R&amp;D"}}"   */
var personFromString = JSON.parse(stringFromPerson);  
/* personFromString is equal to person object  */
</code></pre>

<h3>31..避免使用eval()或Function构造函数</h3>

<p>eval()和Function构造函数被称为脚本引擎，每次执行它们的时候都必须把源码转换成可执行的代码，这是非常昂过的操作。</p>

<pre><code>var func1 = new Function(functionCode);
var func2 = eval(functionCode);
</code></pre>

<h3>32.避免使用with()方法</h3>

<p>如果在全局区域里使用with()插入变量，那么，万一有一个变量名字和它名字一样，就很容易混淆和重写。</p>

<h3>33.避免在数组里使用for-in loop</h3>

<pre><code>//no
var sum = 0;  
for (var i in arrayNumbers) {  
    sum += arrayNumbers[i];  
}

//good
var sum = 0;  
for (var i = 0, len = arrayNumbers.length; i &lt; len; i++) {  
    sum += arrayNumbers[i];  
}

//better
for (var i = 0; i &lt; arrayNumbers.length; i++)
</code></pre>

<h3>34.不要向setTimeout()和setInterval()方法里传递字符串</h3>

<p>如果在这两个方法里传递字符串，那么字符串会像eval那样重新计算，这样速度就会变慢，而不是这样使用：</p>

<pre><code>//no
setInterval('doSomethingPeriodically()', 1000);  
setTimeOut('doSomethingAfterFiveSeconds()', 5000);

//good
setInterval(doSomethingPeriodically, 1000);  
setTimeOut(doSomethingAfterFiveSeconds, 5000);
</code></pre>

<h3>35.使用switch/case语句代替较长的if/else语句</h3>

<p>如果有超过2个以上的case，那么使用switch/case速度会快很多，而且代码看起来更加优雅。</p>

<h3>36.遇到数值范围时，可以选用switch/case</h3>

<pre><code>function getCategory(age) {  
    var category = "";  
    switch (true) {  
        case isNaN(age):  
            category = "not an age";  
            break;  
        case (age &gt;= 50):  
            category = "Old";  
            break;  
        case (age &lt;= 20):  
            category = "Baby";  
            break;  
        default:  
            category = "Young";  
            break;  
    };  
    return category;  
}  
getCategory(5);  // will return "Baby"
</code></pre>

<h3>37.创建一个对象，该对象的属性是一个给定的对象</h3>

<p>可以编写一个这样的函数，创建一个对象，该对象属性是一个给定的对象，好比这样：</p>

<pre><code>function clone(object) {  
    function OneShotConstructor(){}; 
    OneShotConstructor.prototype= object;  
    return new OneShotConstructor(); 
} 
clone(Array).prototype ;  // []
</code></pre>

<h3>38.一个HTML escaper函数</h3>

<pre><code>function escapeHTML(text) {  
    var replacements= {"&lt;": "&lt;", "&gt;": "&gt;","&amp;": "&amp;", "\"": """};                      
    return text.replace(/[&lt;&gt;&amp;"]/g, function(character) {  
        return replacements[character];  
    }); 
}
</code></pre>

<h3>39.在一个loop里避免使用try-catch-finally</h3>

<p>try-catch-finally在当前范围里运行时会创建一个新的变量，在执行catch时，捕获异常对象会赋值给变量。</p>

<p>不要这样使用：</p>

<pre><code>var object = ['foo', 'bar'], i;  
for (i = 0, len = object.length; i &lt;len; i++) {  
    try {  
        // do something that throws an exception 
    }  
    catch (e) {   
        // handle exception  
    } 
}
</code></pre>

<p>应该这样使用：</p>

<pre><code>var object = ['foo', 'bar'], i;  
try { 
    for (i = 0, len = object.length; i &lt;len; i++) {  
        // do something that throws an exception 
    } 
} 
catch (e) {   
    // handle exception  
}
</code></pre>

<h3>40.给XMLHttpRequests设置timeouts</h3>

<p>如果一个XHR需要花费太长时间，你可以终止链接（例如网络问题），通过给XHR使用setTimeout()解决。</p>

<pre><code>var xhr = new XMLHttpRequest (); 
xhr.onreadystatechange = function () {  
    if (this.readyState == 4) {  
        clearTimeout(timeout);  
        // do something with response data 
    }  
}  
var timeout = setTimeout( function () {  
    xhr.abort(); // call error callback  
}, 60*1000 /* timeout after a minute */ ); 
xhr.open('GET', url, true);  

xhr.send();
</code></pre>

<p>此外，通常你应该完全避免同步Ajax调用。</p>

<h3>41.处理WebSocket超时</h3>

<p>一般来说，当创建一个WebSocket链接时，服务器可能在闲置30秒后链接超时，在闲置一段时间后，防火墙也可能会链接超时。</p>

<p>为了解决这种超时问题，你可以定期地向服务器发送空信息，在代码里添加两个函数：一个函数用来保持链接一直是活的，另一个用来取消链接是活的，使用这种方法，你将控制超时问题。
　　</p>

<pre><code>var timerID = 0; 
function keepAlive() { 
    var timeout = 15000;  
    if (webSocket.readyState == webSocket.OPEN) {  
        webSocket.send('');  
    }  
    timerId = setTimeout(keepAlive, timeout);  
}  
function cancelKeepAlive() {  
    if (timerId) {  
        cancelTimeout(timerId);  
    }  
}
</code></pre>

<p>keepAlive()方法应该添加在WebSocket链接方法onOpen()的末端，cancelKeepAlive()方法放在onClose()方法下面。</p>

<h3>42.记住，最原始的操作要比函数调用快</h3>

<p>对于简单的任务，最好使用基本操作方式来实现，而不是使用函数调用实现。例如</p>

<pre><code>var min = Math.min(a,b); 
A.push(v);
</code></pre>

<p>基本操作方式：</p>

<pre><code>var min = a &lt; b ? a b; 
A[A.length] = v;
</code></pre>

<h3>43.编码时注意代码的美观、可读</h3>

<p>JavaScript是一门非常好的语言，尤其对于前端工程师来说，JavaScript也非常重要，点击 这里可以访问更多优秀的JavaScript资源。</p>

<h3>参考：</h3>

<p><a href="http://modernweb.com/2013/12/23/45-useful-javascript-tips-tricks-and-best-practices/">1.原文来自：45 Useful JavaScript Tips, Tricks and Best Practices</a></p>

<p><a href="http://www.admin10000.com/document/3669.html">2.翻译来自：超实用的JavaScript技巧及最佳实践</a></p>

<p><a href="http://www.dreamdu.com/javascript/define_object/">2.http://www.dreamdu.com/javascript/define_object/</a></p>
