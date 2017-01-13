---
layout: post
title: "《第一本Docker书》笔记 4.Docker Node构建app应用"
category: "docker"
tags: [docker, redis, nodejs]
---

目标是把一个使用Express框架，Redis做数据驱动的Node.js应用完全Docker化，将会构建多个容器部署. 整个项目在**[github - docker-node](https://github.com/BeginMan/docker-node)**下。

- 一个Node容器，服务Node应用
- 一个Redis主容器，保存和集群化应用状态
- 两个Redis备份容器，用于集群化应用状态
- 一个logstash日志容器

那么先开始处理目录结构和基础数据吧。

```bash
# 创建主目录并进入
$ mkdir docker-node  && cd "$_"
# 创建各image目录
$ mkdir nodejs logstash redis_base redis_primary redis_replica
# 创建主Dockerfile
$ touch Dockerfile
# 将Dockerfile复制到各个image目录里
$ echo logstash nodejs redis_base redis_primary redis_replica | xargs -n 1 cp Dockerfile

```

Ok,来看下整体目录结构

```bash
tree
.
├── Dockerfile
├── logstash
│   └── Dockerfile
├── nodejs
│   └── Dockerfile
├── redis_base
│   └── Dockerfile
├── redis_primary
│   └── Dockerfile
└── redis_replica
    └── Dockerfile
```

# 一.构建nodejs镜像

Dockerfile内容如下：

```bash
FROM				ubuntu:latest
MAINTAINER			beginman.cn
ENV REFRESHED_AT	2016-11-11

RUN		apt-get -yqq update
RUN		apt-get -yqq install nodejs npm
RUN		ln -s /usr/bin/nodejs /usr/bin/node
RUN		mkdir -p /var/log/nodeapp

ADD			nodeapp /opt/nodeapp/
WORKDIR		/opt/nodeapp
RUN			npm install
VOLUME		["/var/log/nodeapp"]

EXPOSE		3000

ENTRYPOINT	["nodejs", "server.js"]
```

目录结构：

```bash
tree
.
├── Dockerfile
├── build.sh            --> 构建脚本
├── nodeapp             --> node 项目
│   ├── package.json    --> 依赖项
│   └── server.js       --> web服务
├── run.sh              --> run node容器
└── start.sh            --> 开始容器脚本

```

先构建名为 "beginman/nodejs"的node镜像， 执行 build.sh脚本即可。

# 二.构建Redis基础镜像

在redis_base目录下Dockerfile编写构建Redis基础镜像的指令，这个镜像作为基础镜像供其他两个Redis镜像使用，这里只build, 没有run。

基于Dockerfile 构建名为"beginman/redis-base"镜像。

```bash
# redis base image
FROM				ubuntu:latest
MAINTAINER			beginman.cn
ENV REFRESHED_AT	2016-11-12

RUN		apt-get -yqq update
RUN		apt-get -yqq install redis-server redis-tools

# 指定两个卷
VOLUME	[ "/var/lib/redis", "/var/log/redis" ]
EXPOSE	6379
CMD		[]
```

# 三.构建Redis主镜像和Redis从镜像

Redis主、从镜像基于刚才上面创建的 redis-base 基础镜像。
两者Dockerfile分别为：

```bash
# redis-primary
FROM	beginman/redis-base
ENV REFRESHED_AT 2016-11-11

ENTRYPOINT ["redis-server", "--logfile /var/log/redis-server.log"]

# redis-replica
FROM	beginman/redis-base
ENV REFRESHED_AT 2016-11-11

ENTRYPOINT ["redis-server", "--logfile /var/log/redis-replica.log", "--slaveof redis_primary 6379"]
```

来看下到目前为止创建的镜像

```bash
$ ocker images
REPOSITORY               TAG                 IMAGE ID   
beginman/redis-replica   latest              a001514ac61e
beginman/redis-primary   latest              ac7783052df7
beginman/redis-base      latest              e6c9ea05de68
beginman/nodejs          latest              eb4ac7221b6c
```

# 四.创建Redis后端集群

redis_primary目录结构如下：

```bash
.
├── Dockerfile
├── build.sh
└── run.sh
```

然后从redis主镜像中启动一个容器：

```bash
# -h 设置容器主机名(注意别名不能以包含_, _可改成- )，并被本地DNS服务正确解析
docker run -d -h redis-primary \
	--name redis_primary beginman/redis-primary
```

但是`docker logs` 却没有任何输出：

```bash
$ docker logs redis_primary
```

是因为我们设置指令 `ENTRYPOINT ["redis-server", "--logfile /var/log/redis-server.log"]` 的缘故, **redis日志记录到文件了而不是标准输出。所以Docker查看不到任何日志。**

那么检验redis服务器运行状况，可使用之前构建名为"beginman/redis-base"镜像创建的/var/log/redis 卷。

```bash
# 读取redis主日志
$ docker run -ti \
--rm \
--volumes-from redis_primary \
ubuntu \
/bin/bash -c "ls /var/log/redis/ ; echo '============='; cat /var/log/redis/redis-server.log"
```

这里有几点需要注意：

- `-ti` 以交互方式运行一个容器
- **`--rm` 在进程运行完之后自动删除容器**
- **`--volumes-from` 告诉它从redis_primary容器挂载了所有卷**
- 指定一个ubuntu镜像
- **如果 run 运行多个命令，可/bin/bash -c 'xxx'的方式进行。**

可以看到打印的信息了：

```bash
redis-server.log
=============
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 3.0.6 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 1
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

```

接下来创建名为 "redis_replica1" 的从redis容器

```bash
$ docker run -d -h redis-replica1 --name redis_replica1 \
	--link redis_primary:redis_primary \
	beginman/redis-replica
```

**这里通过`--link`标志将redis_primary容器以别名redis_primary连接到Redis从容器。(--link container:alias)**

同样看下Redis从容器的日志：

```bash
$ docker run -ti \
--rm \
--volumes-from redis_replica1 \
ubuntu \
cat /var/log/redis/redis-replica.log
redis-replica.log
```

一般Redis主从，有多个从服务器，接下来再运行一个redis_replica2的从容器。

```bash
$ docker run -d -h redis-replica2 --name redis_replica2 \
	--link redis_primary:redis_primary \
	beginman/redis-replica
```

再次用上面命令，把1改成2查看下log，会发现Redis从2已经Ok了，那么到此**Redis集群运行起来了。**

# 六.创建Node容器

运行Node.js容器

```bash
docker run -d \
	-p 3000:3000 \
	--link redis_primary:redis_primary \
	--name nodeapp  \
	beginman/nodejs
```

查看下nodeapp容器输出：

```bash
docker logs nodeapp
Listening on port 3000
```

浏览器打开可看到相应输出。

# 七.使用logstash捕获应用日志

Dockerfile文件如下：

```bash
$ cat Dockerfile
FROM ubuntu:latest
ENV REFRESHED_AT 2016-11-11

RUN apt-get -yqq update
RUN apt-get -yqq install wget
RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch |  apt-key add -
RUN echo 'deb http://packages.elasticsearch.org/logstash/1.5/debian stable main' > /etc/apt/sources.list.d/logstash.list
RUN apt-get -yqq update
RUN apt-get -yqq install logstash default-jdk

ADD logstash.conf /etc/

# 指定工作目录
WORKDIR /opt/logstash
# 指定启动命令
ENTRYPOINT [ "bin/logstash" ]
# 指定启动参数
CMD [ "--config=/etc/logstash.conf" ]
```

开始build and run 

```bash
$ docker build -t beginman/logstash .
$ docker run -d --name logstash \
	--volumes-from redis_primary \
	--volumes-from nodeapp \
	beginman/logstash
```

通过`--volumes-from` 挂载redis_primary和nodeapp容器以便logstash可访问到Redis和Node的日志文件，logstash监控这些文件，有变动则立马反应到logstash容器的卷里，传给logstash做后续处理。

build / run之后刷新下网页，看logstash的输出：

```bash
$ docker logs -f logstash
{
       "message" => "::ffff:192.168.99.1 - - [Fri, 11 Nov 2016 16:20:11 GMT] \"GET /hello/beginman HTTP/1.1\" 200 25 \"-\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36\"",
      "@version" => "1",
    "@timestamp" => "2016-11-11T16:20:12.112Z",
          "host" => "1f79e3e5e68a",
          "path" => "/var/log/nodeapp/nodeapp.log",
          "type" => "syslog"
}
{
       "message" => "::ffff:192.168.99.1 - - [Fri, 11 Nov 2016 16:20:11 GMT] \"GET /hello/beginman HTTP/1.1\" 200 25 \"-\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36\"",
      "@version" => "1",
    "@timestamp" => "2016-11-11T16:20:12.118Z",
          "host" => "1f79e3e5e68a",
          "path" => "/var/log/nodeapp/nodeapp.log",
          "type" => "syslog"
}
```

好了，整个基础项目OK了，看下现在运行的容器：

```bash
$ docker ps | less -S
CONTAINER ID        IMAGE                    COMMAND            
1f79e3e5e68a        beginman/logstash        "bin/logstash --confi"
232553ca6e26        beginman/nodejs          "nodejs server.js"
fd16b718c114        beginman/redis-replica   "redis-server '--logf"
40a7468dd60d        beginman/redis-replica   "redis-server '--logf" 
f450136a2a5d        beginman/redis-primary   "redis-server '--logf" 
```

# 八.总结

书上讲通过[nsenter](https://github.com/jpetazzo/nsenter)工具访问Docker容器，讲解的还是太简单了，直接看github项目即可。进行容器访问方式可参考[Docker exec与Docker attach](http://blog.csdn.net/halcyonbaby/article/details/46884605)这篇博客。

本节干货比较少，其实也没啥要总结的，就是把之前的构建流程又实践了一把，混了个手熟而已，总的来说有几点唠叨下。

1. base image构建太慢，比如Ubuntu, Centos等，主要是访问国外资源太慢，导致整个build过程特别长，我大部分时间就在等build, 二十分钟不为过，所以base image不要轻易删掉，能用缓存就用。
2. `cp`命令无法 复制一个文件到多个目录，只能一个个的复制或复制多个到一个目录，如果有cp one to more dir的需求，可`echo dir1 dir2 ...| xargs -n 1 cp xx`
3. 玩Docker大部分在Dockerfile上，所以Dockerfile指令一定要熟记。
4. **Docker倡导一个容器一个进程原则**
5. 挂载、卷十分强大, 要弄清楚它。
6. 默认的镜像（如Ubuntu）是不包含软件包列表的，目的是让镜像体积更小。因此需要在任何的基础的Dockerfile中需要使用`apt-get update`
6. 干货：**[24条 Docker 建议](https://linux.cn/article-4506-1.html)**







