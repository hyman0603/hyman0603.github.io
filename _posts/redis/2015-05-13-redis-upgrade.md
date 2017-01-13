---
layout: post
title: "redis升级过程"
description: "redis升级过程"
category: "redis"
tags: [redis]
---
<p>对于<a href="http://redis.io/commands/sadd"><code>sadd</code>命令</a>:>= 2.4: Accepts multiple member arguments. Redis versions before 2.4 are only able to add a single member per call.</p>

<p>对于之前安装的2.2版本的redis必须要升级。</p>

<p>下面是<strong>暴力升级流程</strong>：</p>

<!--more-->

<h2>1.备份</h2>

<h3>1.备份数据</h3>

<p>如果redis安装目录没有dump.rdb文件,可以用<code>SAVE</code> 命令创建当前数据库的备份。</p>

<pre><code>redis 127.0.0.1:6379&gt; SAVE 
OK
</code></pre>

<p>该命令将在 redis 安装目录中创建dump.rdb文件。创建 redis 备份文件也可以使用命令 <code>BGSAVE</code>，该命令在后台执行。</p>

<p><strong>如果需要恢复数据，只需将备份文件 (dump.rdb) 移动到 redis 安装目录并启动服务即可</strong></p>

<p>获取 redis 安装目录可以使用 <code>CONFIG</code> 命令，如下所示：</p>

<pre><code>redis 127.0.0.1:6379&gt; CONFIG GET dir
1) "dir"
2) "/usr/local/redis/bin"
</code></pre>

<h3>2.备份配置文件</h3>

<p>将配置文件备份一下</p>

<h2>2.安装最新版本</h2>

<pre><code>wget http://download.redis.io/releases/redis-2.8.5.tar.gz
tar zxvf redis-2.8.5.tar.gz
cd redis-2.8.5
make
make install
</code></pre>

<p><strong>我们最好依照源码里的READ.md文件进行安装配置，如下提示：</strong></p>

<p>In order to install Redis binaries into /usr/local/bin just use:</p>

<pre><code>% make install
</code></pre>

<p>You can use "make PREFIX=/some/other/directory install" if you wish to use a
different destination.</p>

<p>Make install will just install binaries in your system, but will not configure
init scripts and configuration files in the appropriate place. This is not
needed if you want just to play a bit with Redis, but if you are installing
it the proper way for a production system, we have a script doing this
for Ubuntu and Debian systems:</p>

<pre><code>% cd utils
% ./install_server
</code></pre>

<p>The script will ask you a few questions and will setup everything you need
to run Redis properly as a background daemon that will start again on
system reboots.</p>

<p>如果<code>make test</code> 提示：You need tcl 8.5 or newer in order to run the Redis test，则直接安装</p>

<p>centos:</p>

<pre><code>yum install -y tcl
</code></pre>

<p>ubuntu:</p>

<pre><code>sudo apt-get remove tk8.4 tcl8.4
sudo apt-get install tk8.5 tcl8.5
</code></pre>

<p>在redis源码目录下utils目录对应一些常用的脚本，如install_server.sh，redis_init_script等。</p>

<p><strong>将redis_init_script管理脚本拷贝到/usr/bin/下就可以方便的对redis进行管理了</strong></p>

<h2>3.卸载旧redis版本</h2>

<pre><code>apt-get remove redis
#删除残留文件
find / -name redis
rm -rf var/lib/redis/
rm -rf /var/log/redis
rm -rf /etc/redis/
rm -rf /usr/bin/redis-*
</code></pre>

<h2>4.数据恢复，配置更改</h2>

<ol>
<li>将之前dump.rdb 备份文件copy到新目录下如 /var/lib/redis/6379/</li>
<li>更改6379.conf(或redis.conf)与之前的copy文件相符合，能替换是最好的了，不能替换就一项一项的更改</li>
<li>启动redis服务  redis-server 6379.conf</li>
</ol>

<p><strong>如何做到平滑升级呢？这是我下一步要研究的方向。</strong></p>
