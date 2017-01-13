---
layout: post
title: "Html5移动web开发基础总结"
description: "Html5移动web开发基础总结"
category: "web"
tags: [web]
---
>莫急，莫急，到用的时候再多查细看做总结。

最近被迫无奈搞了一段时间前端的东西，虽然之前写过点，但都是半瓢水的样子，今天趁着写移动端web的机会，走马观花看了下Html5的相关知识，参考书籍是借同事的《HTML5移动web开发指南》这本书（不推荐看，H5和Css3语法特性没讲多少，倒是讲了一堆jqueryMobile, Sencha Touch, PhoneGap的东西，这不完全抄人家的API么）。花了一天时间翻阅完此书，特此做了些总结。

总结大纲：

- Webkit浏览器引擎
- HTML5页面布局
- HTML5本地存储
- 离线应用
- HTML5 服务器推送事件
- 表单元素
- CSS3

PS. [**HTML5 Tutorial**](http://www.tutorialspoint.com/html5/index.htm)教程挺不错的，中文版在这里[HTML5 Tutorial](http://www.runoob.com/tags/html-reference.html)。可用来查询之用。

# 一.Webkit
webkit是一种开源项目，浏览器引擎，Chrome和Safari都已经内置Webkit引擎，并支持HTML5和CSS3特性，WebKit 内核在手机上的应用也十分广泛，例如 Google 的手机Android、 Apple 的iPhone, Nokia’s Series 60 browser 等所使用的 Browser 内核引擎，都是基于 WebKit。

总结：

- webkit催生了面向移动设备的现代 Web 应用程序
- 大多是浏览器支持，应用广泛
- 支持HTML5和CSS3特性

为了理解webkit作用性，首先看**标准Web浏览器组件**

现代浏览器的组件：

- HTML、XML、CSS、JavsScript解析器
- Layout
- 文字和图形渲染
- 图像解码
- GPU(Graphics Processing Unit, 图形处理器)交互
- 网络访问
- 硬件加速

这里前两个是WebKit浏览器共享的，其他部分每个WebKit都有各自的实现，所谓的“port”。

智能手机的移动web特点：

- 有限的屏幕尺寸
- 触屏，缩放
- 硬件设备提升
- 基于webkit内核

# 二.HTML5页面布局

h5新特性：

- 新的语义化元素，见下
- 表单2.0, 主要增加了input新属性和类型
- 持久化本地存储
- websocket: 用于web应用程序的下一代双向通信技术
- 服务器推送事件：SSE
- Canvas绘图
- 音频和视频
- 地理位置
- 微数据
- 拖放

## 1 HTML5新语义元素

h5添加的新语义元素有：`section`,`header`,`footer`,`nav`,`article`,`mark`等。

- `header`: 表示文档头部导航信息
- `footer`: 文档尾部信息，而联系信息则可配合`address`标签
- `nav`:定义构建导航，显示导航链接，比如头部导航，页脚站点导航等。`<nav><ul><li><a>..`
- `aside`:定义一个区块，装载非正文类内容，如广告，侧边栏等
- `article`:定义一块独立的文章内容，表示文档，页面，如一则网站新闻或博客，`<articel><header><h1>这是标题<h1></header><div>这是正文</div><footer>..</footer>`
- `section`: 定义文档中的节，如章节，页眉，页脚或文档中其他部分。适合做一节一节的信息。
- `hgroup`: 对网页或区段的标题元素进行组合，通常用多级别的h1-h6标签节点进行分组。`<hgroup><h1>..</h1><h2>..</h2></hgroup>`
- `audio`:定义音频内容
- `canvas`:定义画布功能
- `command`:定义命令按钮
- `detalist`:定义下拉列表
- `details`:定义一个元素详细内容
- `dialog`:定义对话框
- `keygen`: 定义表单里一个声称的键值
- `mark`: 定义一个有标记的文本
- `output`:定义一些输出类型
- `progress`: 定义任务的过程
- `source`: 定义媒体资源
- `video`: 定义视频内容


如下一个完整示例：
	
	<!DOCTYPE html>
	<html lang="en">
	<head>
	    <meta charset="UTF-8">
	    <title></title>
	</head>
	<body>
	<!--定义页头信息-->
	<header>
	    <h1>Html5</h1>
	    <!--定义导航目录-->
	    <nav>
	        <ul>
	            <li>前言</li>
	            <li>目录</li>
	        </ul>
	    </nav>
	</header>
	
	<!--定义主体内容-->
	<section>
	    <article>
	        <h1>java</h1>
	    </article>
	    <article>
	        <h1>python</h1>
	    </article>
	</section>
	
	<!--定义底部信息-->
	<footer>
	    <nav>
	        <ul>
	            <li>站点1</li>
	            <li>站点2</li>
	        </ul>
	    </nav>
	    <address>&copy;Copyright@2016 &nbsp; BeginMan..</address>
	</footer>
	</body>
	</html>

效果如下：

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-1.png)

## 2.HTML语法

总结：

- 标签名大小写都行
- 属性大小写都行
- 属性的双引号可选
- 属性值可选
- 闭合空元素可选
- DOCTYPE简化，如`<!DOCTYPE html>`
- 字符编码简化，如`<meta charset="UTF-8">`
- script和link标签可以不需要`type`属性

[HTML5属性列表](http://wiki.jikexueyuan.com/project/html5/attributes.html), 其中HTML5 还引入了一个新特性，就是可以添加**自定义数据属性**

自定义数据属性以 `data-` 开头，基于我们的需求命名。下面是一个简单的例子：

	<div class="example" data-subject="physics" data-level="complex">
	...
	</div>

上面的例子中两个叫做 data-subject 和 data-level 的自定义属性在 HTML5 中是完全有效的。我们还可以使用 JavaScript API 或者在 CSS 中以获取标准属性类似的方式获取它们的值。


### 2.1 HTML5事件
事件属性列表，任意事件发生在H5元素上，下列属性可以触发JavaScript代码。

[**事件属性列表**](http://wiki.jikexueyuan.com/project/html5/events.html)

比如`offline`事件属性，文档进入离线状态时触发。等

### 2.2 SVG
SVG（可伸缩矢量图形） 是使用 XML 来描述二维图形和绘图程序的语言。Internet Explorer 9、Firefox、Opera、Chrome 以及 Safari 支持内联 SVG。

H5使用`<svg>...</svg>` 标签嵌入 SVG.

比如这段代码：
	
	<svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="190">
	  <polygon points="100,10 40,180 190,60 10,60 160,180"
	  style="fill:lime;stroke:purple;stroke-width:5;fill-rule:evenodd;" />
	</svg>

<svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="190">
  <polygon points="100,10 40,180 190,60 10,60 160,180"
  style="fill:lime;stroke:purple;stroke-width:5;fill-rule:evenodd;" />
</svg>

更多内容参考：[W3C SVG](http://www.w3school.com.cn/svg/svg_intro.asp)


### 2.3 MathML字符

>MathML 是数学标记语言，是一种基于XML（标准通用标记语言的子集）的标准，用来在互联网上书写数学符号和公式的置标语言。

HTML5 的 HTML 语法允许我们在文档内使用 `<math>...</math>` 标签应用 MathML 元素。

比如如下代码：

	
	<math xmlns="http://www.w3.org/1998/Math/MathML">
	     <mrow>
	        <mrow>
	           <msup>
	              <mi>x</mi>
	              <mn>2</mn>
	           </msup>
	           <mo>+</mo>
	           <mrow>
	              <mn>4</mn>
	              <mo>⁢</mo>
	              <mi>x</mi>
	           </mrow>
	           <mo>+</mo>
	           <mn>4</mn>
	        </mrow>
	        <mo>=</mo>
	        <mn>0</mn>
	     </mrow>
	</math>



<math xmlns="http://www.w3.org/1998/Math/MathML">
     <mrow>
        <mrow>
           <msup>
              <mi>x</mi>
              <mn>2</mn>
           </msup>
           <mo>+</mo>
           <mrow>
              <mn>4</mn>
              <mo>⁢</mo>
              <mi>x</mi>
           </mrow>
           <mo>+</mo>
           <mn>4</mn>
        </mrow>
        <mo>=</mo>
        <mn>0</mn>
     </mrow>
</math>


# 三.HTML5存储
分为WebStorage存储和Web SQL Database

## 3.1 WebStorage
历史图如下：

![](http://pic002.cnblogs.com/images/2011/219983/2011052411382518.jpg)

本地存储两个重要API:

- Web Storage
- 本地数据库Web SQL Database

Web Storage 是HTML4的Cookie存储机制的升级版，提供过两种存储类型API接口：

- sessionStorage：会话期间有效
- localStorage：永久存储本地，除非主动删除

大部分主流浏览器都支持

![](http://pic002.cnblogs.com/images/2011/219983/2011052411384081.jpg)

**严谨点，检查浏览器是否支持Web Storage**
	
	window.localStorage ? console.log("浏览器支持localStorage"): console.log("NO");
	window.sessionStorage ? console.log("浏览器支持sessionStorage"): console.log("NO");

**需要注意的是，HTML5本地存储只能存字符串，任何格式存储的时候都会被自动转为字符串，所以读取的时候，需要自己进行类型的转换**

### 3.1.1 localStorage

特性如下：

- 持久化存储， 声明周期永久，直到主动删除
- 域内安全，任何域内页面都可访问该localStorage数据
- 不同的浏览器中localStorage数据是独立的，无法相互访问，因此同一应用程序在不同设备上保存的数据是不同的

写入操作:

    localStorage.a = 3;
    localStorage['b'] = 'b';
    localStorage.setItem("name", "Python");
    localStorage.setItem("js", JSON.stringify({'name':'jack', 'age': 22}));
    localStorage.setItem("other", [1,2,3,4]);

在Safari调试下，表现形式很好：

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-web-storage.png)


读取与删除：

    console.log(localStorage.getItem('name'));
    var a = parseInt(localStorage.a);
    var b = localStorage['b'];

    //清除
    localStorage.removeItem('js');
    //清除全部
    localStorage.clear();
 	
	//利用length属性和key方法，可以遍历所有的键。
	for(var i = 0; i < localStorage.length; i++){
    	console.log(localStorage.key(i));
	}
	
	//根据位置（索引从0开始）获得键值
	localStorage.key(1);
	
其他操作：
   
- HTML5还提供了一个`key()`方法.
- `length`属性查看存储多少键值对 
- HTML5的本地存储，还提供了一个storage事件，可以对键值对的改变进行监听。

### 3.1.2.sessionStorage
与localStorage类似，其特性如下：

- 声明周期在会话期
- 原理与服务器session功能类似
- 与localStorage一样都继承Storage接口，因此两种API都一样。

### 3.1.3.Storage事件监听
通过标准的事件注册函数`addEventListener`注册，当储存的数据发生变化时，会触发storage事件：

	window.addEventListener("storage",onStorageChange);

	//回调函数接受一个event对象作为参数。这个event对象的key属性，保存发生变化的键名。
	function onStorageChange(e) {
     console.log(e.key);    
	}
	
上面event对象属性有：

- key, 发生变化的键名
- oldValue, 更新前的值, 若新增则为null
- newValue, 更新后的值，若删除则为null, 如clear()全删，则oldValue和newValue都为null
- url：原始触发storage事件的那个网页的网址

>值得特别注意的是，该事件不在导致数据变化的当前页面触发。如果浏览器同时打开一个域名下面的多个页面，当其中的一个页面改变sessionStorage或localStorage的数据时，其他所有页面的storage事件会被触发，而原始页面并不触发storage事件。可以通过这种机制，实现多个窗口之间的通信。所有浏览器之中，只有IE浏览器除外，它会在所有页面触发storage事件。

## 3.2 Web SQL Database

[W3C文档 Web SQL Database](https://www.w3.org/TR/webdatabase/)

对于新版的Safari和Chrome, Opera浏览器都支持，三个核心方法：

- `openDatabase`：使用现有数据库或创建新数据库创建数据库对象。
- `transaction`：允许我们根据情况控制事务提交或回滚。
- `executeSql`：用于执行真实的SQL查询。

如下实例：

    // 使用数据库，无则创建
    var db =openDatabase(
            'mydb',         // 数据库名称
            '1.0',          // 版本号
            'Test DB',      // 描述文件
            2*10*24*1024,   // 数据库大小
            callback        // 创建回调(可选)
    );
    function callback(e){console.log(e)}
    // 执行查询
    db.transaction(function (tx) {
        // 创建LOGS表
        tx.executeSql('CREATE TABLE IF NOT EXISTS LOGS (id UNIQUE, log)');
        // 插入数据
        tx.executeSql('INSERT INTO LOGS (id, log) VALUES (1, "test log")');
        tx.executeSql('INSERT INTO LOGS (id, log) VALUES (?, ?)', [2, "插入条目传递动态值"]);
    });

    // 读取,使用回调来捕获结果
    db.transaction(function (tx) {
        tx.executeSql('SELECT * FROM LOGS', [], function (tx, results) {
            var len = results.rows.length, i;
            msg = "<p>Found rows:"+ len + "</p>";
            document.querySelector('#status').innerHTML += msg;

            for(i=0; i<len; i++){
                console.log(results.rows.item(i).log)
            }
        }, null)
    })
   
在chrome下可见：

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-web-db.png)
   
# 四.离线应用

除了**IE不支持外，其他主流都支持。**, 那么在使用过程中需要检查是否支持了：

	if(window.applicationCache){
		//浏览器支持离线应用
	}

我们可通过H5 onLine判断是否处于离线状态:

	if(!window.navigator.onLine){
		//离线..
	}

关于离线应用实现如下：

- Cache Manifest，后缀名为minifest的文件定义那些需要缓存的文件，H5新增manifest属性来指定文件，如：`<html lang="en" manifest="index.manifest">`
- applicationCache: html5中引入了js操作离线缓存的方法

![](http://yanhaijing.com/blog//164.png)

# 五. HTML5 服务器推送事件
Web 服务器到 Web 浏览器的事件流，被称作服务器推送事件（SSE）,**这个事件流方法会打开一个到服务器的持久连接，新消息可用时发送数据到客户端，从而不再需要持续的轮询。**

检测浏览器是否支持SSE：

	if (!!window.EventSource) {
	  // ...
	}

总结：

- 单向消息传递,允许网页获得来自服务器的更新
- 所有主流浏览器均支持服务器发送事件，除了 IE
- `<eventsource>` 元素的 src 属性应该指向一个 URL，这个 URL 应该提供一个 HTTP 持久连接用于发送包含事件的数据流。
- 或者JS创建`EventSource`对象，参数为url
- SSE 服务器应该发送 Content-type 头指定类型为 `text/event-stream`
- SSE 服务器应规定 输出发送格式（始终以 "data: ","id:", "event:" 开头）
- 客户端有open，message，error事件，也可以自定义事件
- SSE默认支持断线重连

下面是基于flask实现的SSE服务端和客户端代码,[flask-sse.py](https://gist.github.com/BeginMan/514d8189a6ce98d12a7b)


推荐阅读：

- [**HTML5 服务器推送事件（Server-sent Events）实战开发**](http://www.ibm.com/developerworks/cn/web/1307_chengfu_serversentevent/)
- [SSE：服务器发送事件](http://javascript.ruanyifeng.com/htmlapi/eventsource.html)


# 六.表单元素

## 1.新属性

### 1.1.placeholder属性
未输入状态的文本框内容提示

    <input type="text" placeholder="请输入内容">

### 1.2.autofocus属性
指定控件自动获得焦点，只能有一个控件设置，如果设置多个则以最后一个为准。

    <input type="text" placeholder="请输入内容" autofocus>

### 1.2 其他

OPera浏览器对html5新表单属性支持的比较多，chrome和safari相对较少。如下仅Opera支持的表单属性：

- autocomplete: 自动完成，有on/off两值
- required: 必填项

在[**HTML5 表单属性**](http://www.w3school.com.cn/html5/html_5_form_attributes.asp)可以看到新表单属性和浏览器支持程度。

## 2.移动web表单的input类型

### 2.1.search类型文本
检索，与普通文本最大区别就是样式，chrome和safair是圆角的。

### 2.2.email类型文本
在其他浏览器上与普通文本一样，**但是在iPhone Safair上则会提供默认输入法英文键盘，用于输入Email.**

	<input type="email" />
	
### 2.3.number类型文本
number类型文本配合min, max, step属性可构造最大max,最小min,逐步为step的数字类型文本，在chrome和safari都支持，如下：

    <input type="number" min="1" max="10" step="2" style="width: 100px; font-size: 30px">



![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-input-number.png)

那么在iPhone Safair中则显示数字键盘：

### 2.4.ragne类型文本
chrome和safair, iOS都支持该类型，

    <input type="range" min="1" max="10" step="2">
    

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-input-range.png)

### 2.5.tel类型文本
提供输入电话号码的类型文本，在iPhone Safair下效果如下：

    <input type="tel" placeholder="请输入您的电话号码">


![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-input-tel.png)

### 2.6.url类型文本
输入网址，在iPhone Safair下切换到英文输入法键盘.

### 2.7.日期选择器

HTML5 拥有多个可供选取日期和时间的新输入类型：

- date - 选取日、月、年
- month - 选取月、年
- week - 选取周和年
- time - 选取时间（小时和分钟）
- datetime - 选取时间、日、月、年（UTC 时间）
- datetime-local - 选取时间、日、月、年（本地时间）

如下在iPhone Safair下的表现

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-input-date.png)


![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/h5-input-datetime-local.png)

更多特性可参考:[**HTML5 Input 类型**](http://www.w3school.com.cn/html5/html_5_form_input_types.asp)

# 七. CSS3

资料教程：

- [W3C-CSS3 教程](http://www.w3school.com.cn/css3/index.asp)
- [w3cplus 前端](http://www.w3cplus.com/)

**这里主要学习viewport和Media Queries的用法。**

## 1. viewport

>viewport是Apple解决移动版Safari的屏幕分辨率大小问题引入的viewport虚拟窗口，它的作用就是允许开发者创建一个虚拟的窗口(viewport),并自定义其大小或缩放功能。

考虑到移动设备的分辨率相对于桌面电脑来说都比较小，所以为了能在移动设备上正常显示那些传统的为桌面浏览器设计的网站，移动设备上的浏览器都会把自己默认的viewport设为980px或1024px（也可能是其它值，这个是由设备自己决定的），但带来的后果就是浏览器会出现横向滚动条，因为浏览器可视区域的宽度是比这个默认的viewport的宽度要小的。下图列出了一些设备上浏览器的默认viewport的宽度。

![](http://images.cnitblog.com/blog/130623/201407/300958470402077.png)

除了Safair其他浏览器也支持viewport。**viewport有利于移动 web 站点跨设备显示效果基本一致.**

基础写法:

	<meta 
		name="viewport" 
		content="width=device-width, 
					initial-scale=1.0, 
					maximum-scale=1.0, 
					user-scalable=0" />

参数解释：

- `width`: 控制Viewport的宽度,可以指定一个值或者设备的宽度,如`device-width`为设备的宽度(单位为设备缩放比例1:1的像素, 表示此宽度不依赖于原始象素(px)，而依赖于屏幕的宽度),这里设置的宽度等于设备宽度;
- `initial-scale`: 初始缩放,即页面初始缩放程度.对应的值是一个浮点值,这里是一个乘积关系,页面呈现大小等于设置的宽度乘以initial-scale的值;
- `maximum-scale`: 最大缩放,即允许用户缩放的最大比例,也是乘积关系.一般设置为1:1的比例不会让用户缩放的;
- `minimum-scale`: 最小缩放,如上;
- `user-scalable`:用户是否可以手动缩放,一般值设为no,不允许用户缩放;

这段代码的大意是让viewport的物理宽度等于设备的分辨率,不允许用户缩放.

## 2. Media Queries
媒体查询的意思，如下：
	
	<link rel="stylesheet" media="screen and (max-width: 600px)" href="small.css" />

上面代码的意思是：当页页宽度小于或等于600px,调用small.css样式表来渲染你的Web页面。

包含三点：

- 媒体类型（Media Type）， 如all（全部）,screen（屏幕）,print（页面打印)
- 关键词, 如and
- 媒体特性（Media Query), 如`（max-width:600px）`

在样式表中可以这样：
	
	@media screen and (max-width: 600px) {
    选择器 {
      		属性：属性值；
    	}
  	}

详见：[**CSS3 Media Queries**](http://www.w3cplus.com/content/css3-media-queries)

# 参考

- [**【原】移动web资源整理(强烈推荐)**](http://www.cnblogs.com/PeunZhang/p/3407453.html)
- [开发者需要了解的WebKit](http://www.infoq.com/cn/articles/webkit-for-developers)
- [HTML5 LocalStorage 本地存储](http://www.cnblogs.com/xiaowei0705/archive/2011/04/19/2021372.html)
- [Web Storage：浏览器端数据储存机制](http://javascript.ruanyifeng.com/bom/webstorage.html)
- [HTML5 离线缓存-manifest简介](http://yanhaijing.com/html/2014/12/28/html5-manifest/)
- 《HTML5移动web开发指南》

# 修订历史

- 2016-02-24：初稿
- 2016-02-25：看完《HTML5 中文教程》添加HTML语法，Web SQL Database和SSE推送事件

