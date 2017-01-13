---
layout: post
title: "数据库设计小结"
description: "数据库设计小结"
category: "Mysql"
tags: [Mysql]
---

<p>这两天看慕课网<a href="http://www.imooc.com/learn/117">《数据库设计那些事》</a>教学视频，总结了几点，算是观后感吧。</p>

<p>数据库设计步骤：</p>

<ol>
<li>需求分析：根据业务，明确数据属性和特点</li>
<li>逻辑设计：ER图逻辑建模</li>
<li>物理设计：选择数据库系统，合适的表结构设计，字段选择，命名规范</li>
<li>维护优化：数据，索引进行维护优化，如表的拆分等</li>
</ol>

<!--more-->

<h1>一.需求分析</h1>

<ol>
<li>选择属性：尽可能的罗列所有属性</li>
<li>可选唯一标识属性：如通过用户名或身份证号码等唯一标示一个User.</li>
<li>存储特点：永久or临时or生命周期，分表或分库等</li>
</ol>

<h1>二.逻辑设计</h1>

<h2>2.1 ER图</h2>

<p>常见er图工具：
Visio，erstudio,MySQL workbench</p>

<p>下面是er图设计需要明白的基础点：</p>

<p><img src="http://beginman.qiniudn.com/名词解释.jpg" alt="" /></p>

<p><img src="http://beginman.qiniudn.com/ER图.jpg" alt="" /></p>

<h2>2.2 数据库范式</h2>

<p><strong>针对关系数据库</strong>，数据库范式就是设计规范，各种范式呈递增，越高的数据库冗余越小，目前关系数据库有六种范式：第一范式（1NF）、第二范式（2NF）、第三范式（3NF）、巴斯-科德范式（BCNF）、第四范式(4NF）和第五范式（5NF，还又称完美范式）。</p>

<h3>2.2.1.第一范式(1NF)</h3>

<p>表中所有字段都是单一属性（由基本的数据结构组成如整数，字符串等），不可再分，也就是第一范式要求数据库表都是二维表。简单的说，就是每一个列（属性）只有一个，没有重复。</p>

<h3>2.2.2.第二范式(2NF)</h3>

<p>所有单关键字表都符合第二范式</p>

<p><img src="http://beginman.qiniudn.com/2nf.jpg" alt="" /></p>

<h3>2.2.3.第三范式(3NF)</h3>

<p>可参考<a href="http://www.zhihu.com/question/24696366">知乎：解释一下关系数据库的第一第二第三范式？</a></p>

<h1>三.物理设计</h1>

<ol>
<li>选择合适数据库</li>
<li>命名规范</li>
<li>选择合适的字段类型</li>
</ol>

<p><img src="http://beginman.qiniudn.com/type_choice.jpg" alt="" /></p>

<p><img src="http://beginman.qiniudn.com/type_choice2.jpg" alt="" /></p>

<p><img src="http://beginman.qiniudn.com/type_choice3.jpg" alt="" /></p>

<p><code>char</code> vs <code>varchar</code>: 当长度基本一致则选择char,否则选择varchar; 如果列中最大数据长度小于50Byte,考虑char, 如果该列很少使用则基于节省空间和减少I/O,可以考虑varchar</p>

<p><code>decimal</code> vs <code>float</code>: decimal用于存储高精度浮点数，占用空间也大，float存储精度弱于decimal.</p>

<p><strong>在高并发的互联网开发中使用外键会带来负面影响</strong></p>

<ol>
<li>写入数据都会去查询是否有外键约束，降低写入效率</li>
<li>增加维护成本</li>
<li>虽然不建议使用外键约束但是相关联的列上一定要建立索引</li>
</ol>

<p><strong>避免使用触发器</strong></p>

<p><strong>严禁使用预留字段</strong></p>

<h3>反范式化</h3>

<ol>
<li>减少表关联数量，减少磁盘I/O操作</li>
<li>增加数据的读写效率</li>
<li>要适度使用</li>
</ol>

<p><img src="http://beginman.qiniudn.com/againNF.jpg" alt="" /></p>

<p><img src="http://beginman.qiniudn.com/nf1.jpg" alt="" /></p>

<p><img src="http://beginman.qiniudn.com/nf2.jpg" alt="" /></p>

<p><img src="http://beginman.qiniudn.com/nf3.jpg" alt="" /></p>

<p><img src="http://beginman.qiniudn.com/nf4.jpg" alt="" /></p>

<h1>四.维护优化</h1>

<h2>4.1 维护数据字典</h2>

<p>mysql:</p>

<p>使用数据库本身的备注字段：</p>

<pre><code>CREATE TABLE blogs(
    blog_id int(11) AUTO_INCREMENT NOT NULL COMMENT '自增id',
    author VARCHAR(10) NOT NULL COMMENT '作者',
    PRIMARY KEY (blog_id)
) COMMENT '博客表';
</code></pre>

<p>查看表注释：</p>

<pre><code>SELECT table_name,table_comment FROM information_schema.tables  WHERE table_schema = 'your db' AND table_name ='your table'
</code></pre>

<p>查看列注释：</p>

<pre><code>SHOW FULL COLUMNS FROM blogs;
# 查看指定列
SHOW FULL COLUMNS FROM blogs WHERE FIELD='author';
# 查看指定属性
SELECT column_name, column_comment FROM information_schema.columns WHERE table_schema ='your db'  AND table_name = 'your table' 
</code></pre>

<p>修改已创建了的表注释:</p>

<pre><code>ALTER TABLE blogs COMMENT '修改表注释'
ALTER TABLE blogs MODIFY COLUMN author VARCHAR(100) COMMENT '修改列注释'
</code></pre>

<h2>4.2 维护表结构</h2>

<p>对列的更改会锁表，可能会产生阻塞，在mysql5.5之前可以使用第三方工具如<code>pt-online-schema-change</code>进行在线变更表结构，它首先会建立一个临时表，把原表中数据copy进去，对临时表重命名。在mysql5.6之后本身已经支持在线变更。</p>

<p>更改后表结构后要及时维护数据字典</p>

<p>数据库以页进行存储，一页中存储的行数越多，I/O效率越高，但表变的很宽，字段很多时意味着每行的数据量增大，则在一页中存储的行数就变少，I/O效率就降低了，所以我们对宽表进行垂直拆分，分成几张窄表，则每行的长度就不会太大</p>

<p><img src="http://beginman.qiniudn.com/表的垂直和水平拆分.jpg" alt="" /></p>

<p>当一张表数据量太大，我们要减少其数据量，则可以进行水平拆分，</p>

<p><img src="http://beginman.qiniudn.com/水平拆分.jpg" alt="" /></p>
