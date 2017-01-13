---
layout: post
title: "Linux用户的那些麻烦事"
description: "Linux用户的那些麻烦事"
category: "linux"
tags: [linux]
---

为什么说“Linux用户的那些麻烦事”呢？原因如下：

- Linux多用户系统中我们必须对root天神毕恭毕敬，对系统用户退却三分，对普通用户强加管理
- 用户组的朋友圈要控制好
- 我们远程登录的安全性，禁止root远程登录，限制和管理普通用户的远程登录
- 如果忘记root密码怎么办

接下来从三个方面去分析：

- Linux用户管理
- 远程登录涉及的一些情况

# 一. Linux用户管理
Linux系统用户可分为：根用户，系统用户，普通用户，每个用户都有UID和对应的用户组ID（GID）

注意系统用户往往是你安装一些服务，如msyql,nginx时创建的，它们往往不能远程登录，如mysql系统用户来管理mysqld进程等，系统用户的ID一般在1~499之间.

那怎么才知道自己的UID和GID呢：

- `id`:查看自己的UID
- `groups`:查看自己的GID

## 1.1 Linux账号管理

/etc/passwd 查看用户密码信息，如下：

	cat /etc/passwd
	root:x:0:0:root:/root:/bin/bash
	bin:x:1:1:bin:/bin:/sbin/nologin
	beginamn:x:502:508::/home/beginman:/bin/bash
	...

格式如下图：

![](http://beginman.qiniudn.com/etc_passwd.png)

**上图的`nologin`常常作为我们检测为什么用户不能登录的原因！！**

**这样上述命令任何用户都能看到，为了防止密码被破解，`/etc/shadow`则保存密码，只有root权限才能看到**

### 1.1.1 新增用户

`useradd`命令用于新增

	useradd [－d home] [－s shell] [－c comment] [－m [－k template]] [－f inactive] [－e expire ] [－p passwd] [－r] name
	
	－c：加上备注文字，备注文字保存在passwd的备注栏中。　
	－d：指定用户登入时的启始目录。
	－D：变更预设值。
	－e：指定账号的有效期限，缺省表示永久有效。
	－f：指定在密码过期后多少天即关闭该账号。
	－g：指定用户所属的群组。
	－G：指定用户所属的附加群组。
	－m：自动建立用户的登入目录。
	－M：不要自动建立用户的登入目录。
	－n：取消建立以用户名称为名的群组。
	－r：建立系统账号。
	－s：指定用户登入后所使用的shell。
	－u：指定用户ID号。

流程如下：

1. 创建用户后，将信息写入passwd和shadow中
2. 复制/etc/skel下所有文件到该用户的家目录，我们可以自制模板，然后新建用户后就会copy进他的家目录下
3. 如果没有-g指定群组则会自动创建和用户名同名的群组，如创建beginman用户，自动创建beginman群组并所属。

### 1.1.2 修改密码
`passwd`命令，如`passwd beginman`,如果没有设置密码则在/etc/shadow下该用户的记录中第二列将是`!!`,说明不允许用户登录系统，只有通过`passwd`修改密码才行。如果是当前用户则直接输入`passwd`命令即可。

### 1.2.3 修改用户
`usermod`命令修改

	usermod [-LU][-c <备注>][-d <登入目录>][-e <有效期限>][-f <缓冲天数>][-g <群组>][-G <群组>][-l <帐号名称>][-s <shell>][-u <uid>][用户帐号]
	
	-c<备注> 　修改用户帐号的备注文字。 
	-d登入目录> 　修改用户登入时的目录。 
	-e<有效期限> 　修改帐号的有效期限。 
	-f<缓冲天数> 　修改在密码过期后多少天即关闭该帐号。 
	-g<群组> 　修改用户所属的群组。 
	-G<群组> 　修改用户所属的附加群组。 
	-l<帐号名称> 　修改用户帐号名称。 
	-L 　锁定用户密码，使密码无效。 
	-s<shell> 　修改用户登入后所使用的shell。 
	-u<uid> 　修改用户ID。 
	-U 　解除密码锁定。

我们常用来修改用户名，用户群组，冻结或解冻账号，如果冻结了则shadow密码处有一个`!`表示。

### 1.2.4 删除用户
`userdel`进行删除

### 1.2.5 新增用户组
`groupadd`命令

我们可以通过`/etc/group`查看

### 1.2.6 删除用户组
`groupdel`进行删除

### 1.2.7 查看用户
`w`,`who`,`users`均可。

下面是小总结：

- `su`可切换root， `su -`则是切换root并使用root环境，`su other`则切换其他用户，同理加`-`则表示用其环境，su命令不安全，一般使用`sudo`执行root身份命令
- `sudo`会先检查`/etc/sudoers`判断该用户是否有sudo权限，有则要求用户输入自己的密码，正确则以root身份执行命令。在使用sudo前先在`/etc/sudoers`修改配置

# 二. 常见问题
## 2.1 无法登录
当我创建普通账号时，突然 root 远程连接的终端自动断开，再次以 root 身份登录却登录不上，密码都正确，但是以普通用户身份登录能成功，查看 passwd 时发现：

	root:x:0:0:root:/root:/bin/bash 
	operator:x:11:0:operator:/root:/sbin/nologin

参考我在v2ex发布的帖子：[是什么鬼导致了 root nologin？](http://v2ex.com/t/235891),

解决办法是：

>centos root密码输入正确，但本地还是无法登录，输入错误的密码时，会提示密码错误。后来才发现是root 用户被禁用了，禁用的命令是： usermod -s /sbin/nologin。问题找到了就好解决，进入单用户模式，编辑/etc/passwd这个文件，找到root用户信息这一行会发现root 用户确实被禁用了root:x:0:0:root:/root:/sbin/nologin **把后面的“/sbin/nologin”　修改为“/bin/bash”，修改后的信息是：root:x:0:0:root:/root:/bin/bash ，重启机器问题解决了。**

这里我弄巧成拙了，重启以单用户模式修改了root密码

## 2.2 忘记root密码
即**重启进入单用户模式重新修改root密码**，可参考[http://www.centoscn.com/CentOS/2015/0806/5972.html](http://www.centoscn.com/CentOS/2015/0806/5972.html)

## 2.3 ssh无法登录
新开一普通用户，ssh连接到远程到一台LINUX服务器，密码正确，一直连接不上。用root登录查看`/var/log/secure`日志，发现如下信息：

	......
	User XXX from x.x.x.x(IPAddr) not allowed because not listed in AllowUsers
	Jan 21 09:43:32 mx100 sshd[15997]: input_userauth_request: invalid user XXX 
	......

原因就是：**创建用户不在SHHD的允许登录列表中。在/etc/ssh/sshd_config配置文件中加入新建用户**

	# override default of no subsystems
	Subsystem       sftp    /usr/libexec/openssh/sftp-server
	AllowUsers root
	AllowUsers admin
	AllowUsers xxx

为了安全性最好限制root远程登录

	/etc/ssh/sshd_config
	PermitRootLogin no
	AllowUsers theOne Beos

只允许特定的用户登录，这个设置里面，只有 theOne 和 Beos才能登录

最后重启sshd服务

	service sshd restart

参考：

《Linux系统命令以Shell脚本实践指南》

《构建高性能的Linux服务器》

[linux 普通用户无法登录问题](http://libo93122.blog.163.com/blog/static/1221893820126100267829/)



