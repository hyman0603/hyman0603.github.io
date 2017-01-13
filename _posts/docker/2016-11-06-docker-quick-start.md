---
layout: post
title: "《第一本Docker书》笔记 1.Docker快速入门"
category: "docker"
tags: [docker, 运维, 容器, 入门, 总结]
---

目录：

1. 查看docker是否正常工作
2. 运行容器
3. 使用容器
4. 容器命名
5. 重启容器
6. 附着到容器上
7. 创建守护式容器
8. 容器内部都在干什么
9. 查看容器内的进程
10. 在容器内运行进程
11. 停止守护式进程
12. 自动重启容器
13. 深入容器
14. 删除容器

Docker 基于CS模式， 一个docker程序既能做客户端，也能做服务端。做客户端时，docker程序向Docker守护进程发送请求，然后再对Server返回的请求信息进行处理。

# 一.查看docker是否正常工作

使用docker可执行程序的`info`命令

```bash
$ docker info

Containers: 5
 Running: 1
 Paused: 0
 Stopped: 4
Images: 4
Server Version: 1.12.2
Storage Driver: aufs
 Root Dir: /mnt/sda1/var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 36
 Dirperm1 Supported: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: host null bridge overlay
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Security Options: seccomp
Kernel Version: 4.4.24-boot2docker
Operating System: Boot2Docker 1.12.2 (TCL 7.2); HEAD : 9d8e41b - Tue Oct 11 23:40:08 UTC 2016
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 1.955 GiB
Name: default
ID: FHY4:JRVG:EPU3:3VSD:LW54:3ORJ:ONXY:7LRS:FBSV:TUCM:YQLH:5HAH
Docker Root Dir: /mnt/sda1/var/lib/docker
Debug Mode (client): false
Debug Mode (server): true
 File Descriptors: 18
 Goroutines: 33
 System Time: 2016-11-06T15:15:00.093572527Z
 EventsListeners: 1
Registry: https://index.docker.io/v1/
Labels:
 provider=virtualbox
Insecure Registries:
 127.0.0.0/8

```

返回所有容器和镜像的数量、执行驱动和存储驱动以及Docker的基本配置。


# 二.运行容器

使用`docker run`命令，语法：

    docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

提供Docker容器的创建到启动的功能, 如下基于ubuntu镜像来创建容器，并且启动 bash.

    $ docker run -i -t ubuntu /bin/bash
    root@6feb11e60576:/#
    
该容器的主机名就是其容器ID 6feb11e60576

命令解释如下： 参考[Docker run命令](http://www.runoob.com/docker/docker-run-command.html)

**`-i`和`-t`一般搭配使用，-i: 开启STDIN, -t: 分配一个伪tty终端。**

**docker run 的流程如下：**

1. Docker会先检查本地是否存在ubuntu镜像
2. 如果本地没有则Docker连接官方维护的Docker Hub Registry查看是否有该镜像
3. 找到后就会下载镜像并将其保存到本地宿主机中。
4. 随后Docker在文件系统内部用这个镜像创建一个新容器，该容器拥有自己的网络、IP以及一个用来与宿主机进行通信的桥接网络接口。
5. 最后告诉Docker在新容器中运行什么命令，上面运行了`/bin/bash`命令来启动一个Bash shell.


# 三.使用容器

直接在该容器中操作命令, 如：

```bash
root@6feb11e60576:/# ps -aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  18244  3412 ?        Ss   15:19   0:00 /bin/bash
root        22  0.0  0.1  34424  2880 ?        R+   15:48   0:00 ps -aux

root@6feb11e60576:/# apt-get update && apt-get install git vim
```

输入`exit`就返回到宿主机。

    $ docker ps -a
    
使用[Docker ps 命令](http://www.runoob.com/docker/docker-ps-command.html)查看当前系统容器中的列表，`docker ps`只能查看正在运行的容器， `-a` 查看所有包括正在运行的和已经停止的。

![docke](http://beginman.qiniudn.com/2016-11-07-docker.png)

# 四.容器命名

`-name` 选项即可：

    $ docker run -name 名字 -i -t 镜像 [命令]

如果存在相同名字的容器则创建失败。

# 五.重启容器

命令如下：

    $ docker start 容器名(或容器ID)
    $ docker restart 容器名(或容器ID)
    
然后 `docker ps` 查看正在运行的容器，看是否重启成功。

# 六.附着到容器
 
使用`docker attach`命令重新附着该容器的会话。

    $ docker attach 容器名（或容器ID）
    
如下：

```bash
$ docker start ubuntu
ubuntu

$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
49003e9b8c9e        ubuntu:latest       "/bin/bash"         42 hours ago        Up 3 seconds                            ubuntu

$ docker attach ubuntu
root@49003e9b8c9e:/#
root@49003e9b8c9e:/#
```

现在又重新回到容器的bash提示符， 注意：**可能需要按下回车键才能进入该会话。**, 如果退出容器的shell，那么容器也随之停止运行。

# 七.创建守护式容器

两种容器：

1. 交互式
2. 守护式

刚才上面的就属于交互式， 但是大多时候需要守护式容器。它创建命令如下：

    docker run --name daemon_dave -d ubuntu /bin/sh -c "while ture"; do echo hello world; sleep 1; done;
    
上面的`-d`就是daemon的意思放在后台运行，命令就是循环打印hello world, 直到容器或进程停止运行。

```bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

$ docker run --name UUB -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
c7586551985d60787a6aa26a63da477cbb849146a447584f94df386ec94d9969

$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
c7586551985d        ubuntu              "/bin/sh -c 'while tr"   3 seconds ago       Up 2 seconds                            UUB

$ docker top UUB
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                4868                4856                0                   07:05               ?                   00:00:00            /bin/sh -c while true; do echo hello world; sleep 1; done
root                4928                4868                0                   07:05               ?                   00:00:00            sleep 1
```

# 八.容器内部都在干什么

上面的容器一直打印hello world 要清楚容器内部在干什么，可以用`logs`命令：

    $ docker logs UUB
    hello world
    hello world
    hello world
    ...
    
可以使用`-f`选项 ，同`tail -f`一样来监控Docker日志

    $ docker logs -f UUB
    $ docker logs --tail 10 UUB         # 获取日志最后10行
    $ docker logs --tail 0 -f UUB       # 跟踪最新日志而不必读取整个日志文件
    $ docker logs --ft UUB              # -t 加上时间戳
    
    
然后按`CTRL+C`退出日志跟踪。

# 九.查看容器进程

使用 `docker top 容器名或ID` 命令

# 十.在容器内部运行进程

使用`docker exec` 命令, 同`run` 也分交互式和守护式， 对于守护式也有`-d`选项，对于交互式也是`-t`,`-i`选项

    $ docker exec -d UUB touch hello.txt        # 通过 docker exec后台命令创建文件
    $ docker exec -t -i UUB /bin/sh             # 交互式，打开bash
    # ls
    bin  boot  dev	etc  hello.txt home


## 十一.停止守护式容器

`stop`命令即可：

    $ docker stop 容器名或ID
    
> `stop`命令会向容器进程发送`SIGTERM`信号，如果想快速停止某个容器，也可使用`docker kill`命令发送`SIGKILL`信号。

查看最后x个容器，而不管正运行或停止：

    $ docker ps -n x
    
如下实例：

    $ docker stop UUB
    UUB 
    
    $ docker ps -n 2
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                        PORTS               NAMES
    c7586551985d        ubuntu              "/bin/sh -c 'while tr"   59 minutes ago      Exited (137) 23 seconds ago                       UUB
    6feb11e60576        ubuntu              "/bin/bash"              16 hours ago        Exited (0) 16 hours ago                           sick_jennings

## 十二.自动重启容器

意思就是，如果容器出现异常，可能就崩溃了，导致整个容器停止了。像supervisor一样，有如下配置，自动重启或或设置启动失败重启尝试次数等。如下是supervisor的配置：

```ini
[program:programName]
directory = /path/to/projects       ; 程序的启动目录
command = command line              ; 启动命令
autostart = true                    ; 在 supervisord 启动的时候也自动启动
startsecs = 5                       ; 启动 5 秒后没有异常退出，就当作已经正常启动了
autorestart = true                  ; 程序异常退出后自动重启
startretries = 3                    ; 启动失败自动重试次数，默认是 3
redirect_stderr = true              ; 把 stderr 重定向到 stdout，默认 false
stdout_logfile_maxbytes = 20MB      ; stdout 日志文件大小，默认 50MB
stdout_logfile_backups = 20         ; stdout 日志文件备份数
stdout_logfile = /path/to/stdout.log ; stdout 日志文件

; 可以通过 environment 来添加需要的环境变量
; environment=PYTHONPATH=$PYTHONPATH:/path/to/somewhere
```

在Docker里可以在`docker run`命令 设置 `--restart`标识让Docker自动重新启动该容器，`--restart`标志会检查容器的退出码，并根据此来决定是否要重启容器，默认行为是不重启容器。

    $ docker run --restart=always --name UUB2 -d ubuntu /bin/sh -c "while true; do echo hello; sleep 1; done"
    fff5977c91ee9b712723248cc9339d49eba5025c1453dd05d4f069846d84a855

在上面`--restart=always`, 无论容器退出码是什么都会自动重启， 还可设置`on-failure`， 这样只有当容器的退出码为非0值的时候才会自动重启。另外`on-failure` 还可以接受一个可选参数表示重启次数：

    --restart=on-failure:5
    

# 十三.深入容器

两个获取信息的命令：

- `docker ps` 获取容器信息
- [`docker inspect`](http://www.runoob.com/docker/docker-inspect-command.html) 获取更多信息, 获取容器/镜像的元数据

如下：

    $ docker inspect UUB
    [
    {
        "Id": "xxx",
        "Created": "2016-11-07T07:05:15.936489266Z",
        "Path": "/bin/sh",
        "Args": [
            "-c",
            "while true; do echo hello world; sleep 1; done"
        ],
        "State": {
            "Status": "exited",
            "Running": false,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 0,
            "ExitCode": 137,
            "Error": "",
            "StartedAt": "2016-11-07T07:05:16.045347627Z",
            "FinishedAt": "2016-11-07T08:04:49.886820124Z"
        },
        "Image": "sha256:xxx",
        "ResolvConfPath": "/mnt/sda1/var/lib/docker/containers/xxx/resolv.conf",
        "HostnamePath": "/mnt/sda1/var/lib/docker/containers/xxx/hostname",
        "HostsPath": "/mnt/sda1/var/lib/docker/containers/xxx/hosts",
        "LogPath": "/mnt/sda1/var/lib/docker/containers/xxx/xxx-json.log",
        "Name": "/UUB",
        ....
        

inspect返回一大堆json， 可通过`-f`或`--format`标志来选定查看结果。

 (ps. Markdown 过滤了`{{}}`？？)
 
 ![](http://beginman.qiniudn.com/2016-11-07-14785087857409.jpg)


# 十四.删除容器

先停止，再删除

    $ docker stop xxx  # 或 docker kill xxx
    $ docker rm xxx
    
一次删除所有容器：

    docker rm `docker ps -a -q`
    

（完）~


