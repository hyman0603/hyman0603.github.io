---
layout: post
title: "wks-03:Js this关键字"
category: "一周新技术"
tags: [js,this,周技术]
---

上周对vim配置和vimscript有一点的了解了：[wks-02:Vim配置文件语法学习](http://beginman.cn/2016/11/20/vim-config/)，这周搞一个我的薄弱点。js `this`不是新技术了，但是对我来说还是有点陌生的，毕竟用的时候总是模糊的。那么这周就学习搞懂`this`. 

# 一. 揭秘

Python的`self`与`this`类似，但是Python的`self`**不是关键字**，而是一个参数对象，代表实例对象本身。调用实例方法时会隐式传入它，这与Js的`this`太像了，之前总结过Python的self：[Python OOP 常见疑难点汇总](http://beginman.cn/2015/04/09/Python-OOP/#self)。

>但是Js的this有它特别的地方，JavaScript 的this总是指向一个对象,而具体指向哪个对象是在运行时基于函数的**执行环境动态绑定**的,而非函数被声明时的环境。

也就是说：`this`是一个对象（环境，运行环境也是对象）。

- 全局环境中运行，this就是指顶层对象（浏览器中为window对象, 在node下是node宿主环境对象）
- 在DOM的事件处理，表示当前Dom对象（如文本框）
- 在一个命名空间或作用域中又是它的对象。
- ....

就是**返回'当前'所在对象的属性或方法。**

```js
function f() { return this.name };
var A = {name:'A', callName: f};
var B = {name:'B', callName: f};

console.log(A.callName())   // 'A'
console.log(B.callName())   // 'B'
```

函数f内部使用了`this`关键字，随着f所在的对象不同，this的指向也不同, 但无论指向何处都在当前所在的对象下。

比如Dom操作：

```html
<input onChange="valid(this, arg1, arg2)">
<!--回调函数传入this表示当前文本框对象，可用this.value读取输入的值-->
```

>**this是所有函数运行时的一个隐藏参数，指向函数的运行环境。**



# 二.this的指向

大致分4类：

1. 对象方法调用
2. 函数调用
3. 构造器调用
4. `Function.prototype.call`或`Function.prototype.apply`调用


第1,2上面已经说了，下面主要看看3，4.

## 2.1 构造器调用

也就是`new` 调用函数，返回一个对象，构造器里的`this`就指向这个返回的对象。如下的一道面试题：

![](http://beginman.qiniudn.com/2016-11-27-14802457083152.jpg)


答案如下：

```js
> function obj(name) {
... if (name) {
..... this.name = name;
..... }
... return this;
... }

> obj.prototype.name = "name2";
'name2'
> var a = obj("name1");

> var b = new(obj);

> a.name
'name1'
> b.name
'name2'
```

还要注意一个问题,如果构造器显式地返回了一个 object 类型的对象,那么最终返回这个对象,可能不是我们期待的 this。解决办法就是绑定this。

```js
> var MyClass = function() {
... this.name = 'jack';
... return {   // 显式返回一个对象
..... name: 'rose'
..... }
... };

> var obj = new MyClass();

> obj.name
'rose'


> var MyClass2 = function() {
... this.name = 'jack';
... return { name: this.name}
... }

> var obj2 = new MyClass2();

> obj2.name
'jack'
```

## 2.2 Function.prototype.call 或 Function.prototype.apply

作用：**动态地改变传入函数的 this**

```js
> var a = {name: 'A', getName: function(){ return this.name }}
> var b = {name: 'B'}
> a.getName()
'A'
> a.getName.call(b);
'B'
```

# 三.注意事项

大多数问题出现就是搞不清this的环境，因为this的指向是动态的，所以终极解决方案就是**固定this的指向，固定运行环境！**， 固定方式如下：

1. 中间变量
2. this做参数
3. call、apply、bind来绑定this

如下需要注意的问题：

- 避免多层this，在多层下改用一个指向外层this的变量, 如`var that = this;` 内层引用这个that，也就是使用一个变量固定this的值,嵌套的内层也如此。
- 避免数组处理方法中的this， 如`forEach`等.

如下

```js
var o = {
    v: 'v',
    p: ['a', 'b', 'c'],
    f: function() {
        // 解决方案1： 使用中间变量
        var that = this;
        this.p.forEach(function(item) {
            console.log(that.v + ' ' + item);
        })
    }
}

o.f()

var o2 = {
  v: 'v',
  p: ['a', 'b', 'c'],
  f: function(){
    // 解决方案2：this做forEach第二个参数
    this.p.forEach(function(item){
      console.log(this.v + ' ' + item);
    }, this)
  }
}

o2.f()

```


# 参考资料

- [《JavaScript标准参考教程》](http://javascript.ruanyifeng.com/oop/this.html#toc0)

(完~)


