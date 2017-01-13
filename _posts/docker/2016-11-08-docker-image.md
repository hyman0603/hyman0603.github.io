---
layout: post
title: "《第一本Docker书》笔记 2.Docker镜像和仓库"
category: "docker"
tags: [docker, 运维, 容器, 入门, 总结]
---

目录：

- Docker镜像简介
- Docker写时复制
- 列出镜像
- 拉取镜像
- 查找镜像
- 构建镜像
- 推送Docker Hub
- 删除镜像


# 一.Docker镜像简介

Docker镜像是由文件系统叠加而成的，由底向上层次依次是：

- 最底层是bootfs引导文件系统， 像Linux/Unix的引导文件系统，bootfs在容器启动时引导，它会被卸载(unmount)并移到内存，以留出更多内存供initrd磁盘镜像使用。
- 第二层是root文件系统rootfs, rootfs可以是一种或多种操作系统(如Debian or Ubuntu 文件系统)

下面需要清楚的是：

1. 在Docker里，root文件系统是只读的，作为OS
2. Docker利用联合加载(union mount)技术又会在root文件系统层上叠加更多的只读文件系统。

**Docker将这样的文件系统称为镜像，多镜像可叠加，位于底部的是父镜像（parent image）,最底部的是基础镜像(base image)。当从一个镜像启动容器时，Docker会在该镜像的最顶端(Top)加载一个读写文件系统，我们在Docker中运行的程序就是在这个读写层进行。**

如下图 Docker容器文件系统

![](http://beginman.qiniudn.com/2016-11-08-14786161138424.png)



# 二.Docker写时复制

写时复制在wiki中的介绍：

>写入时复制（英语：Copy-on-write，简称COW）是一种计算机程序设计领域的优化策略。其核心思想是，如果有多个调用者（callers）同时要求相同资源（如内存或磁盘上的数据存储），他们会共同获取相同的指针指向相同的资源，直到某个调用者试图修改资源的内容时，系统才会真正复制一份专用副本（private copy）给该调用者，而其他调用者所见到的最初的资源仍然保持不变。这过程对其他的调用者都是透明的（transparently）。此作法主要的优点是如果调用者没有修改该资源，就不会有副本（private copy）被创建，因此多个调用者只是读取操作时可以共享同一份资源。

例如当在Docker里添加一个apache镜像时，该镜像是只读文件，不可以修改，那是不是说下载了别人的镜像不能修改呢？这肯定不符合逻辑，实际上Docker处理逻辑是：当我们试图修改镜像时，Docker会复制出该镜像到可写层，并隐藏原来的镜像，而被我们修改过的镜像就变成一个我们自己的镜像了，这就是写时复制。

>当 Docker 第一次启动一个容器时，初始的读写层是空的，当文件系统发生变化时，这些变化都会应用到这一层之上。比如，如果想修改一个文件，这个文件首先会从该读写层下面的只读层复制到该读写层。由此，该文件的只读版本依然存在于只读层，只是被读写层的该文件副本所隐藏。该机制则被称之为写时复制（Copy on write）。

![](http://beginman.qiniudn.com/2016-11-08-14786165775574.png)

**文件系统时通过写时复制创建，意味着文件系统时分层、快速的，占用磁盘空间更小。**

# 三.列出镜像

`docker images`命令：

```bash
$ docker images
REPOSITORY                                   TAG                 IMAGE ID            CREATED             SIZE
ubuntu                                       latest              f753707788c5        3 weeks ago         127.2 MB
nginx                                        latest              a5311a310510        3 weeks ago         181.5 MB
hello-world                                  latest              c54a2cc56cbb        4 months ago        1.848 kB
```

#  四.拉取镜像

用`docker run`**从镜像启动一个容器**时，如果该image 不在本地则会先从 docker hub download， 如果没指定具体的镜像标签，则会自动下载 latest 标签的镜像。
    
    # 如下通过image name后面加冒号和tag name 来指定该仓库中的某一个镜像
    $ docker run -t -i --name new_container ubuntu:12.04 /bin/bash
    
拉取`docker pull`，一个镜像仓库可包括多个镜像，如下：

```bash
$ docker pull ubuntu
Using default tag: latest
latest: Pulling from library/ubuntu
Digest: sha256:2d44ae143feeb36f4c898d32ed2ab2dffeb3a573d2d8928646dfc9cb7deb1315
Status: Image is up to date for ubuntu:latest
```

`pull` 和 `run`的区别就在于`pull`只是拉取image到本地，而`run`是一连贯的动作。

如pull centos 6.7

```bash
$ docker pull centos:6.7

$ docker images centos
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              6.7                 ab44245321a8        9 weeks ago         190.6 MB    
```    

# 五.查找镜像

`docker search`在Docker hub上公共可用镜像中查询。

```bash
$ docker search nginx
NAME                      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
nginx                     Official build of Nginx.                        4539      [OK]
jwilder/nginx-proxy       Automated Nginx reverse proxy for docker c...   856                  [OK]
....
```

返回带有[puppet](http://baike.baidu.com/item/puppet)的镜像。

# 六.构建镜像

目录：

1. [docker commit](http://www.runoob.com/docker/docker-commit-command.html)
2. 用Dockerfile文件配合[docker build](http://www.runoob.com/docker/docker-build-command.html)构建镜像(**推荐**)

首先在docker hub上注册，通过[`docker login`](https://docs.docker.com/engine/reference/commandline/login/)验证下：

```bash
docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: beginman
Password:
Login Succeeded
```

认证信息存储在$HOME/.docker/config.json下

## 6.1 commit

然后基于一个镜像，更改后`commit`。如下在ubuntu容器里安装nginx

```bash
$ docker start ubuntu
ubuntu
$ docker attach ubuntu
^C
root@49003e9b8c9e:/# apt-get install nginx
...
```
安装了nginx，那么该容器作为web服务器来运行，把当前状态保存下来，而不必每次创建新容器并安装nginx。基于此构建自己的image。先`exit`退出该image 然后 `docker commit`提交定制容器。

```bash
root@49003e9b8c9e:/# exit
exit

$ docker commit 49003e9b8c9e beginman/my-nginx
sha256:847f7607f002960a7f87897dcd8cf1af10e00adf08c72b36c2efd04020f4028d
```

docker commit提交的仅仅该容器的差异部分，非常轻量级。通过`docker ps -l -q`获取刚创建的容器ID

```bash
$ docker ps -l -q
a2e4534a1478
```

查看新创建的镜像(docker images 或 docker inspect)：

```bash
$ docker images beginman/my-nginx
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
beginman/my-nginx   latest              847f7607f002        10 hours ago        305.7 MB
```

从刚才创建的镜像运行一个容器。

```bash
$ docker run -t -i  beginman/my-nginx /bin/bash
root@81a17949bc4d:/#
```

## 6.2 用Dockerfile构建镜像

**总结：**

1. Dockerfile + docker build > commit
2. Dockerfile基于DSL语法

**使用dockerfile构建镜像的流程如下：**

1. 选择或创建目录， 该目录作为build env，docker称之为上下文或构建上下文。在build image时将上下文和其中的文件、目录等上传到Docker 守护进程，这样docker 守护进程就能直接访问你想在镜像中存储的任何代码、文件、数据等。
2. 创建Dockerfile文件并编辑指令
3. 基于Dockerfile 使用`docker build`构建新镜像
4. (可选步骤)构建完成后将镜像推送到docker hub.

关于如何构建镜像在《第一本Docker书》4.5节有很详细的讲解，这里列举重要的几点。

1. **熟悉Dockerfile 指令**
2. **熟悉Dockerfile 构建流程及原理**
3. **build异常处理**


### 6.2.1.指令

参考：

- [Docker入门教程（三）Dockerfile](http://dockone.io/article/103)
- [Docker从入门到实践-Dockerfile](https://yeasy.gitbooks.io/docker_practice/content/dockerfile/)

### 6.2.2.流程及原理

**指令从上到下依次执行，每条指令都会创建一个新的镜像层并对镜像进行提交。每个Dockerfile文件的第一条指令必须是选择已存在的base image指令，也即是`FORM`指令， 后续的指令都基于该base image进行。**

那么Docker执行Dockerfile中的指令流程如下：

1. Docker从base image运行一个容器
2. 执行一条指令，对容器作出修改
3. 执行类似docker commit的操作，提交一个新的镜像层
4. Docker再基于刚提交的镜像运行一个新容器。
5. 执行Dockerfile中的下一条指令，以此类推，直到所有指令都执行完毕。

如下实例体现构建流程:

```bash
$ mkdir static_web
$ cd static_web
$ touch Dockerfile
$ vim Dockerfile

# 构建时为镜像设置标签
$ docker build -t="beginman/static_web:v1" . 

Sending build context to Docker daemon 2.048 kB
Step 1 : FROM ubuntu:latest
 ---> f753707788c5
Step 2 : MAINTAINER Beginman "xinxinyu2011@163.com"	# 作者
 ---> Running in 1372bf1e86a5
 ---> 7995056a9774
Removing intermediate container 1372bf1e86a5
Step 3 : RUN apt-get update	# RUN 执行命令
 ---> Running in 03f14cb06c77
Get:1 http://archive.ubuntu.com/ubuntu xenial InRelease 
[247 kB]
...

```

关于Dockerfile内容如下：

```bash
# Version 0.0.1
# FORM指令指定一个已经存在的base image.
FROM ubuntu:latest
MAINTAINER Beginman "xinxinyu2011@163.com"	# 作者
RUN apt-get update	# RUN 执行命令
RUN apt-get install -y nginx
# RUN use /bin/sh -c default, 如果不支持shell则可使用exec格式的指令：
RUN ["apt-get", "install", "-y", "git"]
RUN echo 'Hi, I am in your container' \
	>/usr/share/nginx/html/index.html
	
# docker不会自动打开端口，需显式告知要使用80端口
EXPOSE 80	
```

docker build 也可从git仓库的源地址来指定dockerfile的位置：

    docker build -t='xx' git@github.com:beginman/xxxx
    
如果构建上下文存在`.dockerignore`文件，则里面的文件不会被上传到构建上下文中，与git的`.gitignore`一样。

执行指令后构建的每一步都返回新镜像的ID。如果指令失败则会停到上一个新的image，假设ID 为 xxx，那么可进入该容器再次执行那个出了错的命令：

```bash
$ docker run -t -i xxx /bin/bash
xxx:/# 执行出了错的命令, 进行调试
```

调试成功后，重新修改dockerfile文件纠正命令，重新build。docker build基于缓存，再次build会使用之前build success的镜像缓存，会直接跳到待build的那一步构建。不过前提条件就是之前的build步骤没有发生变化。

如下例子中，最后一步出错了，我修正后重新build, 可发现之前已经build过的都标上 Using cache. 

```bash
$ docker build -t="beginman/static_web:v1" . # 构建时为镜像设置标签

Sending build context to Docker daemon 2.048 kB
Step 1 : FROM ubuntu:latest
 ---> f753707788c5
Step 2 : MAINTAINER Beginman "xinxinyu2011@163.com"	# 作者
 ---> Using cache
 ---> 7995056a9774
Step 3 : RUN apt-get update	# RUN 执行命令
 ---> Using cache
 ---> 24191655f273
Step 4 : RUN apt-get install -y nginx
 ---> Using cache
 ---> 0d8849b2522c
Step 5 : RUN apt-get install -y git
 ---> Using cache
 ---> bd644658b587
Step 6 : RUN echo 'Hi, I am in your container' 	>/usr/share/nginx/html/index.html
 ---> Using cache
 ---> 4f89cee4ff22
Step 7 : EXPOSE 80
 ---> Running in d4fb332661e2
 ---> 4d6a3b434479
Removing intermediate container d4fb332661e2
Successfully built 4d6a3b434479
```

如果不想使用缓存，则使用`--no-cache`标志

```bash
$ docker build --no-cache -t="beginman/my-web:v1" .
```

**还可以在Dockerfile使用` ENV REFRESHED_AT 日期`指令来刷新构建**，如下：

```bash
# Version 0.0.1
# FORM指令指定一个已经存在的base image.
FROM ubuntu:latest
MAINTAINER Beginman "xinxinyu2011@163.com"	# 作者
ENV REFRESHED_AT 2016-11-09
RUN apt-get update	# RUN 执行命令
RUN apt-get install -y nginx
# RUN use /bin/sh -c default, 如果不支持shell则可使用exec格式的指令：
RUN ["apt-get", "install", "-y", "git"]
RUN echo 'Hi, I am in your container' \
	>/usr/share/nginx/html/index.html
# docker不会自动打开端口，需显式告知要使用80端口
EXPOSE 80
```

然后重新build, 可以看到从Step3: ENV REFRESHED_AT 2016-11-09 后就变成 Running了而不再是Using cache。


```bash
$ docker build -t="beginman/static_web:v1" . # 构建时为镜像设置标签

Sending build context to Docker daemon 2.048 kB
Step 1 : FROM ubuntu:latest
 ---> f753707788c5
Step 2 : MAINTAINER Beginman "xinxinyu2011@163.com"	# 作者
 ---> Using cache
 ---> 7995056a9774
Step 3 : ENV REFRESHED_AT 2016-11-09
 ---> Running in 35576c9fa1e8
 ---> e14788722de8
Removing intermediate container 35576c9fa1e8
Step 4 : RUN apt-get update	# RUN 执行命令
 ---> Running in b2ac534cf5de
Get:1 http://archive.ubuntu.com/ubuntu xenial InRelease [247 kB]
```

然后从构建的新镜像中启动一个容器来验证下： 下面`nginx -g "daemon off;"`命令是以前台运行Nginx.

```bash
$ docker run -d -p 80 --name static_web beginman/static_web:v1 nginx -g "daemon off;"
```

`-p 80` 用于在宿主机随便打开一个端口用于映射容器的80端口。 如下可见容器中的80端口被映射到了宿主机的32768端口上。

```bash
$ docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED              STATUS              PORTS                   NAMES
4106acb7d32d        beginman/static_web:v1   "nginx -g 'daemon off"   About a minute ago   Up About a minute   0.0.0.0:32768->80/tcp   static_web

# 查看端口映射
$  docker port 4106acb7d32d
80/tcp -> 0.0.0.0:32768

$ docker port 4106acb7d32d 80
0.0.0.0:32768

# 查看容器IP
$ docker inspect --format='{{.NetworkSettings.IPAddress}}'  4106acb7d32d
172.17.0.2
```

`-p`可灵活管理容器与宿主机端口映射的关系，如将容器端口映射到宿主机指定的端口上。`-p 指定的宿主机端口: 容器端口`，如果只是`-p 容器端口` 那么Docker会随机打开一个宿主机端口作为其映射。

关于ip/端口绑定方式有如下：

```bash
# 容器端口映射到宿主机指定的端口上
$ docker run -d -p 8080:80 --name static_web beginman/static_web:v1 nginx -g "daemon off;"
# 容器端口映射到宿主机指定IP和端口上
$ docker run -d -p 127.0.0.1:8080:80 --name static_web beginman/static_web:v1 nginx -g "daemon off;"
# 容器端口映射到宿主机指定IP和随机端口上
$ docker run -d -p 127.0.0.1::80 --name static_web beginman/static_web:v1 nginx -g "daemon off;"
``` 

Docker还提供`-P`参数可以对外公开在Dockerfile中的EXPOSE指令中设置的端口：

```bash
$ docker run -d -P --name xx mm
```

现在已经启动了现在看看这个容器内部的进程:

```bash
docker top 3ea92e350f5c | awk '{print $1,$2,$8,$9}'
UID PID CMD
root 30690 nginx: master
33 30706 nginx: worker
```

OK，Nginx确实运行了。**但是不知道为什么访问不到？？？？？**

原因在于：

>`DOCKER_HOST` 的地址并不是你本地的机器的地址（0.0.0.0），而是您的 Docker 虚拟机的地址。

获取 Docker 虚拟机（即 default）的地址:
    
    $ docker-machine ip default
    192.168.59.103

在您的浏览器中输入地址 http://192.168.59.103:49157 即可访问。如果在Linux上则可以直接访问localhost:port

问题来源：[**Mac Install docker**](https://github.com/widuu/chinese_docker/blob/master/installation/mac.md)

关于Dockerfile指令可参考[**Dockerfile指令详解**](http://seanlook.com/2014/11/17/dockerfile-introduction/)


# 七.推送Docker Hub

`docker push 用户名/镜像名`即可

# 八.删除镜像
`docker rmi`命令来删除, 注意 rm 与 rmi区别：

- `rm`   -- Remove one or more containers
- `rmi`  -- Remove one or more images

删除刚才创建的镜像

```bash
$ docker rmi beginman/static_web
Error response from daemon: No such image: beginman/static_web:latest

# 哦，忘了带tag了
$ docker rmi beginman/static_web:v1
Error response from daemon: conflict: unable to remove repository reference "beginman/static_web:v1" (must force) - container 65f2f659b00d is using its referenced image 4d6a3b434479
```

为啥删不掉呢？在Docker使用中，经常会碰到删除镜像不成功，反而让镜像变成了<none > <none>即，没名字，没Tag的镜像。

```bash
docker images
REPOSITORY                                   TAG                 IMAGE ID            CREATED             SIZE
<none>                                       <none>              20a3d29685fe        2 hours ago         223.2 MB
beginman/static_web                          v1                  4d6a3b434479        4 hours ago         307.4 MB
beginman/my-nginx                            latest              847f7607f002        17 hours ago        305.7 MB
ubuntu                                       latest              f753707788c5        3 weeks ago         127.2 MB
nginx                                        latest              a5311a310510        3 weeks ago         181.5 MB
centos                                       6.7                 ab44245321a8        10 weeks ago        190.6 MB
hello-world                                  latest              c54a2cc56cbb        4 months ago        1.848 kB
```

>由于image被某个container引用（拿来运行），如果不将这个引用的container销毁（删除），那image肯定是不能被删除。所以想要删除运行过的images必须首先删除它的container。--ref:[阿里云部署Docker（6）----解决删除<none>镜像问题](http://blog.csdn.net/minimicall/article/details/40188251)

我不知道这样设计的原因是啥。解决方法：

```bash
# 先删除引用该镜像的容器
$ docker ps -a|awk '{print $1,$2}'|grep beginman/static_web:v1|awk '{print $1}'|xargs docker rm

# 再干掉烦人的<none>
$ docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi
Error response from daemon: conflict: unable to delete 20a3d29685fe (must be forced) - image is being used by stopped container 5d81b1313661

# 竟然报错了，原来是有容器引用，干掉它即可。
$ docker rm 5d81b1313661
5d81b1313661

$ docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi
Deleted: sha256:20a3d29685fe64ce8b11a5ac265e6ba420d8f8d6bb1d0ea242e0569d07709efb
Deleted: sha256:ad9b81049a8ac82a69fbef52e86009b08101ac26dac88d36c432a4e72bdb9547
Deleted: sha256:dee1e54e550a25b0de716275a16ffa7f0b9a73bdfb62afc096edeb2bad8e4d0d
Deleted: sha256:eecc82f4f1cda8ac632593ad00f120bdcca0ed438eacff756ee2179ce43f508f
Deleted: sha256:e14788722de813199c3471e28cfbcc130d4d2eab8ed4153653b5b8e08674fc4c

# 再删我们想删除的镜像
$ docker images | grep 'beginman/static_web' | awk '{print $3}' | xargs docker rmi
Untagged: beginman/static_web:v1
Deleted: sha256:4d6a3b4344794890e0b3e6c2939dacada654afc01700efb23edacb6f3142f894
Deleted: sha256:4f89cee4ff226a4794e608c3179ab430ab0aa13717f6f3e702a3381b74e55ffe
Deleted: sha256:a654d92a543ddad09ae124826a1f4c0b3e6952ad27ea5c338c14b7d18ebedbc3
Deleted: sha256:bd644658b5877ccb2a99d31fd27a2aa6f349bc177096a56b14af671aa59c915f
Deleted: sha256:5e917e4a40895abd71d5f509caa6cfdaa8b21ec281c193bcd20e43403f76ab2b
Deleted: sha256:0d8849b2522c6591e8f0d93ceb54cc55196f06f11a7c1cd6b6f543a802639bf6
Deleted: sha256:12b967c9cdab8871009167a5aad1f2e84fbf08e569d6eba4c792dcb4ea92f2cb
Deleted: sha256:24191655f273db2c5c523ae99f2c6a50b9831b117a1af1e84aeebfc4ef03cd17
Deleted: sha256:f64521071384896a5736a8bdca448470fab6d5d151069a24e6d789564260165d
Deleted: sha256:7995056a97740f5a854ae1141634ee94a65b530bc7e1c8896b3b76a3fddaa329
```

也可加`-f`强制删除镜像。

**删除所有镜像, 删得一干二净！！**：

```bash
$ docker ps -a|awk '{print $1,$2}'|awk '{print $1}'|xargs docker rm
$ docker rmi `docker images -a -q`
```

（完）~

