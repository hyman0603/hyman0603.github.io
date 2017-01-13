---
layout: post
title: "mysql data目录恢复"
description: "mysql data目录恢复"
category: "mysql"
tags: [备份]
---

<p>如果不能完成某件事就要找出原因，否则就不要轻易的放弃，对于这次服务器坏掉对其mysql data目录数据恢复就是一教训。</p>

<p>这里总结一下作为警戒：</p>

<p>1.Mysql 安装在windows后一般会有两个文件夹，一个Mysql安装目录，一个是Mysql data存放目录，默认位置是：C:/ProgramData/Mysql/data/， 一般ProgramData是隐藏的。</p>

<p>2.Mysql data存放目录是可以改变的，不过要记着在哪个位置，里面包含的组织结构如下：</p>

<pre><code>2014/12/30  22:48                       2FB8.err
2014/12/30  22:48                   2FB8.pid
2014/12/30  16:35                       ibdata1
2014/12/30  22:48                       ib_logfile0
2014/12/30  16:29                       ib_logfile1
2014/12/30  16:28    &lt;DIR&gt;              mysql
2014/12/30  16:28    &lt;DIR&gt;              performance_schema
2014/12/29  14:33    &lt;DIR&gt;              test
2014/12/30  16:28    &lt;DIR&gt;              tuijian
2014/11/13  15:14                       WIN-BOMPLP44I83.err
2014/11/13  15:14                   WIN-BOMPLP44I83.pid
</code></pre>

<p>其中数据库以文件夹为表现形式，文件夹下是各个表的组织结构包含以<code>.frm</code>后缀的表结构和<code>db.opt</code>是用来记录该库的默认字符集编码和字符集排序规则用的.</p>

<p>3.当把原先数据库下的data copy到新数据库data下，要注意首先要关闭mysql. 对于win7+ 则在搜索程序和文件 下输入cmd ，然后以管理员身份运行，输入<code>net stop mysql</code>停掉mysql服务.</p>

<p>4.不要把整个data数据都覆盖掉，这里只需要保留安装mysql所自动生成的文件夹， 然后再将旧data除此之外的其他文件夹和文件复制进去即可。 这样做的原因是如果覆盖了mysql和performance_schema则会初始化原先设置的密码，这样就不好了，如果遇到这种情况那么就要恢复这两个文件即可。</p>

<p>5.覆盖之后就要重启mysql <code>net start mysql</code>,打开数据库就会发现之前的数据库已经恢复了，然后再<code>mysqldump -u root -p yourdatabase &gt; db.sql</code> 进行数据导出做个备份即可。</p>
