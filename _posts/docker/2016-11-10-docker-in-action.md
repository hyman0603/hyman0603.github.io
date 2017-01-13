---
layout: post
title: "《第一本Docker书》笔记 3.Docker实战构建webAPP"
category: "docker"
tags: [docker, 应用, 静态网站, flask, python]
---

目标有2：

1. 构建Nginx静态网站
2. 构建flask webApp

# 一.构建Nginx静态网站

项目在[github/beginman/docker-flask/sample-nginx-demo 下](https://github.com/BeginMan/docker-flask.git), 目录结构如下：

```bash
$ tree
.
├── Dockerfile          
├── nginx               
│   ├── app.conf     -> 静态应用配置
│   └── nginx.conf   -> nginx配置
├── run.sh           -> docker容器创建/启动命令
|── build.sh         -> docker镜像构建
└── website          -> 静态文件路径
    └── index.html

2 directories, 5 files
```

首先创建镜像：`./build.sh`, 然后从该镜像中启动一个容器：

    $ ./run.sh
    d27ae3afbfea3434503e86f95a637f44540d3045cc68f647bc524bbd3fb8af2a
    curl 192.168.99.100:8090

然后浏览器打开下面的地址：192.168.99.100:8090 就能访问了。随意编辑website里的文件，重新刷新浏览器就能看到更新内容，因为`docker run`的时候已经通过**`-v`**标识将website目录**挂载**到容器的 /var/www/html/website 下了。

    $ docker run -d -p 8090:80 --name website \
	-v $PWD/website:/var/www/html/website \
	beginman/nginx nginx
	

# 二.构建并测试webApp

目标:

1. 初步：一个简单的flask app
2. 连接一个redis容器

主要知识点：

**1. 容器间互联**

Docker创建redis容器并使用其服务，可参考官方文档:[Dockerize a Redis service](https://docs.docker.com/engine/examples/running_redis_service/)。这里假设已经运行了一个redis容器，如下进行容器link的测试：

```bash
$ docker run --name test --link redis:db -t -i ubuntu /bin/bash

# link信息都在/etc/hosts下
# 下面将 root@395b... 简写为 `$`
$ root@395bd9690347:/# cat /etc/hosts
127.0.0.1	localhost
....
172.17.0.3	db ed45b0adfa23 redis    --> link redis, db为别名，edxxx为主机名
172.17.0.4	395bd9690347             --> 是自己的IP和主机名

# ping db试一下
$ apt-get update && apt-get install iputils-ping python-pip python2.7-dev
$ ping db
PING db (172.17.0.3) 56(84) bytes of data.
64 bytes from db (172.17.0.3): icmp_seq=1 ttl=64 time=0.087 ms
...

# 在使用redis之前，先看下环境变量包含的link 容器信息：
$ env|grep DB
DB_NAME=/test/db
DB_PORT_6379_TCP_PORT=6379
DB_PORT=tcp://172.17.0.3:6379
DB_PORT_6379_TCP=tcp://172.17.0.3:6379
DB_ENV_REFRESHED_AT=2016-11-10
DB_PORT_6379_TCP_ADDR=172.17.0.3
DB_PORT_6379_TCP_PROTO=tcp
# Docker 在处理 test和redis容器的link 时，自动创建了这些以DB_开头的环境变量
```

**那么在test容器里可使用redis容器服务方式有两个：**

1. 通过环境变量
2. 通过DNS和/etc/hosts

下面在test容器里使用第一种方案：

```python
>>> import os
>>> import redis
>>> rds = redis.Redis(host=os.getenv('DB_PORT_6379_TCP_ADDR'),
...                     port=os.getenv('DB_PORT_6379_TCP_PORT'))
>>> rds.setex('test_key', 'hello, world', 300)
True
>>> rds.get('test_key')
'hello, world'
```

整个项目在[**docker-flask**](https://github.com/BeginMan/docker-flask) 里，使用说明：

```bash
git clone https://github.com/BeginMan/docker-flask.git
# Dockerize Python 
cd python_webapp
./build.sh
	
# Dockerize Redis and create a redis container 
cd redis
./build.sh
./run.sh
	
# Dockerize flask app and run it
cd flask_webapp
./build.sh
./run.sh
```

那么本地flask_webapp目录就可做自己的开发目录，可随意修改里面的Python代码，注意，一旦flask因语法等异常后整个容器便会退出，此时运行flask_webapp下 `./start.sh` 即可重新启动该容器。

图示：

![](http://beginman.qiniudn.com/2016-11-10-14787744605116.jpg)

![](http://beginman.qiniudn.com/2016-11-10-14787742459254.jpg)


(完) ~








