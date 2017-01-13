---
layout: post
title: "linux服务进程管理与分析"
description: "linux服务进程管理与分析"
category: "linux"
tags: [linux服务器]
---

<h2>1.查看linux占用内存/CPU最多的进程</h2>

<p>查使用内存最多的10个进程</p>

<pre><code>ps -aux | sort -k4nr | head -n 10
</code></pre>

<p>或者top （然后按下M，注意大写）</p>

<p>查使用CPU最多的10个进程</p>

<pre><code>ps -aux | sort -k3nr | head -n 10
</code></pre>

<p>或者top （然后按下P，注意大写）</p>

<!--more-->

<h2>2.查看Nginx,Apache,Mysql并发连接数</h2>

<p>1、查看Web服务器（Nginx Apache）的并发请求数及其TCP连接状态：</p>

<pre><code>netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
</code></pre>

<p>或者：</p>

<pre><code>netstat -n | awk '/^tcp/ {++state[$NF]} END {for(key in state) print key,"t",state[key]}'
</code></pre>

<p>返回结果一般如下：</p>

<pre><code>LAST_ACK 5 （正在等待处理的请求数）
SYN_RECV 30
ESTABLISHED 1597 （正常数据传输状态，可以理解为接近并发连接数）
FIN_WAIT1 51
FIN_WAIT2 504
TIME_WAIT 1057 （处理完毕，等待超时结束的请求数）
</code></pre>

<p>其他参数说明：</p>

<pre><code>CLOSED：无连接是活动的或正在进行
LISTEN：服务器在等待进入呼叫
SYN_RECV：一个连接请求已经到达，等待确认
SYN_SENT：应用已经开始，打开一个连接
ESTABLISHED：正常数据传输状态
FIN_WAIT1：应用说它已经完成
FIN_WAIT2：另一边已同意释放
ITMED_WAIT：等待所有分组死掉
CLOSING：两边同时尝试关闭
TIME_WAIT：另一边已初始化一个释放
LAST_ACK：等待所有分组死掉
</code></pre>

<p>2、查看Nginx并发进程数</p>

<pre><code>ps -ef | grep nginx | wc -l
</code></pre>

<p>返回的数字就是nginx的并非进程数，如果是apache则执行</p>

<pre><code>ps -ef | grep httpd | wc -l
</code></pre>

<p>还可以用如下命令：</p>

<pre><code>watch -n 1 -d "pgrep nginx|wc -l"
</code></pre>

<p>3、查看Web服务器进程连接数：</p>

<pre><code>netstat -antp | grep 80 | grep ESTABLISHED -c
</code></pre>

<p>4、查看MySQL进程连接数：</p>

<pre><code>ps -axef | grep mysqld -c
</code></pre>

<h2>3.其他</h2>

<p><strong><a href="http://6244685.blog.51cto.com/6234685/1316234">Linux下杀僵尸进程办法</a></strong></p>

<h2>参考</h2>

<p><a href="http://blog.is36.com/check_top_of_linux_memory_CPU_in_process/">http://blog.is36.com/check_top_of_linux_memory_CPU_in_process/</a></p>

<p><a href="http://www.ha97.com/4106.html">http://www.ha97.com/4106.html</a></p>
