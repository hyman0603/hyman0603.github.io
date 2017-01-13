---
layout: post
title: "TLS,SSL,HTTPS with Python"
category: "python"
tags: [python,TLS,SSL,HTTPS,UNP]
---

需要了解的背景知识：

- 术语 HTTPS,SSL,TLS
- 长连接与短连接的关系
- 了解 CA 证书
- 基本流程

# 一.术语扫盲

## 1.什么是SSL？

SSL(Secure Sockets Layer, 安全套接字)，因为原先互联网上使用的 HTTP 协议是明文的，存在很多缺点——比如传输内容会被偷窥（嗅探）和篡改。发明 SSL 协议，就是为了解决这些问题。

## 2.那么什么是TLS呢？

到了1999年，SSL 因为应用广泛，已经成为互联网上的事实标准。IETF 就在那年把 SSL 标准化。标准化之后的名称改为 TLS（是“Transport Layer Security”的缩写），中文叫做“传输层安全协议”。

很多相关的文章都把这两者并列称呼（SSL/TLS），因为这两者可以视作同一个东西的不同阶段。

## 3.那么什么是HTTPS呢？

HTTPS = HTTP + SSL/TLS, 也就是 HTTP over SSL 或 HTTP over TLS.这是后面加`S`的由来

![Untitled Image](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/Users/fangpeng/Documents/tmp/1.png)

相对于HTTP:

- http和https使用的是完全不同的连接方式，用的端口也不一样，前者是80，后者是443。
- http的连接很简单，是无状态的；HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络协议，比http协议安全。

# 二.长连接VS短连接

HTTP对TCP的连接使用分为：

- 短连接
- 长连接(又称“持久连接”，或“Keep-Alive”或“Persistent Connection”)

如果是短连接的话，针对每个HTML资源，就会针对每一个外部资源，分别发起一个个 TCP 连接。相反，如果是“长连接”的方式，浏览器也会先发起一个 TCP 连接去抓取页面。但是抓取页面之后，该 TCP 连接并不会立即关闭，而是暂时先保持着（所谓的“Keep-Alive”）。然后浏览器分析 HTML 源码之后，发现有很多外部资源，就用刚才那个 TCP 连接去抓取此页面的外部资源。

注意：

- 在 HTTP 1.0 版本，【默认】使用的是“短连接”（那时候是 Web 诞生初期，网页相对简单，“短连接”的问题不大）
- 在 HTTP 1.1 中，【默认】采用的是“Keep-Alive”的方式。


# 三.HTTPS的设计

HTTPS的设计要兼容HTTP

- HTTPS 还是要基于 TCP 来传输
- 单独使用一个新的协议，把 HTTP 协议包裹起来（所谓的“HTTP over SSL”，实际上是在原有的 HTTP 数据外面加了一层 SSL 的封装。HTTP 协议原有的 GET、POST 之类的机制，基本上原封不动）

关于HTTPS的性能，为了确保性能，SSL 的设计者至少要考虑如下几点：

- 如何选择加密算法（“对称”or“非对称”）？
- 如何兼顾 HTTP 采用的“短连接”TCP 方式？

# 四.简单运行过程

SSL/TLS协议的基本思路是采用公钥加密法，也就是说，客户端先向服务器端索要公钥，然后用公钥加密信息，服务器收到密文后，用自己的私钥解密。

问题：

- 如何保证公钥不被篡改？:解决方法：将公钥放在数字证书中。只要证书是可信的，公钥就是可信的。
- 公钥加密计算量太大，如何减少耗用的时间？解决方法：每一次对话（session），客户端和服务器端都生成一个"对话密钥"（session key），用它来加密信息。由于"对话密钥"是对称加密，所以运算速度非常快，而服务器公钥只用于加密"对话密钥"本身，这样就减少了加密运算的消耗时间。

因此，SSL/TLS协议的基本过程是这样的：

- 客户端向服务器端索要并验证公钥。
- 双方协商生成"对话密钥"。
- 双方采用"对话密钥"进行加密通信。

如下图解:

![Untitled Image](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/Users/fangpeng/Documents/tmp/2.png)

# 五.详解运行过程

如下图示：

![Untitled Image](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/Users/fangpeng/Documents/tmp/3.png)

注意的是，"握手阶段"的所有通信都是明文的

## 1.客户端发出请求（ClientHello）

C向S提供信息如下：

- 支持的协议版本，比如TLS 1.0版。
- 一个客户端生成的随机数，稍后用于生成"对话密钥"。
- 支持的加密方法，比如RSA公钥加密。
- 支持的压缩方法。

## 2.服务器回应（SeverHello）

服务器收到客户端请求后，向客户端发出回应，这叫做SeverHello。服务器的回应包含以下内容。

- 确认使用的加密通信协议版本，比如TLS 1.0版本。如果浏览器与服务器支持的版本不一致，服务器关闭加密通信。
- 一个服务器生成的随机数，稍后用于生成"对话密钥"。
- 确认使用的加密方法，比如RSA公钥加密。
- 服务器证书。

除了上面这些信息，如果服务器需要确认客户端的身份，就会再包含一项请求，要求客户端提供"客户端证书"。

## 3.客户端回应

客户端收到服务器回应以后，首先验证服务器证书。如果证书不是可信机构颁布、或者证书中的域名与实际域名不一致、或者证书已经过期，就会向访问者显示一个警告，由其选择是否还要继续通信。

如果证书没有问题，客户端就会从证书中取出服务器的公钥。然后，向服务器发送下面三项信息。

- 一个随机数。该随机数用服务器公钥加密，防止被窃听。
- 编码改变通知，表示随后的信息都将用双方商定的加密方法和密钥发送。
- 客户端握手结束通知，表示客户端的握手阶段已经结束。这一项同时也是前面发送的所有内容的hash值，用来供服务器校验。

现在总共有3个随机数，第三个又称"pre-master key”，有了它以后，客户端和服务器就同时有了三个随机数，接着双方就用事先商定的加密方法，各自 生成 本次会话 所用的 同一把 "会话密钥"。

## 4.服务器的最后回应
服务器收到客户端的第三个随机数pre-master key之后，计算生成本次会话所用的"会话密钥"。然后，向客户端最后发送下面信息。

- 编码改变通知，表示随后的信息都将用双方商定的加密方法和密钥发送。
- 服务器握手结束通知，表示服务器的握手阶段已经结束。这一项同时也是前面发送的所有内容的hash值，用来供客户端校验。

至此，整个握手阶段全部结束。接下来，客户端与服务器进入加密通信，就完全是使用普通的HTTP协议，只不过用"会话密钥"加密内容。

![Untitled Image](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/Users/fangpeng/Documents/tmp/4.png)

# 六.Https的劣势

不完整总结如下：

- 对数据进行加解密决定了它比http慢
- https协议需要到CA申请证书。

# 七.Python操作SSL

首先创建证书

	openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem
    
实例代码在：[ssl_demo](https://github.com/BeginMan/pytool/tree/master/unp/ssl_demo)

# 七.参考：

- 聊聊HTTPS和SSL/TLS协议
- 图解HTTPS
- SSL/TLS协议运行机制的概述