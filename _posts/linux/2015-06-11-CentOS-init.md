---
layout: post
title: "CentOS服务器开发初步"
description: "CentOS服务器开发初步"
category: "operation"
tags: [运维]
---
最讨厌的事情来了，那就是做数据迁移和服务器重新搭建，而且还是两台。我不是专业的运维人员，我特别想知道他们是怎么管理这些服务器集群的，或者他们是怎么进行成百上千台服务器搭建的.
没有办法，只能继续埋头搭建了，这里我总结了我需要做的事情：

# 一.安全性配置

## 1.1 更改root密码使之更加健壮
新服务器以root身份登陆后，直接输入命令`passwd`,则更改root密码

    [root@fuckyou ~]# passwd
    Changing password for user root.
    New password:
    Retype new password:
    passwd: all authentication tokens updated successfully.   
    
## 1.2 生成普通用户
`useradd`: 生成用户，`passwd`:设置密码，`groupadd`:生成组

    useradd beginman
    passwd beginman
   
然后授予root权限

    chmod 775 /etc/sudoers
    vim /etc/sudoers
    
    [root@rhel1 ~]# vim /etc/sudoers
    root    ALL=(ALL)       ALL  
    team     ALL=(ALL)       ALL                # 这个在切换时，是需要输入密码的，密码是当前普通用户的密码
    beginman ALL=(ALL)     NOPASSWD:ALL         # 这个在切换时，不需要输入密码
    
    # write ok, 恢复只读状态
    chmod 440 /etc/sudoers
    
## 1.3 ssh配置，禁用root登陆，以及更加安全性的配置

`vim /etc/ssh/sshd_config`:

- 将默认端口22 改成其他端口 如:2048
- 禁止root用户远程登陆：修改PermitRootLogin，默认为yes且注释掉了；修改是把注释去掉，并改成no。
- PermitEmptyPasswords   no不允许空密码用户login

ssh服务器重启:

`service sshd restart`    或 `/etc/init.d/sshd restart`


## 1.4 搭建防火墙，安装Fail2Ban等防暴力破解工具

参考这里:[How To Protect SSH with fail2ban on CentOS 6](https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-centos-6)

## 1.5 挂载硬盘，分配空间

参考这里：[Linux 系统挂载数据盘](http://help.aliyun.com/knowledge_detail/5974154.htm)

# 二.开发环境搭建

## 2.1 升级Python
见这里[Centos 升级python](http://beginman.cn/python/2015/04/06/Centos-python/)

升级后再安装python包，如`pip`等,这里直接给出link

- [How to install pip on CentOS / RHEL / Ubuntu / Debian](http://sharadchhetri.com/2014/05/30/install-pip-centos-rhel-ubuntu-debian/)

如果`pkg_resources.DistributionNotFound pip`错误, 解决方法: `easy_install –upgrade pip`

如果有其他pip，如python2.6,python2.7的则`find / -name pip` 一个个的试一试，不行的那个就删掉



## 2.2 安装mysql,并做好安全性，读写分离，备份等基础配置
Centos mysql源比较旧了，不建议`yum`安装，从mysql5.5起，mysql源码安装开始使用cmake了，这里介绍编译方法.

先安装需要的包：

    yum install –y autoconf automake imake libxml2-devel expat-devel cmake gcc gcc-c++ libaio libaio-devel bzr bison libtool ncurses5-devel ncurses-devle
    
剩下的参考这里：

[CentOS6.5下编译安装MySQL 5.6.16](http://www.centoscn.com/mysql/2014/0924/3833.html)

安装完成修改root密码：

    mysql>update user set password=PASSWORD(‘123456’) where User='root';

然后允许mysql远程访问：

    mysql>GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
    mysql>FLUSH RIVILEGES;

## 2.3 安装redis，并做好安全性，读写分离，备份等基础配置

[download and install] (http://redis.io/download)

如果出现`You need tcl 8.5 or newer in order to run the Redis test`异常则参考这里[Redis: You need tcl 8.5 or newer in order to run the Redis test](http://blog.58share.com/?p=280)

    yum install -y tcl



## 2.4 安装mongodb,并做好安全性，读写分离，备份等基础配置

todo

## 2.5 nginx服务器安装及配置文件详解
[nginx服务器安装及配置文件详解](http://segmentfault.com/a/1190000002797601)


## 2.6 安装rabbitmq
    
    # Note: We are also enabling third party remi package repositories.
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    sudo rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
    
    # Finally, download and install Erlang:
    yum install -y erlang


Once we have Erlang, we can continue with installing RabbitMQ:

[rabbitmq,downlink](https://www.rabbitmq.com/install-rpm.html):
    
    # Download the latest RabbitMQ package using wget:
    wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.5.3/rabbitmq-server-3.5.3-1.noarch.rpm
    
    # Add the necessary keys for verification:
    rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    
    # Install the .RPM package using YUM:
    yum install rabbitmq-server-3.5.3-1.noarch.rpm
    
    
然后就是启动设置：

    chkconfig rabbitmq-server on
    
    # To start the service:
    service rabbitmq-server start
    
    # To stop the service:
    service rabbitmq-server stop
    
    # To restart the service:
    service rabbitmq-server restart
    
    # To check the status:
    service rabbitmq-server status
    
