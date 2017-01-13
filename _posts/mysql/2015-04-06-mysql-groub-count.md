---
layout: post
title: "mysql groub count解决为0的情况"
description: "mysql groub count解决为0的情况"
category: "Mysql"
tags: [Mysql]
---

<p><img src="http://dev.mysql.com/common/logos/logo-mysql-110x57.png" alt="" /></p>

<p>mysql进行group by 并count操作时当没有数据则不显示,这里需要标明如果没有数据则标记为空,如下需求:</p>

<p>统计班级下学生数:</p>

<pre><code>    select mor.unit_class_id, suc.unit_name, count(mor.unit_class_id)as count from mobile_order_region mor
        inner join mobile_user_bind mub on mor.user_bind_id = mub.id
        inner join tbkt.school_unit_class suc on suc.id=mor.unit_class_id
        where mor.user_type = 1 and mor.unit_class_id in (411934,530256,530381,530382,529557) group by mor.unit_class_id
</code></pre>

<p>结果:</p>

<pre><code>+---------------+-----------+-------+
| unit_class_id | unit_name | count |
+---------------+-----------+-------+
|        411934 | 930班     |    21 |
|        530381 | 228班     |     1 |
+---------------+-----------+-------+
2 rows in set (0.01 sec)
</code></pre>

<p>共有5个班级,如上,则只有2个班级下有学生,其他班级信息则不显示,这里我需要显示.可以使用<strong>右链接+子查询</strong>,如下改进:</p>

<pre><code>select suc.id,suc.unit_name,IF(count IS NULL , 0, count) as count from
( 
    select mor.unit_class_id, suc.unit_name, count(mor.unit_class_id)as count from mobile_order_region mor
    inner join mobile_user_bind mub on mor.user_bind_id = mub.id
    inner join tbkt.school_unit_class suc on suc.id=mor.unit_class_id
    where mor.user_type = 1 and mor.unit_class_id in (411934,530256,530381,530382,529557) group by mor.unit_class_id
) t
RIGHT JOIN tbkt.school_unit_class suc on suc.id = t.unit_class_id where suc.id in (411934,530256,530381,530382,529557)
</code></pre>

<p>查询结果:</p>

<pre><code>+--------+-----------+-------+
| id     | unit_name | count |
+--------+-----------+-------+
| 411934 | 930班     |    21 |
| 529557 | 230班     |     0 |
| 530256 | 525班     |     0 |
| 530381 | 228班     |     1 |
| 530382 | 426班     |     0 |
+--------+-----------+-------+
5 rows in set (0.71 sec)
</code></pre>

<p>当然这样操作,查询速度成为了牺牲品.</p>
