---
layout: post
title: "Mysql Join语法解析与性能分析"
description: "Mysql Join语法解析与性能分析"
category: "Mysql"
tags: [Mysql]
---

<h2>一．Join语法概述</h2>

<p>join 用于多表中字段之间的联系，语法如下：</p>

<pre><code>... FROM table1 INNER|LEFT|RIGHT JOIN table2 ON conditiona
</code></pre>

<p>table1:左表；table2:右表。</p>

<p>JOIN 按照功能大致分为如下三类：</p>

<p><code>INNER JOIN</code>（内连接,或等值连接）：取得两个表中存在连接匹配关系的记录。</p>

<p><code>LEFT JOIN</code>（左连接）：取得左表（table1）完全记录，即是右表（table2）并无对应匹配记录。</p>

<p><code>RIGHT JOIN</code>（右连接）：与 LEFT JOIN 相反，取得右表（table2）完全记录，即是左表（table1）并无匹配对应记录。</p>

<p>注意：<strong>mysql不支持<code>Full join</code></strong>,不过可以通过<code>UNION</code> 关键字来合并 LEFT JOIN 与 RIGHT JOIN来模拟FULL join.</p>

<!--more-->

<p>接下来给出一个列子用于解释下面几种分类。如下两个表(A,B)</p>

<pre><code>mysql&gt; select A.id,A.name,B.name from A,B where A.id=B.id;
+----+-----------+-------------+
| id | name       | name             |
+----+-----------+-------------+
|  1 | Pirate       | Rutabaga      |
|  2 | Monkey    | Pirate            |
|  3 | Ninja         | Darth Vader |
|  4 | Spaghetti  | Ninja             |
+----+-----------+-------------+
4 rows in set (0.00 sec)
</code></pre>

<h2>二.Inner join</h2>

<p>内连接，也叫等值连接，inner join产生同时符合A和B的一组数据。</p>

<pre><code>mysql&gt; select * from A inner join B on A.name = B.name;
+----+--------+----+--------+
| id | name   | id | name   |
+----+--------+----+--------+
|  1 | Pirate |  2 | Pirate |
|  3 | Ninja  |  4 | Ninja  |
+----+--------+----+--------+
</code></pre>

<p><img src="http://images.cnblogs.com/cnblogs_com/BeginMan/486940/o_sql1.png" alt="" /></p>

<h2>三.Left join</h2>

<pre><code>mysql&gt; select * from A left join B on A.name = B.name;
#或者：select * from A left outer join B on A.name = B.name;

+----+-----------+------+--------+
| id | name      | id   | name   |
+----+-----------+------+--------+
|  1 | Pirate    |    2 | Pirate |
|  2 | Monkey    | NULL | NULL   |
|  3 | Ninja     |    4 | Ninja  |
|  4 | Spaghetti | NULL | NULL   |
+----+-----------+------+--------+
4 rows in set (0.00 sec)
</code></pre>

<p>left join,（或<strong>left outer join:在Mysql中两者等价，推荐使用left join.</strong>）左连接从左表(A)产生一套完整的记录,与匹配的记录(右表(B)) .如果没有匹配,右侧将包含null。</p>

<p><img src="http://images.cnblogs.com/cnblogs_com/BeginMan/486940/o_sql3.png" alt="" /></p>

<p>如果想只从左表(A)中产生一套记录，但不包含右表(B)的记录，可以通过设置where语句来执行，如下：</p>

<pre><code>mysql&gt; select * from A left join B on A.name=B.name where A.id is null or B.id is null;
+----+-----------+------+------+
| id | name      | id   | name |
+----+-----------+------+------+
|  2 | Monkey    | NULL | NULL |
|  4 | Spaghetti | NULL | NULL |
+----+-----------+------+------+
2 rows in set (0.00 sec)
</code></pre>

<p><img src="http://images.cnblogs.com/cnblogs_com/BeginMan/486940/o_sql4.png" alt="" /></p>

<p>同理，还可以模拟inner join. 如下：</p>

<pre><code>mysql&gt; select * from A left join B on A.name=B.name where A.id is not null and B.id is not null;
+----+--------+------+--------+
| id | name   | id   | name   |
+----+--------+------+--------+
|  1 | Pirate |    2 | Pirate |
|  3 | Ninja  |    4 | Ninja  |
+----+--------+------+--------+
2 rows in set (0.00 sec)
</code></pre>

<p><strong>求差集：</strong></p>

<p>根据上面的例子可以求差集，如下：</p>

<pre><code>SELECT * FROM A LEFT JOIN B ON A.name = B.name
WHERE B.id IS NULL
union
SELECT * FROM A right JOIN B ON A.name = B.name
WHERE A.id IS NULL;
# 结果
    +------+-----------+------+-------------+
| id   | name      | id   | name        |
+------+-----------+------+-------------+
|    2 | Monkey    | NULL | NULL        |
|    4 | Spaghetti | NULL | NULL        |
| NULL | NULL      |    1 | Rutabaga    |
| NULL | NULL      |    3 | Darth Vader |
+------+-----------+------+-------------+
</code></pre>

<p><img src="http://images.cnblogs.com/cnblogs_com/BeginMan/486940/o_sql5.png" alt="" /></p>

<h2>四.Right join</h2>

<pre><code>mysql&gt; select * from A right join B on A.name = B.name;
+------+--------+----+-------------+
| id   | name   | id | name        |
+------+--------+----+-------------+
| NULL | NULL   |  1 | Rutabaga    |
|    1 | Pirate |  2 | Pirate      |
| NULL | NULL   |  3 | Darth Vader |
|    3 | Ninja  |  4 | Ninja       |
+------+--------+----+-------------+
4 rows in set (0.00 sec)
</code></pre>

<p>同left join。</p>

<h2>五.Cross join</h2>

<p>cross join：交叉连接，得到的结果是两个表的乘积，即<a href="http://baike.baidu.com/view/348542.htm?fromtitle=%E7%AC%9B%E5%8D%A1%E5%B0%94%E7%A7%AF&amp;fromid=1434391&amp;type=syn">笛卡尔积</a></p>

<blockquote>
  <p>笛卡尔（Descartes）乘积又叫直积。假设集合A={a,b}，集合B={0,1,2}，则两个集合的笛卡尔积为{(a,0),(a,1),(a,2),(b,0),(b,1), (b,2)}。可以扩展到多个集合的情况。类似的例子有，如果A表示某学校学生的集合，B表示该学校所有课程的集合，则A与B的笛卡尔积表示所有可能的选课情况。</p>
</blockquote>

<pre><code>mysql&gt; select * from A cross join B;
+----+-----------+----+-------------+
| id | name      | id | name        |
+----+-----------+----+-------------+
|  1 | Pirate    |  1 | Rutabaga    |
|  2 | Monkey    |  1 | Rutabaga    |
|  3 | Ninja     |  1 | Rutabaga    |
|  4 | Spaghetti |  1 | Rutabaga    |
|  1 | Pirate    |  2 | Pirate      |
|  2 | Monkey    |  2 | Pirate      |
|  3 | Ninja     |  2 | Pirate      |
|  4 | Spaghetti |  2 | Pirate      |
|  1 | Pirate    |  3 | Darth Vader |
|  2 | Monkey    |  3 | Darth Vader |
|  3 | Ninja     |  3 | Darth Vader |
|  4 | Spaghetti |  3 | Darth Vader |
|  1 | Pirate    |  4 | Ninja       |
|  2 | Monkey    |  4 | Ninja       |
|  3 | Ninja     |  4 | Ninja       |
|  4 | Spaghetti |  4 | Ninja       |
+----+-----------+----+-------------+
16 rows in set (0.00 sec)

#再执行：mysql&gt; select * from A inner join B; 试一试

#在执行mysql&gt; select * from A cross join B on A.name = B.name; 试一试
</code></pre>

<p>实际上，<strong>在 MySQL 中（仅限于 MySQL） CROSS JOIN 与 INNER JOIN 的表现是一样的</strong>，在不指定 ON 条件得到的结果都是笛卡尔积，反之取得两个表完全匹配的结果。
INNER JOIN 与 CROSS JOIN 可以省略 INNER 或 CROSS 关键字，因此下面的 SQL 效果是一样的：</p>

<pre><code>... FROM table1 INNER JOIN table2
... FROM table1 CROSS JOIN table2
... FROM table1 JOIN table2
</code></pre>

<h2>六.Full join</h2>

<pre><code>mysql&gt; select * from A left join B on B.name = A.name 
    -&gt; union 
    -&gt; select * from A right join B on B.name = A.name;
+------+-----------+------+-------------+
| id   | name      | id   | name        |
+------+-----------+------+-------------+
|    1 | Pirate    |    2 | Pirate      |
|    2 | Monkey    | NULL | NULL        |
|    3 | Ninja     |    4 | Ninja       |
|    4 | Spaghetti | NULL | NULL        |
| NULL | NULL      |    1 | Rutabaga    |
| NULL | NULL      |    3 | Darth Vader |
+------+-----------+------+-------------+
6 rows in set (0.00 sec)
</code></pre>

<p>全连接产生的所有记录（双方匹配记录）在表A和表B。如果没有匹配,则对面将包含null。</p>

<p><img src="http://images.cnblogs.com/cnblogs_com/BeginMan/486940/o_sql2.png" alt="" /></p>

<h2>七.性能优化</h2>

<h3>1.显示(explicit)   inner join VS 隐式(implicit)    inner join</h3>

<p>如：</p>

<pre><code>select * from
table a inner join table b
on a.id = b.id;
</code></pre>

<p>VS</p>

<pre><code>select a.*, b.*
from table a, table b
where a.id = b.id;
</code></pre>

<p>我在数据库中比较(10w数据)得之，它们用时几乎相同，第一个是显示的inner join，后一个是隐式的inner join。</p>

<p><a href="http://stackoverflow.com/questions/44917/explicit-vs-implicit-sql-joins"><strong>参照:Explicit vs implicit SQL joins</strong></a></p>

<h3>2.left join/right join VS inner join</h3>

<p>尽量用inner join.避免 LEFT JOIN 和 NULL.</p>

<p>在使用left join（或right join）时，应该清楚的知道以下几点：</p>

<h4>(1). <code>on</code> 与 <code>where</code>的执行顺序</h4>

<blockquote>
  <p>ON 条件（“A LEFT JOIN B ON 条件表达式”中的ON）用来决定如何从 B 表中检索数据行。如果 B 表中没有任何一行数据匹配 ON 的条件,将会额外生成一行所有列为 NULL 的数据,<strong>在匹配阶段 WHERE 子句的条件都不会被使用。仅在匹配阶段完成以后，WHERE 子句条件才会被使用。它将从匹配阶段产生的数据中检索过滤。</strong></p>
</blockquote>

<p>所以我们要注意：<strong>在使用Left (right) join的时候，一定要在先给出尽可能多的匹配满足条件，减少Where的执行。</strong>如：</p>

<p>PASS</p>

<pre><code>select * from A
inner join B on B.name = A.name
left join C on C.name = B.name
left join D on D.id = C.id
where C.status&gt;1 and D.status=1;
</code></pre>

<p>Great</p>

<pre><code>select * from A
inner join B on B.name = A.name
left join C on C.name = B.name and C.status&gt;1
left join D on D.id = C.id and D.status=1
</code></pre>

<p>从上面例子可以看出，尽可能满足ON的条件，而少用Where的条件。从执行性能来看第二个显然更加省时。</p>

<h4>(2).注意ON 子句和 WHERE 子句的不同</h4>

<p>如作者举了一个列子：</p>

<pre><code>mysql&gt; SELECT * FROM product LEFT JOIN product_details
       ON (product.id = product_details.id)
       AND product_details.id=2;
+----+--------+------+--------+-------+
| id | amount | id   | weight | exist |
+----+--------+------+--------+-------+
|  1 |    100 | NULL |   NULL |  NULL |
|  2 |    200 |    2 |     22 |     0 |
|  3 |    300 | NULL |   NULL |  NULL |
|  4 |    400 | NULL |   NULL |  NULL |
+----+--------+------+--------+-------+
4 rows in set (0.00 sec)

mysql&gt; SELECT * FROM product LEFT JOIN product_details
       ON (product.id = product_details.id)
       WHERE product_details.id=2;
+----+--------+----+--------+-------+
| id | amount | id | weight | exist |
+----+--------+----+--------+-------+
|  2 |    200 |  2 |     22 |     0 |
+----+--------+----+--------+-------+
1 row in set (0.01 sec)
</code></pre>

<blockquote>
  <p>从上可知，第一条查询使用 ON 条件决定了从 LEFT JOIN的 product_details表中检索符合的所有数据行。第二条查询做了简单的LEFT JOIN，然后使用 WHERE 子句从 LEFT JOIN的数据中过滤掉不符合条件的数据行。</p>
</blockquote>

<h4>(3).尽量避免子查询，而用join</h4>

<p>往往性能这玩意儿，更多时候体现在数据量比较大的时候，此时，我们应该避免复杂的子查询。如下：</p>

<p>PASS</p>

<pre><code>insert into t1(a1) select b1 from t2 where not exists(select 1 from t1 where t1.id = t2.r_id); 
</code></pre>

<p>Great</p>

<pre><code>insert into t1(a1)  
select b1 from t2  
left join (select distinct t1.id from t1 ) t1 on t1.id = t2.r_id   
where t1.id is null;  
</code></pre>

<p>这个可以参考<a href="http://openxtiger.iteye.com/blog/1911228">mysql的exists与inner join 和 not exists与 left join 性能差别惊人</a></p>

<h3>补充：MySQL STRAIGHT_JOIN 与 NATURAL JOIN的使用</h3>

<p>长话短说：<code>straight_join</code> 实现强制多表的载入顺序，从左到右，如：</p>

<pre><code>...A straight_join B on A.name = B.name 
</code></pre>

<p><code>straight_join</code>完全等同于<code>inner join</code> 只不过，join语法是根据“哪个表的结果集小，就以哪个表为驱动表”来决定谁先载入的，而straight_join 会强制选择其左边的表先载入。</p>

<p>往往我们在分析mysql处理性能时，如(Explain),如果发现mysql在载入顺序不合理的情况下，可以使用这个语句，但往往mysql能够自动的分析并处理好。</p>

<p>更多内容参考：<a href="http://www.5idev.com/p-php_mysql_straight_join_natural_join.shtml">MySQL STRAIGHT_JOIN 与 NATURAL JOIN</a>
和<a href="http://huoding.com/2013/06/04/261">MySQL优化的奇技淫巧之STRAIGHT_JOIN</a></p>

<h2>八.参考：</h2>

<p><a href="http://blog.codinghorror.com/a-visual-explanation-of-sql-joins/"><strong>A Visual Explanation of SQL Joins</strong></a></p>

<p><a href="https://www.microsoft.com/china/MSDN/library/data/sqlserver/FiveWaystoRevupYourSQLPerformanCE.mspx?mfr=true"><strong>五种提高 SQL 性能的方法</strong></a></p>

<p><a href="http://www.oschina.net/question/89964_65912"><strong>关于 MySQL LEFT JOIN 你可能需要了解的三点</strong></a></p>
