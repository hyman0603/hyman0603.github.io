---
layout: post
title: "Linux防火墙"
description: "防火墙概念，linux防火墙设置"
category: "python"
tags: [python]
---
防火墙这个概念我们都清楚，我们伟大的GFW就是世界上最大的防火墙。

![](http://beginman.qiniudn.com/gfw.jpg)

linux下防火墙工作在**网络层**， 就是**对TCP/IP数据包进行过滤，属于包过滤防火墙**，包过滤机制是：`netfilter`, 管理防火墙规则命令工具：`iptables`

# 一.iptables的规则表、链结构
iptables管理4个表、以及他们的规则链:

## 1.filter
用于路由网络数据包

- INPUT 网络数据包流向服务器
- OUTPUT 网络数据包从服务器流出
- FORWARD 网络数据包经服务器路由

## 2.nat
nat,用于NAT表.NAT(Net Address Translation )是一种IP地址转换方法。

- PREROUTING, (prerouting, pre-route，预路由, 到达前)网络数据包到达服务器时可以被修改
- POSTROUTING, (postrouting, post-route，流出前) 网络数据包在即将从服务器发出时可以被修改
- OUTPUT 网络数据包流出服务器

## 3.mangle
mangle,用于修改网络数据包的表，如TOS(Type Of Service),TTL(Time To Live),等

- INPUT 网络数据包流向服务器
- OUTPUT 网络数据包流出服务器
- FORWARD 网络数据包经由服务器转发
- PREROUTING 网络数据包到达服务器时可以被修改
- POSTROUTING 网络数据包在即将从服务器发出时可以被修改

## 4.raw
raw, 用于决定数据包是否被跟踪机制处理

- OUTPUT 网络数据包流出服务器
- PREROUTING 网络数据包到达服务器时可以被修改

# 二.数据包过滤匹配流程
- 规则表之间的优先顺序:raw>mangle>nat>filter
- 规则链之间的优先顺序:入站数据流向>转发数据流向>出站数据流向

# 三.管理和配置Iptables规则

## 1.基本语法

	iptables [-t 表名] 命令选项 [链名] [条件匹配] [-] 目标动作或跳转

- 表名链名用于指定iptables命令所做对象，未指定默认filter表
- 命令选项指于管理iptables规则的方式（插入、删除··）；
- 条件匹配指定对条件的符合而处理；
- 目标动作或跳转指定数据包的处理方式。

## 2.管理iptables规则

### 2.1控制选项

- `-A` 在链尾添加一条规则
- `-D` 从链中删除一条规则
- `-I` 在链中插入一条规则
- `-R` 修改、替换某链的某规则
- `-L` 列出某个链上的规则
- `-F` 清空链，删除链上的所有规则
- `-N` 创建一个新链
- `-X` 删除某个规则链
- `-P` 定义某个链的默认策略
- `-n` 数字形式显示结果
- `-v` 查看规则列表详细信息
- `-V` 查看iptables命令工具版本
- `-h` 查看命令帮助信息
- `-line-numbers` 查看规则列表，显示顺序号

### 2.2增加、插入、删除和替换规则

	iptables  [-t表名]  <-A | I | D | R> 链名 [规则编号] [-i | o 网卡名称] [-p 协议类型] [-s 源IP地址 | 源子网] [--sport 源端口号] [-d目标IP地址 | 目标子网] [--dport目标端口号] <-j动作>

参数说明如下。

- `[-t表名]`：定义默认策略将应用于哪个表，可以使用filter、nat和mangle，如果没有指定使用哪个表，iptables就默认使用filter表。
- `-A`：新增加一条规则，该规则将会增加到规则列表的最后一行，该参数不能使用规则编号。
- `-I`：插入一条规则，原本该位置上的规则将会往后顺序移动，如果没有指定规则编号，则在第一条规则前插入。
- `-D`：从规则列表中删除一条规则，可以输入完整规则，或直接指定规则编号加以删除。
- `-R`：替换某条规则，规则被替换并不会改变顺序，必须要指定替换的规则编号。
- `<链名>`：指定查看指定表中哪个链的规则列表，可以使用INPUT、OUTPUT、FORWARD、PREROUTING、OUTPUT和POSTROUTING。
- `[规则编号]`：规则编号用于插入、删除和替换规则时用，编号是按照规则列表的顺序排列，规则列表中第一条规则的编号为1。
- `[-i | o 网卡名称]`：i是指定数据包从哪块网卡进入，o是指定数据包从哪块网卡输出。网卡名称可以使用ppp0、eth0和eth1等。
- `[-p 协议类型]`：可以指定规则应用的协议，包含TCP、UDP和ICMP等。
- `[-s 源IP地址 | 源子网]`：源主机的IP地址或子网地址。
- `[--sport 源端口号]`：数据包的IP的源端口号。
- `[-d目标IP地址 | 目标子网]`：目标主机的IP地址或子网地址。
- `[--dport目标端口号]`：数据包的IP的目标端口号。 
- `<-j动作>`：处理数据包的动作，各个动作的详细说明可以参考表10-3。 

#### (1).插入

	iptables -I INPUT -p tcp --dport 80 -j ACCEPT

#### (2).查看
	  
	查看Filter表的INPUT链中的所有规则，同时显示顺序号

	[root@xx ~]# iptables -L INPUT --line-numbers
	Chain INPUT (policy ACCEPT)
	num  target     prot opt source               destination
	1    ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:8070
	2    ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:8090
	3    ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:ospf-lite
	4    ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:cslistener
	5    ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:irdmi
	6    ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:mysql
	7    ACCEPT     all  --  anywhere             anywhere            state RELATED,ESTABLISHED
	8    ACCEPT     icmp --  anywhere             anywhere
	9    ACCEPT     all  --  anywhere             anywhere
	10   ACCEPT     tcp  --  anywhere             anywhere            state NEW tcp dpt:ssh
	11   REJECT     all  --  anywhere             anywhere            reject-with icmp-host-prohibited

	查看filter表各链中所有规则的详细信息，以数字形式显示地址和端口信息
	[root@lingzhixun ~]# iptables -vnL
	Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
	 pkts bytes target     prot opt in     out     source               destination
	   14  1780 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:8070
	   14  1780 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:8090
	   49  5978 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:8899
	  251 42782 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:9000
	 2793  174K ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:8000
	19175   25M ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:3306
	 508K  272M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
	   69  5520 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
	 1412 84664 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
	   12   768 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22
	 3783  494K REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

	Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
	 pkts bytes target     prot opt in     out     source               destination
	    0     0 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

	Chain OUTPUT (policy ACCEPT 304K packets, 48M bytes)
	 pkts bytes target     prot opt in     out     source               destination

#### (3).删除、清空规则:

删除Filter表的INPUT链中的第2条规则

	[root@s2 ~]# iptables -D INPUT 2

清空filter表、nat表、mangle表各链中的所有规则	

	[root@s2 ~]# iptables -F
	[root@s2 ~]# iptables -t nat -F
	[root@s2 ~]# iptables -t mangle -F

#### (4). 设置规则链的默认策略
最基本的两种策略为ACCEPT（允许）、DROP（丢弃）

将filter表中的FORWARD规则链的默认策略设为 DROP

	[root@s2 ~]# iptables -t filter -P FORWARD DROP

将filter表中的 OUTPUT规则链的默认策略设为 ACCEPT

	[root@s2 ~]# iptables -P OUTPUT ACCEPT

#### (5). 获得iptables相关选项用法的帮助信息
查看iptables命令中关于icmp协议的信息

	[root@s2 ~]# iptables -p icmp -h



#### (6). 新增、删除自定义规则链
清空raw表中自定义的所有规则链

	[root@s2 ~]# iptables -t raw -X


### 2.3 基础命令

如下开放80，22，3306端口：

	#/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
	#/sbin/iptables -I INPUT -p tcp --dport 22 -j ACCEPT
	#/sbin/iptables -I INPUT -p tcp --dport 3306 -j ACCEPT

然后保存：

	#/etc/rc.d/init.d/iptables save
 
查看打开的端口：
	
	# /etc/init.d/iptables status

	表格：filter
	Chain INPUT (policy ACCEPT)
	num  target     prot opt source               destination
	1    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:8070
	2    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:8090
	3    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:8899
	4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:9000
	5    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:8000
	6    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:3306
	7    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
	8    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
	9    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
	10   ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22
	11   REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

	Chain FORWARD (policy ACCEPT)
	num  target     prot opt source               destination
	1    REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

	Chain OUTPUT (policy ACCEPT)
	num  target     prot opt source               destination


重启后永久性生效：
	
	开启：chkconfig iptables on
	关闭：chkconfig iptables off

即时生效，重启后失效：

	开启：service iptables start
	关闭：service iptables stop

关闭防火墙

	/etc/init.d/iptables stop
	service iptables stop # 停止服务

查看防火墙信息

	/etc/init.d/iptables status

重启防火墙以便改动生效:(或者直接重启系统)

	/etc/init.d/iptables restart

将更改进行保存
	
	/etc/rc.d/init.d/iptables save

## 3.条件匹配

### 1>.通用条件匹配

一般直接使用，而不依赖于其他的条件匹配及其扩展。常见匹配方式如下：
	
协议匹配：用于检查数据包的网络协议

	拒绝进入防火墙的所有icmp协议数据包
	[root@s2 ~]# iptables -I INPUT -p icmp -j REJECT
	
	允许防火墙转发除icmp协议以外的所有数据包（“！”反取）	
	[root@s2 ~]# iptables -A FORWARD -p ! icmp -j ACCEPT
	[root@s2 ~]# iptables -L FORWARD
	Chain FORWARD (policy DROP)
	target     prot opt source               destination         
	ACCEPT    !icmp --  anywhere             anywhere    
	
地址匹配：用于检查数据包的IP地址、网络地址。
	
	拒绝转发来自192.168.1.11主机的数据，允许来自192.168.0.0/24网段数据
	[root@s2 ~]# iptables -A FORWARD -s 192.168.1.11 -j REJECT
	[root@s2 ~]# iptables -A FORWARD -s 192.168.0.0/24 -j ACCEPT
	
网络接口匹配：用于检查数据包从防火墙的哪个接口进入或离开
	
	丢弃从外网接口（eth1）进入防火墙本机的源地址为私网地址的数据包
	[root@s2 ~]# iptables -A INPUT -i eth1 -s 192.168.0.0/16 -j DROP
	[root@s2 ~]# iptables -A INPUT -i eth1 -s 172.16.0.0/12 -j DROP
	[root@s2 ~]# iptables -A INPUT -i eth1 -s 10.0.0.0/8 -j DROP
	
	封堵IP地址段！并2小时后解锁
	[root@s2 ~]# iptables -I INPUT -s 10.20.30.0/24 -j DROP
	[root@s2 ~]# iptables -I FORWARD -s 10.20.30.0/24 -j DROP
	[root@s2 ~]# at now +2 hours
	at> iptables -D INPUT 1
	at> iptables -D FORWARD 1
	at> <EOT>
	job 1 at 2010-04-25 17:43

### 2>.隐含条件匹配

通常需要以指定的协议匹配为前提，对应功能由iptables自动装载内核。常见的隐含匹配方式如下：

端口匹配：用于检查数据包的TCP或UDP端口号

	仅允许系统管理员从202.13.0.0/16网段使用SSH方式远程登录防火墙主机
	[root@s2 ~]# iptables -A INPUT -p tcp --dport 22 -s 202.13.0.0/16 -j ACCEPT
	[root@s2 ~]# iptables -A INPUT -p tcp --dport 22 -j DROP
	
	允许本机开放TCP端口的 20 ~ 1024 提供的应用服务
	[root@s2 ~]# iptables -A INPUT -p tcp --dport 20:1024 -j ACCEPT
	[root@s2 ~]# iptables -A OUTPUT -p tcp --sport 20:1024 -j ACCEPT
	
	允许转发来自192.168.0.0/24局域网段的DNS解析请求数据包
	[root@s2 ~]# iptables -A FORWARD -s 192.168.0.0/24 -p udp --dport 53 -j ACCEPT
	[root@s2 ~]# iptables -A FORWARD -d 192.168.0.0/24 -p udp --sport 53 -j ACCEPT

TCP标记匹配：用于检查数据包的TCP标记位

	拒绝从外网接口（eth1）直接访问防火墙本机的数据包，但允许响应防火墙TCP请求的数据包进入
	[root@s2 ~]# iptables -P INPUT DROP
	[root@s2 ~]# iptables -I INPUT -i eth1 -p tcp --tcp-flags SYN, RST, ACK SYN -j REJECT
	[root@s2 ~]# iptables -I INPUT -i eth1 -p tcp --tcp-flags ! --syn -j ACCEPT

ICMP类型匹配：用于检查ICMP数据包

	禁止其他主机ping防火墙主机，但是允许防火墙能ping其他主机
	[root@s2 ~]# iptables -A INPUT -p icmp --icmp-type Echo-Request -j DROP
	[root@s2 ~]# iptables -A INPUT -p icmp --icmp-type Echo-Reply -j ACCEPT
	[root@s2 ~]# iptables -A INPUT -p icmp --icmp-type destination-Unreachable -j ACCEPT

显示条件匹配：需要额外的内核模块提供，因此需要手工指定匹配方式

	MAC地址匹配：主要检查数据包的源MAC地址
		[root@s2 ~]# iptables -A FORWARD -m mac --mac-source 00:0c:29:27:55:3F -j DROP

	多端口匹配：检查数据包的源端口、目标端口时，用于匹配多个不连续的端口号。
		[root@s2 ~]# iptables -A INPUT -p tcp -m multiport --dport 20.21.24.11.1250:1280 -j ACCEPT

	多IP地址匹配：检查数据包的源地址、目标地址时，用于匹配一段范围内的IP地址
		[root@s2 ~]# iptables -A FORWARD -p tcp -m iprange --src-range 192.168.1.20-192.168.1.99 -j DROP

状态匹配：基于iptables的状态跟踪机制，检查数据包的连接状态

	禁止转发与正常TCP连接无关的非--syn请求数据包
		[root@s2 ~]# iptables -A FORWARD -m state --state NEW -p tcp ! --syn -j DROP

## 4.数据包控制

最常见处理方式;
	
- ACCEPT:允许数据包通过
- DROP：直接丢弃数据包，不给任何回应信息
- REJECT：拒绝数据包通过，必要时发个响应信息
- LOG: 记录日志信息，将数据包递给下一条规则
		
对于尝试通过SSH方式登录防火墙主机的访问数据，记录日志信息并禁止访问

	[root@s2 ~]# iptables -I INPUT -p tcp --dport 22 -j DROP
	[root@s2 ~]# iptables -I INPUT -p tcp --dport 22 -j LOG
	
- 用户自定义链：将数据传给用户自定义的链进行处理
		
自定义一个链MYLAN 转发至192.168.1.0/24 网段数据包交给该链中的规则处理。

	[root@s2 ~]# iptables -t filter -N MYLAN
	[root@s2 ~]# iptables -A FORWARD -s 192.168.1.0/24 -j MYLAN
	[root@s2 ~]# iptables -A FORWARD -d 192.168.1.0/24 -j MYLAN
	[root@s2 ~]# iptables -A MYLAN -p icmp -j DROP
	
- SNAT:（源地址转换）修改数据包的源IP地址
- DNAT:（目标地址转换）修改数据包的目标IP地址

# 三.实际应用
一方面是为了限制，另一方面则是为了安全，如linux服务器被攻击了，我们可以找到对应的ip或ip端加入黑名单。

封掉一个ip：

	iptables -I INPUT -s ***.***.***.*** -j DROP

解封一个ip：

	iptables -D INPUT -s ***.***.***.*** -j DROP

清空封掉的ip：

	iptables -flush

添加IP段到封停列表中：

	iptables -I INPUT -s 192.0.0.0/8 -j DROP

只允许特定ip访问某端口：

	iptables -I INPUT -p TCP –dport 80 -j DROP
	iptables -I INPUT -s 46.166.150.22 -p TCP –dport 80 -j ACCEPT

以下是端口，先全部封再开某些的IP

	iptables -I INPUT -p tcp –dport 9889 -j DROP
	iptables -I INPUT -s 192.168.1.0/24 -p tcp –dport 9889 -j ACCEPT

如果用了NAT转发记得配合以下才能生效

	iptables -I FORWARD -p tcp –dport 80 -j DROP
	iptables -I FORWARD -s 192.168.1.0/24 -p tcp –dport 80 -j ACCEPT

只能收发邮件，别的都关闭

	iptables -I Filter -m mac –mac-source 00:0F:EA:25:51:37 -j DROP
	iptables -I Filter -m mac –mac-source 00:0F:EA:25:51:37 -p udp –dport 53 -j ACCEPT
	iptables -I Filter -m mac –mac-source 00:0F:EA:25:51:37 -p tcp –dport 25 -j ACCEPT
	iptables -I Filter -m mac –mac-source 00:0F:EA:25:51:37 -p tcp –dport 110 -j ACCEPT

IPSEC NAT 策略

	iptables -I PFWanPriv -d 192.168.100.2 -j ACCEPT
	iptables -t nat -A PREROUTING -p tcp –dport 80 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.100.2:80
	 
	iptables -t nat -A PREROUTING -p tcp –dport 1723 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.100.2:1723
	 
	iptables -t nat -A PREROUTING -p udp –dport 1723 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.100.2:1723
	 
	iptables -t nat -A PREROUTING -p udp –dport 500 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.100.2:500
	 
	iptables -t nat -A PREROUTING -p udp –dport 4500 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.100.2:4500
 
FTP服务器的NAT

	iptables -I PFWanPriv -p tcp –dport 21 -d 192.168.1.22 -j ACCEPT
	iptables -t nat -A PREROUTING -p tcp –dport 21 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.1.22:21
	只允许访问指定网址

	iptables -A Filter -p udp –dport 53 -j ACCEPT
	iptables -A Filter -p tcp –dport 53 -j ACCEPT
	iptables -A Filter -d www.ctohome.com -j ACCEPT
	iptables -A Filter -d www.guowaivps.com -j ACCEPT
	iptables -A Filter -j DROP

开放一个IP的一些端口，其它都封闭

	iptables -A Filter -p tcp –dport 80 -s 192.168.1.22 -d www.pconline.com.cn -j ACCEPT
	iptables -A Filter -p tcp –dport 25 -s 192.168.1.22 -j ACCEPT
	iptables -A Filter -p tcp –dport 109 -s 192.168.1.22 -j ACCEPT
	iptables -A Filter -p tcp –dport 110 -s 192.168.1.22 -j ACCEPT
	iptables -A Filter -p tcp –dport 53 -j ACCEPT
	iptables -A Filter -p udp –dport 53 -j ACCEPT
	iptables -A Filter -j DROP

多个端口

	iptables -A Filter -p tcp -m multiport –destination-port 22,53,80,110 -s 192.168.20.3 -j REJECT

连续端口

	iptables -A Filter -p tcp -m multiport –source-port 22,53,80,110 -s 192.168.20.3 -j REJECT iptables -A Filter -p tcp –source-port 2:80 -s 192.168.20.3 -j REJECT

指定时间上网

	iptables -A Filter -s 10.10.10.253 -m time –timestart 6:00 –timestop 11:00 –days Mon,Tue,Wed,Thu,Fri,Sat,Sun -j DROP
	iptables -A Filter -m time –timestart 12:00 –timestop 13:00 –days Mon,Tue,Wed,Thu,Fri,Sat,Sun -j ACCEPT
	iptables -A Filter -m time –timestart 17:30 –timestop 8:30 –days Mon,Tue,Wed,Thu,Fri,Sat,Sun -j ACCEPT

禁止多个端口服务

	iptables -A Filter -m multiport -p tcp –dport 21,23,80 -j ACCEPT

将WAN 口NAT到PC

	iptables -t nat -A PREROUTING -i $INTERNET_IF -d $INTERNET_ADDR -j DNAT –to-destination 192.168.0.1

将WAN口8000端口NAT到192。168。100。200的80端口

	iptables -t nat -A PREROUTING -p tcp –dport 8000 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.1.22:80

MAIL服务器要转的端口

	iptables -t nat -A PREROUTING -p tcp –dport 110 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.1.22:110
	iptables -t nat -A PREROUTING -p tcp –dport 25 -d $INTERNET_ADDR -j DNAT –to-destination 192.168.1.22:25

只允许PING 202。96。134。133,别的服务都禁止

	iptables -A Filter -p icmp -s 192.168.1.22 -d 202.96.134.133 -j ACCEPT
	iptables -A Filter -j DROP

禁用BT配置

	iptables –A Filter –p tcp –dport 6000:20000 –j DROP

禁用QQ防火墙配置

	iptables -A Filter -p udp –dport ! 53 -j DROP
	iptables -A Filter -d 218.17.209.0/24 -j DROP
	iptables -A Filter -d 218.18.95.0/24 -j DROP
	iptables -A Filter -d 219.133.40.177 -j DROP

基于MAC，只能收发邮件，其它都拒绝

	iptables -I Filter -m mac –mac-source 00:0A:EB:97:79:A1 -j DROP
	iptables -I Filter -m mac –mac-source 00:0A:EB:97:79:A1 -p tcp –dport 25 -j ACCEPT
	iptables -I Filter -m mac –mac-source 00:0A:EB:97:79:A1 -p tcp –dport 110 -j ACCEPT

禁用MSN配置

	iptables -A Filter -p udp –dport 9 -j DROP
	iptables -A Filter -p tcp –dport 1863 -j DROP
	iptables -A Filter -p tcp –dport 80 -d 207.68.178.238 -j DROP
	iptables -A Filter -p tcp –dport 80 -d 207.46.110.0/24 -j DROP

只允许PING 202。96。134。133 其它公网IP都不许PING

	iptables -A Filter -p icmp -s 192.168.1.22 -d 202.96.134.133 -j ACCEPT
	iptables -A Filter -p icmp -j DROP

禁止某个MAC地址访问internet:

	iptables -I Filter -m mac –mac-source 00:20:18:8F:72:F8 -j DROP

禁止某个IP地址的PING:

	iptables –A Filter –p icmp –s 192.168.0.1 –j DROP

禁止某个IP地址服务：

	iptables –A Filter -p tcp -s 192.168.0.1 –dport 80 -j DROP
	iptables –A Filter -p udp -s 192.168.0.1 –dport 53 -j DROP

只允许某些服务，其他都拒绝(2条规则)

	iptables -A Filter -p tcp -s 192.168.0.1 –dport 1000 -j ACCEPT
	iptables -A Filter -j DROP

禁止某个IP地址的某个端口服务

	iptables -A Filter -p tcp -s 10.10.10.253 –dport 80 -j ACCEPT
	iptables -A Filter -p tcp -s 10.10.10.253 –dport 80 -j DROP

禁止某个MAC地址的某个端口服务

	iptables -I Filter -p tcp -m mac –mac-source 00:20:18:8F:72:F8 –dport 80 -j DROP

禁止某个MAC地址访问internet:

	iptables -I Filter -m mac –mac-source 00:11:22:33:44:55 -j DROP

禁止某个IP地址的PING:

	iptables –A Filter –p icmp –s 192.168.0.1 –j DROP

参考：

[1.linux防火墙基础和管理设置iptables规则](http://xiaozhuang.blog.51cto.com/4396589/874244)

[2.CentOS: 开放80、22、3306端口操作](http://blog.sina.com.cn/s/blog_3eba8f1c0100tsox.html)

[3.Linux防火墙：iptables禁IP与解封IP常用命令](http://yusi123.com/3092.html)

