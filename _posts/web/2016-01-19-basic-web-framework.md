---
layout: post
title: "Web框架列表-循序渐进的学习"
sub-title: "要沉住气，自下而上系统性学习！"
header-img: "img/in-post/shanghai.jpg"
category: "web"
tags: [web]
---
>无论什么时候都不要乱了阵脚，保持清醒，清楚你现在正做什么，想要做什么，如何做好更好。而不是心猿意马，草草了事。 --自勉.

web框架太多了，在Github上的[Web application frameworks](https://github.com/showcases/web-application-frameworks)就有一大堆，不可能每一个都从头到尾学一遍，web框架其实也是有章可循的。


从torando的快速入门[User’s guide](http://www.tornadoweb.org/en/stable/guide.html)和[flask的快速入门](http://docs.jinkan.org/docs/flask/quickstart.html)和[Getting started with Django](https://www.djangoproject.com/start/)。

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/flask-user-guide.png)

## web框架学习列表可总结如下：

- **url route**
	- HTTP 方法
	- 路由规则，正则
	- 静态资源路由
- **表单**
	- 构建表单
	- 表单处理
	- 表单验证
- **request handler 函数**
	- 写一个最简单的request handler 函数
	- 如何从get/post请求中取出参数
	- 如何定义全局url 拦截函数
	- 如何获取/修改/存储 cookie,session数据
	- 如何修改/输出 http header 数据
	- API接口设计(如基于JSON或restful api)， 可参考[HTTP 接口设计指北](https://github.com/bolasblack/http-api-guide)
- **访问数据库**
	- ORM
	- 如何定义/组织/初始化 数据表
	- orm操作
- **模板系统（UI）**
	- 模板文件的目录结构
	- 如何在模板中嵌入代码
	- 模板是否支持继承结构
	- 模板之间如何include
	- 如何自定义模板函数
- **数据处理**
	- json
	- xml
- 如何处理状态码:404和50x
- 如何处理文件上传
- 可选的学习项目
	- 发送email
	- log
	- 图片处理

在[Web frameworks-Common web framework functionality](http://www.fullstackpython.com/web-frameworks.html)：

>These common operations include:

1. URL routing
2. HTML, XML, JSON, and other output format templating
3. Database manipulation
4. Security against Cross-site request forgery (CSRF) and other attacks
5. Session storage and retrieval

在学习一个新的web框架最佳方案就是：

1. 文档先行，看一遍官方文档User's guide
2. 依照**web框架学习列表** 逐个击破
3. 编程实践
4. github找开源项目看一遍，写一遍，重构一遍

上面说的都是应用层的东西，在[关于redis运维与监控方案的思考](http://beginman.cn/redis/2015/12/28/think-for-redis-monitor/)中曾总结从一个web应用开始，需要经过的步骤：

1. 域名解析(DNS)
2. HTTP请求
3. 走N层交换机
3. 走服务器网卡
4. 内核发出系统调用,将内存地址空间中数据(内核缓冲区，网卡控制器)发送到Nginx服务器
5. nginx处理http request
6. nginx将反向到应用程序服务器，如tornado等
7. 应用程序进行数据库(这里分nosql和关系型数据库)操作，连接->db操作->数据网络发送->close…
8. 应用程序处理数据（大部分是CPU密集型）
9. nginx返回数据到用户端
10. 浏览器接收后进行渲染或App Client接收后进行数据展现

则自下而上每层就对应一门相关技术，在上层了解后，则需要花费更多的时间去自下而上学习底层的东西，这样才是一个优秀的后端开发或web开发工程师。

参考：

[5天学会一种 web 开发框架](http://lutaf.com/148.htm)
