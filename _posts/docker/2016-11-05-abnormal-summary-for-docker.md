---
layout: post
title: "Docker异常汇总"
category: "docker"
tags: [docker, 运维, 容器, 异常, 汇总]
---

# Mac OSX 下异常

## 1. Cannot connect to the Docker daemon.

    $ docker info
    Cannot connect to the Docker daemon. Is the docker daemon running on this host?

在Mac下经常遇到这个问题，执行：

    $ docker-machine env default
    
也无效。最后在[这里](https://github.com/docker/kitematic/issues/1010)找到解决方案：

    $ eval "$(docker-machine env default)"

如果不方便可将这条命令写在`.bashrc`文件下。

PS. 其实在之前看的[Mac OS X 安装 Docker](https://github.com/widuu/chinese_docker/blob/master/installation/mac.md) 一文中有说明，只是自己不太熟悉而已：

    # 创建一个新的名为default的Docker虚拟机
    $ docker-machine create --driver virtualbox default
    ...
    To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env default

    # 查看所有可用docker machines
    $ docker-machine ls
    NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
    default   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.12.2
    my        -        virtualbox   Running   tcp://192.168.99.101:2376           v1.12.3

创建虚拟机后查看该虚拟机环境变量， 这里查看我之前创建的名为my的虚拟机：

    $ docker-machine env my
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.99.101:2376"
    export DOCKER_CERT_PATH="/Users/fangpeng/.docker/machine/machines/my"
    export DOCKER_MACHINE_NAME="my"
    # Run this command to configure your shell:
    # eval $(docker-machine env my)    

上面就有提示：

    # Run this command to configure your shell:
    # eval $(docker-machine env my)    

## 2.Error checking TLS connection: Host is not running

在使用`eval` "$(docker-machine env default)"`总是提示：Error checking TLS connection: Host is not running。 解决方案在这里[still having issues with "Error checking TLS connection: Host is not running" #453](https://github.com/docker/toolbox/issues/453)

比较推荐的方案是：

    $ docker-machine restart default

# 二.使用异常

在run时设置主机名，结果报错了, `-h` 设置容器主机名，并被本地DNS服务正确解析。

```bash
$ docker run -d -h redis_primary --name redis_primary beginman/redis_primary
docker: Error response from daemon: invalid hostname format: redis_primary.
```

解决方案：

>It looks like you specified an invalid hostname. Docker validates if hostnames are RFC 1123 compliant (see https://tools.ietf.org/html/rfc1123).

> Removing the underscore in your hostname, and replacing it with a hyphen (ip-172-31-19-146-gefen-cms) should make this work.



（更新中）...






