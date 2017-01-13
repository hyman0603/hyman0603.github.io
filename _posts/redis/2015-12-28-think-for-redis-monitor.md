---
layout: post
title: "关于redis运维与监控方案的思考"
description: "关于redis运维与监控方案的思考"
category: "redis"
tags: [redis]
---

在app应用服务正在上升期时，运维就越来越重要，对于我们的产品，高度依赖redis,无论是key-value data store、Caching(like memcached)、Real time analysis、Pub/Sub、Queues还是目前集成的Chat Service都将redis视为No1人物，那么对redis进行监控是必要的。在动手之前，我所能google的解决方案如下：

- `redis-benchmark`&monitor:Redis自带的性能测试工具
- `redis-faina`:[Instagram出品](https://github.com/Instagram/redis-faina)的使用redis自带命令monitor的输出结果做分析的python脚本
- redis-live:[web界面的监控工具](https://github.com/nkrode/RedisLive)
- redis-stat: [ruby编成的监控redis的程序](https://github.com/junegunn/redis-stat)，基于`info`命令获取信息，性能比monitor要好

上面的几个大部分都用了，比较推荐redis-live和redis-faina。但是在我们得意洋洋的搭建监控系统后，其实我们的内心也是没谱的，因为运维监控方案是因地制宜的，你需求什么？，你的服务器情况是什么？你要监控哪些东西？你的监控指标是什么？要实现什么目的？等等，不要为了监控而监控，毫无意义。于此，我整理如下：

![](http://beginman.qiniudn.com/think-for-redis-monitor.png)

从运维的角度来看，我们是需要**高可用**的，哪些因素会影响高可用呢？如从一个web应用开始，需要经过的步骤：

1. 域名解析(DNS)
2. HTTP请求
3. 走N层交换机
4. 走服务器网卡
5. 内核发出系统调用,将内存地址空间中数据(内核缓冲区，网卡控制器)发送到Nginx服务器
6. nginx处理http request
7. nginx将反向到应用程序服务器，如tornado等
8. 应用程序进行数据库(这里分nosql和关系型数据库)操作，连接->db操作->数据网络发送->close...
9. 应用程序处理数据（大部分是CPU密集型）
10. nginx返回数据到用户端
11. 浏览器接收后进行渲染或App Client接收后进行数据展现

如下11步为最基础的流程，涉及DNS,交换机，网络I/O,带宽，内存，磁盘I/O,CPU，OS调度，web framework,数据库(mysql,redis,mongodb),那么我们的高可用就如上的涉及方案。

对于初创企业，一没钱无法购置更多服务器，二没用户量，三没时间，那么**如何达到高可用80%**：

- 期初的方案是：**对于单点架构要保证各项服务正常，且有正常的运维监控策略。特别是对于我们这初创企业来说，高性能才是最重要的，通过运维监控角度暂时是为了解决高性能问题。在产品还没有火起来，先保证可用，虽然不是高可用，最起码80%吧。然后运维方案要对症下药，先以最基础的开始，切莫一口吃个胖子，要知道如果没有大用户量，这些花哨都是屠龙之术。**
- 详细的运维方案，如上图，专项监控，做到心中有数。
- 打好基础很重要。
- 善于利用成熟的解决方案，如nagios

做什么之前，先想清楚在行动也不迟！



