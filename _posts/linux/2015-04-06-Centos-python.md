---
layout: post
title: "Centos 升级python"
description: "Centos 升级python"
category: "Python"
tags: [Python]
---
<p>Centos 6.4 python 2.6 升级到 2.7的时候要注意yum的配置，否则yum就不能用。鉴于此，总结如下：</p>

<pre><code>查看Python 版本:
python -V       # Python 2.6.6

#下载python2.7
wget http://python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2 

#解压
tar -jxvf Python-2.7.3.tar.bz2

#安装
cd Python-2.7.3  
./configure
make all
make install
make clean
make distclean

#建立软链接
mv /usr/bin/python /usr/bin/python2.6.6
ln -s /usr/local/bin/python2.7 /usr/bin/python

#查看版本确认
python -V  # 2.7.3
</code></pre>

<p>至此，Python已经完成了升级，但是要确保yum能用</p>

<pre><code>#测试
yum
...  报错了
</code></pre>

<p><strong>如果打yum命令，你会发现报错了。提示你可能是python版本不对。所以我们要把yum依旧指向老的python2.6版本：</strong></p>

<pre><code>vim /usr/bin/yum
# 将开头换成如下：
#!/usr/bin/python2.6
</code></pre>
