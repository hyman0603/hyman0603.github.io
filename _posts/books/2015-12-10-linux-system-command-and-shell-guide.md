---
layout: post
title: "《Linux系统命令及Shell脚本实践指南》读书笔记"
description: "《Linux系统命令及Shell脚本实践指南》读书笔记"
category: "book"
tags: [book]
---

《Linux系统命令及Shell脚本实践指南》这本书挺基础的但是挺有用，比起买的[《shell脚本学习指南》](http://book.douban.com/subject/3519360/)读起来还是比较顺畅的。

![](http://img3.douban.com/mpic/s27193072.jpg)

# 一.Linux用户管理
之前写一篇博文： [**Linux用户的那些麻烦事**](http://beginman.cn/linux/2015/11/13/linux-users-about/)作为总结。

# 二.Linux文件管理和文件系统
## 文件属性
包括：**权限属性和隐藏属性**，权限属性如下：

	[team@iZ25mamf7hhZ ~]$ ls -al
	total 64
	-rw-------   1 team team 1681 Dec 10 17:53 .bash_history
	-rw-r--r--   1 team team  124 Oct 16  2014 .bashrc
	-rw-rw-r--   1 team team    0 Dec 10 22:51 b.txt
	drwxrwxr-x   5 team team 4096 Sep 29 11:27 .npm
	drwxr-xr-x   2 root root 4096 Nov 21 10:13 shells

`ls -al`: `-a`参数列出隐藏属性，`-l`列出每个文件的详细信息。

![](https://camo.githubusercontent.com/db59036cd049fd7375b5a85636c233c77a5d497e/687474703a2f2f3766766635362e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f6c696e75785f66696c65322e706e67)

还是参考之前写的关于[《鸟哥的Linux私房菜》](https://github.com/BeginMan/BookNotes/blob/master/Linux/%E9%B8%9F%E5%93%A5%E7%9A%84Linux%E7%A7%81%E6%88%BF%E8%8F%9C%E5%9F%BA%E7%A1%80%E7%AF%87/%E4%B8%80.linux%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90.md)

关于文件的隐藏属性用`lsattr`来显示，**默认情况下文件的隐藏属性都没有设置**。

	lsattr
	----ia---j--- ./lsattr_test

和chmod，ls这些命令相比，chmod只是改变文件的读写、执行权限，更底层的属性控制是由`chattr`来更改文件属性。

语法：

	chattr [ -RV ] [ -v version ] [ mode ] files...

最关键的是在`[mode]`部分，`[mode]`部分是由`+-=`和`[ASacDdIijsTtu]`这些字符组合的，这部分是用来控制文件的:

- `+`：在原有参数设定基础上，追加参数。
- `-`：在原有参数设定基础上，移除参数。
- `=`：更新为指定参数设定
- `A`：文件或目录的atime(access time)不可被修改(modified)
- `S`：硬盘I/O同步选项，功能类似sync
- **`a`：即append，设定该参数后，只能向文件中添加数据，而不能删除，多用于服务器日志文 件安全，只有root才能设定这个属性。**
- **`i`：设定文件不能被删除、改名、设定链接关系，同时不能写入或新增内容。i参数对于文件 系统的安全设置有很大帮助。**

最常用的还是`a,i`,如下将my.log属性改成只能向尾部添加而不能删除：

	[root@ ~]# lsattr my.log
	-------------e- my.log
	
	[root@ ~]# chattr +a my.log
	[root@ ~]# lsattr my.log
	-----a-------e- my.log
	
	[root@ ~]# echo "good">>my.log
	[root@ ~]# cat my.log
	good
	[root@ ~]# echo "job">>my.log
	
	[root@ ~]# echo "如果我追到你，我就把你嘿嘿嘿">my.log
	-bash: my.log: Operation not permitted

	[root@ ~]# rm my.log
	rm: remove regular file `my.log'? y
	rm: cannot remove `my.log': Operation not permitted

	[root@ ~]# chattr -a my.log
	[root@ ~]# rm -f my.log

**你看，设置了`a`属性，root都干不掉它。但是可以向后追加数据， 如果你`vi`编辑它也不允许。如果设置了`i`属性则文件无法写入，更名，删除, 他们对提升系统安全性有很大帮助。**

## 查看文件类型

**(1)`ls`可以通过第一个字符判断文件类型：**

- `d`代表目录
- `l`：连接文件
- `b`:块文件
- `c`：字符文件
- `s`:socket文件
- `-`:普通文件
- `p`:管道文件

**(2)`file`可以直接告诉我们文件类型**

	[root@ ~]# file install.log
	install.log: ASCII text
	[root@ ~]# file /usr/bin/aclocal
	/usr/bin/aclocal: a /usr/bin/perl -w script text executable
	[root@ ~]# file demo/
	demo/: directory

## 查找文件

**(1).`find`**

之前写过[**13个实用的Linux find命令示例**](http://beginman.cn/linux/2015/04/06/Linux-find/),`find`常用参数如下：

- `-name filename`: 按文件名查找
- `-perm`:按文件权限查找
- `-user username`:按用户名查找
- `-mtime -n/+n`:查找n天内/n天前更改过的文件
- `-atime -n/+n`:查找n天内/n天前访问过的文件
- `-ctime -n/+n`:查找n天内/n天前创建过的文件
- `-newer filename`:查找更改时间比filename新的文件
- `-type b/d/c/p/l/f/s`: 按文件类型查找
- `-size`:按文件大小查找
- `depth n`:最大查找目录深度

**(2).`locate`**

数据库查找，比`find`块，但是或许没有find准确，因为linux每天会同步系统所有文件，对于未同步的文件则查不到，但可以使用`updatedb`同步，个人建议还是用`find`更加强大些。

**(3).`which/whereis` 查找执行文件**

	[root@ ~]# which passwd
	/usr/bin/passwd

	[root@ ~]# whereis passwd
	passwd: /usr/bin/passwd /etc/passwd /usr/share/man/man1/passwd.1.gz

`which`从系统PATH变量所定义的目录来查找可执行文件的绝对路径，`whereis`不仅如此还可查找对应的man文件。

## 文件系统

- 树形文件存储结构
- VFS(Virtual File System, 文件系统+虚拟文件系统， 因为linux任何数据都是0，1格式，为了实现上面的目录+文件树形结构形式，linux采用VFS方案)
- 磁盘分区，创建文件系统，挂载等操作

# 三.字符处理

## 管道
管道如同水管一样，有大小，linux管道固定大小缓冲区，为1页(4k字节)，管道是一种使用非常频繁的**通信机制**，可以用管道符`|`连接进程，常用来作为接收数据管道命令有：sed,awk,cut,head,top,less,more,wc,join,sort,split 等等，都是些文本处理命令。

推荐阅读：[**linux shell 管道命令(pipe)使用及与shell重定向区别**](http://www.cnblogs.com/chengmo/archive/2010/10/21/1856577.html)

## grep搜索
`grep`如果匹配到信息则会打印符合条件的所有行

	grep [-icnv] '需要匹配的字符' 文件名

	-i:不区分大小写
	-c:统计包含匹配的行数
	-n:输出行号
	-v:反向匹配

如匹配`install.log`文件：

	# 匹配安装成功的项目
	$ grep -in 'installing' install.log
	191:Installing acl-2.2.49-6.el6.x86_64
	192:Installing attr-2.4.44-7.el6.x86_64

	# 匹配安装失败的项目
	$ grep -inv 'installing' install.log
	2:warning: libgcc-4.4.7-4.el6.x86_64

## sort排序

`sort`对数据进行排序：

	sort [-ntkr] 文件名
	-n:采用数字排序
	-t:指定分隔符
	-k:指定第几列
	-r:反序

如下：

	➜  ~  cat sort.txt 
	b:10
	d:2
	a:20
	c:1
	f:4

	➜  ~  sort sort.txt 
	a:20
	b:10
	c:1
	d:2
	f:4

`sort`默认按第一列正序排列

	# -t指定冒号分隔符，-k用于指定排序的列，-n指明用数字排序
	➜  ~  cat sort.txt|sort -t ':' -k 2 -n
	c:1
	d:2
	f:4
	b:10
	a:20	

## uniq删除重复

`uniq`语法如下：

	uniq [-ic]
	-i:忽略大小写
	-c:计算重复的行数

注意：**`uniq`要与`sort`一起使用才行，先将文件sort(这样相同的内容就能连续排列)，然后在uniq去重。否则不起作用**

## cut截取文本
语法如下：

	cut -f指定的列 -d'分隔符'

	# 按冒号分隔然后打印第二行的数字
	➜  ~  cat sort.txt|cut -f2 -d ':'
	10
	2
	20
	1
	4
	# 按冒号分隔然后打印第一行的字符
	➜  ~  cat sort.txt|cut -f1 -d ':'
	b
	d
	a
	c
	f
	# 按冒号分隔然后打印第一，二行
	➜  ~  cat sort.txt|cut -f1,2 -d ':'
	b:10
	d:2
	a:20
	c:1
	f:4

打印多行如： `-f1, 6-8`打印第一行，和6到8行；`-f1-5, 7-10`：打印1到5，7到10行

## tr文本转换或删除
	
	#删除冒号
	➜  ~  cat sort.txt|tr -d ':'       
	b10
	d2
	a20
	c1
	f4
	#全部转换大写
	  ~  cat sort.txt|tr '[a-z]' '[A-Z]' 
	B:10
	D:2
	A:20
	C:1
	F:4

## paste文本合并
`paste`用于合并文本，中间用tab隔开，如下：

	➜  ~  cat c.txt d.txt 
	a
	b

	1
	2

	# 合并
	➜  ~  paste c.txt d.txt 
	a	1
	b	2
	# 以冒号分隔合并
	➜  ~  paste -d ':' c.txt d.txt
	a:1
	b:2

## split分隔大文件
`split`用来分隔大文件可以按照行数和大小分，如果是二进制文件则没有行的概念则只能按照大小分，实验如下：

	# 创建几十兆大文件
	➜  ~ for i in `seq 1000000`;do echo "goodjobbeginmanhelloworld">>big.txt;done
	# 查看刚才创建的大文件
	➜ ~  du -h big.txt                                                           
 	26M	big.txt

 	# 方式1.按行分，每10000行分隔
 	split -l 100000 big.txt small_each_100000_lines_

 	# 方式2.按大小分，每10兆分隔
 	split -b 10m big.txt small_each_10mb_file

 	# 查看所分
 	➜  ~  du -h small_each_10*
	2.5M	small_each_100000_lines_ab
	2.5M	small_each_100000_lines_ac
	2.5M	small_each_100000_lines_ad
	2.5M	small_each_100000_lines_ae
	2.5M	small_each_100000_lines_af
	2.5M	small_each_100000_lines_ag
	2.5M	small_each_100000_lines_ah
	2.5M	small_each_100000_lines_ai
	2.5M	small_each_100000_lines_aj
	2.5M	small_each_100000_lines_ak

	10.0M	small_each_10mb_fileaa
	10.0M	small_each_10mb_fileab
	5.6M	small_each_10mb_fileac

# 四.网络管理

## ifconfig

![](http://beginman.qiniudn.com/ifconfig.png)

- eth0:表示以太网的第一块网卡，是Ethernet的前三个字母， 0表示第一块网卡，第二块则eth1
- Link encap:指封装方式为以太网
- HWaddr:网卡硬件地址(MAC地址)
- inet addr:该网卡当前的IP地址
- Broadcast:广播地址（由系统根据IP和掩码算出来的，一般不需要手工设置）
- Mask：掩码
- UP：说明网卡处于活动状态(UP BROADCAST RUNNING MULTICAST)
- MTU: 代表网卡的最大存储单元，即网卡一次所能传输的最大分包。(MTU:1500)
- RX,TX：分别代表接收和发送的包，如：(RX packets:227365807 errors:0 dropped:0 overruns:0 frame:0)
- collisions:代表发送的冲突数，**如果发现不为0则可能是网络存在故障**（collisions:0）
- txqueuelen：代表传输缓冲区的长度(txqueuelen:1000)
- 第二个设备lo表示主机的环回地址，用于本机通信

`ifconfig`相关命令：

	ifconfig eth0   # 显示具体设备信息
	ifconfig eth0 192.168.159.130/24  # 手工指定eth0的IP地址
	ifconfig -a     # 显示所有包括不活动的网卡信息
	ifconfig eth0 down/up    # 断开和启动eth0网卡，等同于：ifdown eth0/ifup eth0

## 常见网络故障排查
网络故障分两种：

- 硬件故障：网卡损坏(电子元件)，链路故障(网线或水晶头)等
- 软件故障：网卡驱动故障等

排查步骤如下：

1. 确认网卡本身是否正常工作：利用`ping`输入ping 127.0.0.1,换回接口，是TCP/IP协议栈正常工作的前提，如果ping不同则本机TCP/IP协议栈有问题。
2. 确认是否硬件故障，如果第一步ping通则表示正常
3. 确认二层网络设备如交换机或HUB是否正常工作： ping 同网段的其他主机
4. 确认是否ping通网关IP，如果数据包能正常到达网卡则说明主机和本地网络都工作正常
5. ping公网IP，确认是否正确设置nat或路由设置
6. 确认是否ping通公网上的某个域名，ping不通则说明DNS设置有问题

# 五.进程管理
思考：

- 什么是进程？
- 进程间的同步与互斥是个什么关系？
- 如何查看进程？
- 管理进程的命令有哪些？
- 怎么去管理进程？

## 进程理解
进程是一块很大的面包，一口是吃不下的，需要慢慢消耗。如果去面试的时候，面试官问你如何理解进程？你该怎么回答呢？ 如果是我，我可能会回答*进程是操作系统基本的执行单元。*，回答的我自己的蒙圈了，如果要理解好进程，可以从以下几个方面入手：

1. 进程？程序？
2. 应用程序?
3. 动还是静？

好了，上面的关键词我们可以理解进程为：

1. 进程表示程序的一次执行过程；或者，说进程是操作系统当前运行的程序
2. 进程是应用程序的实例，一个应用程序可能包含N多个进程
3. 启动进程了，那么进程是“动”的（我们的程序是一个静态的概念），操作系统为每个进程都进行了资源调度和独立内存分配

我们上面数进程是“动”的，这只是宏观上的，进程也有状态，如下：

- 运行态： 表示程序当前实际占用着CPU等资源
- 就绪态： 表示除CPU外一切运行资源都已经就绪，等待操作系统分配CPU资源，一旦分配了CPU资源则即可运行
- 阻塞态： 表示程序员运行过程中由于需要请求外部资源（如I/O资源，打印机等低速的或同一时刻只能独享的资源）而当前无法继续执行，从而主动放弃当前CPU资源转而等待所请求的资源。

## 同步与互斥
同步，互斥是进程间的两大关系。从两者语义上就明白它们是什么关系：

- 互斥：进程间不能同时运行，必须等待一个进程运行完毕另一个进程才能运行，如一些临界资源。
- 同步：通过某种通信机制实现信息交互

## 进程查看
涉及`ps`,`top`命令

![](http://beginman.qiniudn.com/linux-ps.png)

## 进程操作

### (1) `kill`,`killall`命令杀死进程

	kill [信号代码] 进程ID

常用信号代码：

- HUP(1)：重启(软重启，不会改变主进程的PID)
- KILL(9)：强制删掉(直接被系统终止，而没有清理之前申请的内存，这会造成一定的内存泄露)
- TERM(15)：正常结束(是linux默认的中断信号，使进程正常退出)

如果不想用进程ID，还可以使用进程名，则使用`killall`命令：

	killall 进程名

如停止系统中所有的httpd进程，`killall httpd`, 该命令不仅简单而且更加安全。

### (2) `lsof`查看进程打开的文件
`lsof`是list open files的缩写，列出所有打开的文件的工具(Linux一切皆文件)

![](http://beginman.qiniudn.com/lsof-linux.png)

### (3) `nice`,`renice`调整进程优先级
在`top`对应NI字段，标记了对应进程的优先级，数值越低优先级越高；RP字段也表示优先级，其实Linux使用动态优先级，即一个进程的最终优先级=优先级+nice优先级

	#nice用于启动进程时赋予优先级
	nice -n -10 ./myjob.sh

	#renice用于已经启动过的进程，如更改PID为5555的进程
	renice -10 -p 5555

修改优先级的方法有很多，这里仅列出两个。

# 六.软件安装
Linux下软件安装主要还是针对不同的发行版本的不同安装方式，但源码安装时通用的，这里以Centos为例。

## 源码包编译安装
在源码安装过程中往往涉及到环境变量，最通用的方法则是：

	echo "export PATH=$PATH:/mypath" >> /etc/rc.local

源码编译安装的过程如下：（针对模块化，如果是简单的则直接编译安装）：

1. 运行configure命令，结合参数生成Makefile
2. 运行make命令生成各类模块和主程序
3. 运行make install 将必要的文件复制到安装目录中

之前写过[**make,make install命令**](http://beginman.cn/operation/2015/09/07/make/)

## RPM安装软件
源码安装有很大的弊端，如下：

- 繁琐，不安全
- 耗时长
- 无法完成软件管理如安装，卸载，升级等

为了解决此类问题，RedHat采用了**RPM(RedHat Package Manager)包管理机制**,通过`rpm`命令管理，如下：

![](http://beginman.qiniudn.com/rpm-linux.png)

常用操作：

	#install
	rpm -ivh package.rpm

	#测试软件安装包，不做真实安装
	rpm -ivh --test package.rpm

	#安装软件包，并重新定义安装路径
	rpm -ivh --relocate /=/usr/local/package.rpm

	#强行安装并忽略依赖关系
	rpm -ivh package.rpm --force --nodeps

	#升级软件包
	rpm -Uvh package.rpm

	#强行升级并忽略依赖关系
	rpm -Uvh package.rpm --force --nodeps

	#删除软件包，并忽略依赖关系
	rpm -e PAKCAGE_NAME --nodeps   # 只是包名，不需要跟版本号

	#导入签名
	rpm --import RPM-GPG-KEY

	#查询某个包是否安装
	rpm -q PAKCAGE_NAME

	#列出所有已安装的包
	rpm -qa

	#查询某个文件属于哪个包
	rpm -qf /etc/auto.misc

	#查询某个已安装软件包含的所有文件
	rpm -ql PAKCAGE_NAME

	#查询某个包的依赖关系
	rpm -qpR PAKCAGE_NAME-VSERSION.rpm

	#查询某个包的信息
	rpm -qpi PAKCAGE_NAME-VSERSION.rpm

	#删除软件包
	rpm -e PAKCAGE_NAME

## yum安装
yum(Yellow dog Updater, Modified, 基于RPM的Shell前端包管理器) 能够从指定服务器安装，删除，升级软件，最大的好处是**自动解决依赖关系**。
	yum [options] [command] [package ...]

	其中的[options]是可选的:
		选项包括-h（帮助）
		-y（当安装过程提示选择全部为"yes"）
		-q（不显示安装的过程）等
	[command]为所要进行的操作
	[package ...]是操作的对象

# 七. vim
之前总结过[**vim学习**](http://beginman.cn/linux/2015/04/07/vim-learn/),作为基础学习，深入学习的话[《Vim实用技巧》](http://book.douban.com/subject/25869486/)是一本不错的好书，这里列出之前没有总结过的。

vim多行编辑：

`ctrl+v`组合键进入`—VISUAL BLOCK—`模式，可以通过`hjkl`方向键选择，可以使用一次性的对选中进行删除(d),复制(y),粘贴(p).

vim编辑多个文件：

vim a.txt b.txt c.txt …. 编辑多个文件，但是默认显示第一个，按`:n`切换下一个(先得save文件后)，按`:N`回到上一个，按`:files`查看打开多少个文件。

# 八. 正则表达式

(1). `.`:点符号匹配除换行符以外的任意一个字符，`r.t`匹配rot,rit,但非root，`r..t`匹配root,tddt.

(2). `*`:星号匹配0次或多次，如ab*,匹配ab,abc,abcd.., `r.*t`则匹配包含r的任意长度字符再后紧跟一个t,如： Services:/var/root:/usr/bin/false

(3). `\{n,m\}`解析

	`\{n\}`匹配前面的字符n次，如：匹配root：
	➜  wx  grep 'ro\{2\}t' /etc/passwd
	root:*:0:0:System Administrator:/var/root:/bin/sh
	daemon:*:1:1:System Services:/var/root:/usr/bin/false
	_cvmsroot:*:212:212:CVMS Root:/var/empty:/usr/bin/false

(4). `\{n,\}`:匹配前面的字符至少n次，包含n

(5). `\{n,m\}`:匹配前面字符n到m次

	➜  wx  grep 'ro\{1,2\}t' /etc/passwd
	root:*:0:0:System Administrator:/var/root:/bin/sh
	daemon:*:1:1:System Services:/var/root:/usr/bin/false
	_uucp:*:4:4:Unix to Unix Copy Protocol:/var/spool/uucp:/usr/sbin/uucico
	_cvmsroot:*:212:212:CVMS Root:/var/empty:/usr/bin/false

(6). `^`:匹配开头，`$`匹配尾部，`^$`匹配空。如匹配以r开头，以h结尾，中间任意字符串：
	
	➜  wx  grep '^r.*h$' /etc/passwd
	root:*:0:0:System Administrator:/var/root:/bin/sh

(7). `[]`匹配任意出现在方括号中的任一字符，如：

	- 匹配所有字母：[A-Za-z]
	- 配合`^`取反，如[^A-D]匹配不是A到D
	- 匹配手机号，^1[38][0-9]\{9\}

(8). `\`转义，如`[-]`就要写成`[\\-]`

(9). `\<`，`\>`分别用来界定单词左边界和右边界，如`\<hello`:匹配以hello开头单词，`hello\>`以此结尾，`\<hello\>`精确匹配hello

	➜  wx  cat a.txt
	hello
	helloworld
	hello world
	➜  wx  grep '\<hello' a.txt
	hello
	helloworld
	hello world
	➜  wx  grep 'hello\>' a.txt
	hello
	hello world
	➜  wx  grep '\<hello\>' a.txt
	hello
	hello world

(10). `\d`匹配数字

(11). `\b`匹配单词边界，如`\bhello\b`精确匹配hello,同[7]

(12). `\B`匹配非单词边界，如`hello\B`可匹配helloworld中的hello

(13). `\w`匹配字母，数字，下划线，同[A-Za-z0-9]

(14). `\W`匹配非…，同[^A-Za-z0-9]

(15). `\n`匹配一个换行符

(16). `\r`匹配一个回车符

(17). `\s`匹配空白，S则匹配非空白

(18). `?`:匹配前一个字符0或1次，如`ro?t`—>root,rot

(19). `+`…1次以上，`ro+t`->`rot`,`root`

(20). `|`或




