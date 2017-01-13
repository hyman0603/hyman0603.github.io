---
layout: post
title: "wks-05: 入门简单的Linux系统扫描技术及安全防范"
category: "一周新技术"
---

这是关于慕课网[Linux系统扫描技术及安全防范](http://www.imooc.com/learn/344)的学习，虽然讲的比较浅但是很入门，最近比较忙，『一周技术』类博客一直滞后，没什么亮点，暂且忙完这阵子吧。

**网络入侵方式： 踩点-网络扫描-查点-提权等。**

# 一. 主机扫描
## 1.1 fping

[fping](http://fping.org/)并行发送，批量给目标主机ping请求，测试主机存活情况。`fping -h`来查看具体使用。可参看[比ping更强大的fping](http://blog.csdn.net/taotianjin/article/details/12614995)这篇博客进一步学习。

常用参数：

- `-a` 只显示存活主机（`-u`相反）
- `-g` 支持主机段方式，如fping 192.168.1.1 192.168.1.255 或 192.168.1.1/24
- `-f` 通过文件读取

如：

```bash
$ fping -g 192.168.1.1/24
192.168.1.1 is alive
192.168.1.149 is alive
192.168.1.2 is alive
192.168.1.104: error while sending ping: No route to host
192.168.1.3 is unreachable
.....
```

## 1.2 hping 

[hping](http://www.hping.org/)支持使用TCP/IP数据包组装，分析工具，对一些屏蔽掉ICMP包的主机，`ping`和`fping`就没辙了，那么可用`hping`。

对目标端口发起tcp探测： `-p`端口， `-S` 设置TCP SYN包。还可以伪造来源IP，模拟Ddos攻击，加`-a`伪造IP地址。

来测试下，在一台主机上（简称主机B）查看正监听的TCP端口：

```bash
$ netstat -ltnp
tcp        0      0 0.0.0.0:8380         0.0.0.0:*                   LISTEN
tcp        0      0 0.0.0.0:80                  0.0.0.0:*                   LISTEN
tcp        0      0 0.0.0.0:29362               0.0.0.0:*                   LISTEN
```

在主机A 通过 hping 来测试下：

```bash
$ sudo hping -p 80 -S x.x.x.x
HPING x.x.x.x (en0 x.x.x.x): S set, 40 headers + 0 data bytes
len=44 ip=x.x.x.x ttl=50 DF id=0 sport=80 flags=SA seq=0 win=14600 rtt=417.8 ms
len=44 ip=x.x.x.x ttl=50 DF id=0 sport=80 flags=SA seq=1 win=14600 rtt=335.6 ms
...
```

其实`ping`也可，那么现在让主机B关闭ICMP，不允许ICMP协议进行连接, 则在主机B写入内核一个参数使其生效：

```bash
# 主机B
$ sysctl -w net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_echo_ignore_all = 1
```

那么现在就ping不通了

```bash
# 主机A
ping x.x.x.x
PING x.x.x.x (x.x.x.x): 56 data bytes
Request timeout for icmp_seq 0
Request timeout for icmp_seq 1
...
```

但是我们的`hping`依然可用，它通过TCP形式来ping。

```bash
# 主机A
# 使用TCP探测方式
$ sudo hping -S x.x.x.x

HPING x.x.x.x (en0 x.x.x.x): S set, 40 headers + 0 data bytes
len=40 ip=x.x.x.x ttl=50 DF id=0 sport=0 flags=RA seq=0 win=0 rtt=196.5 ms
len=40 ip=x.x.x.x ttl=50 DF id=0 sport=0 flags=RA seq=1 win=0 rtt=202.2 ms
^C
--- x.x.x.x hping statistic ---
3 packets tramitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 196.5/206.0/219.3 ms

# 通过默认ICMP依然ping不通
$ sudo hping x.x.x.x

HPING x.x.x.x (en0 x.x.x.x): NO FLAGS are set, 40 headers + 0 data bytes
^C
--- x.x.x.x hping statistic ---
5 packets tramitted, 0 packets received, 100% packet loss
round-trip min/avg/max = 0.0/0.0/0.0 ms
```

# 二. 路由扫描

查询一个主机到另一个主机经过路由的跳数和数据延迟等，常用工具`traceroute`,`mtr`.

![](http://beginman.qiniudn.com/2016-12-14-14817262650489.jpg)

traceroute主要参数：

- 默认使用UDP协议（30000以上端口）
- `-T` 使用TCP ，`-p` 指定端口
- `-I` 使用ICMP

如下traceroute下慕课网网站。

```bash
# -n 不显示主机名
$ traceroute -n jianshu.com
```

![](http://beginman.qiniudn.com/2016-12-14-14817268912205.jpg)

![](http://beginman.qiniudn.com/2016-12-14-14817271758161.jpg)

关于mtr则是比较直观，连通性。在我的Centos下还么有这个工具，可通过`yum install mtr` 安装。

```bash
$ mtr www.imooc.com
```

一直在变化，很直观，如下图。

![](http://beginman.qiniudn.com/2016-12-14-14817274160357.jpg)

# 三. 批量服务扫描

**目的：**

- 批量主机存活扫描
- 针对主机服务扫描

命令： `nmap`, `ncat`

![](http://beginman.qiniudn.com/2016-12-14-14817275021405.jpg)

```bash
# 批量主机扫描
$ nmap -sP 192.168.1.1/24

Starting Nmap 7.12 ( https://nmap.org ) at 2016-12-14 23:01 CST
Nmap scan report for 192.168.1.1
Host is up (0.0032s latency).
Nmap scan report for 192.168.1.4
Host is up (0.096s latency).
Nmap scan report for 192.168.1.149
Host is up (0.00066s latency).
Nmap done: 256 IP addresses (3 hosts up) scanned in 2.97 seconds
```

**端口扫描**

```bash
# -p 0-n 指定0~n端口范围，默认是0-1024，同时包含一些常用的如80**等
$ sudo nmap -sS -p 0-n ip 或域名
```

![](http://beginman.qiniudn.com/2016-12-14-14817285006945.jpg)

# 四. linux防范恶意扫描安全策略

**常用的攻击方法：**

- SYN 攻击 SYN flood洪水攻击
- DDOS 拒绝服务攻击
- 恶意扫描攻击(暂无办法解决)

>SYN攻击属于DOS攻击的一种，它利用TCP协议缺陷，通过发送大量的半连接请求，耗费CPU和内存资源。SYN攻击除了能影响主机外，还可以危害路由器、防火墙等网络系统，事实上SYN攻击并不管目标是什么系统，只要这些系统打开TCP服务就可以实施。



![](http://beginman.qiniudn.com/2016-12-14-14817295497179.jpg)

![](http://beginman.qiniudn.com/2016-12-14-14817300354822.jpg)

**解决方案：**

- 增加backlog大小
- 调小重试次数
- 发现此类找不到地址则拒绝三次握手，不再重试。

![](http://beginman.qiniudn.com/2016-12-14-14817303279943.jpg)

![](http://beginman.qiniudn.com/2016-12-14-14817304139867.jpg)


**参数解释：** 

1. tcp_max_syn_backlog是SYN队列的长度，加大SYN队列长度可以容纳更多等待连接的网络连接数 
2. tcp_syncooking是一个开关，是否打开syn cookie功能，该功能可以防止部分的SYN攻击 
3. tcp_synack_retries和tcp_syn_retries定义SYN的重试连接次数，将默认的参数减小来控制SYN连接次数 

编辑完成之后使内核生效 `sysctl -p`

# 参考

[慕课网：Linux系统扫描技术及安全防范](http://www.imooc.com/learn/344)
[CentOS防止syn攻击](http://www.dockerwy.com/dockewy/221)


