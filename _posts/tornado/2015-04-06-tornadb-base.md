---
layout: post
title: "tornado ORM tornadb 源码分析"
category: "tornado"
tags: [tornado]
---

<p>tornado没有相应的ORM,基本通过tornadb模块，在旧版本原先是tornado.database.，它们都是轻量级的包装mysqldb.</p>

<p>在项目中由于tornado版本新旧的问题，我们可以友好的处理tornadb.</p>

<pre><code>try:
    import torndb as db
except:
    import tornado.database as db
</code></pre>

<p>关于tornadb的使用其实挺简单的，会用mysqldb就会用它。所以最好读一下tornadb的源码，仅仅两三百行。<a href="http://torndb.readthedocs.org/en/latest/_modules/torndb.html#Connection">Source code for torndb</a></p>

<!--more-->

<p><strong>连接mysql：</strong></p>

<pre><code>class torndb.Connection(
    host, 
    database, 
    user=None, 
    password=None, 
    max_idle_time=25200, //用来配置连接的最大空闲时间
connect_timeout=0,       // 连接超时时间
time_zone='+0:00',       // 设置时区init_command=('SET time_zone = "%s"' % time_zone)
charset='utf8',         
sql_mode='TRADITIONAL'  //通过设置sql_mode变量更改模式
)
</code></pre>

<p><code>max_idle_time</code>,配置连接的最大空闲时间，当超过该时间则重新连接。</p>

<pre><code>def _ensure_connected(self):
    """
    MySQL的默认情况下关闭客户端连接是闲置8小时后，但客户端库不报告这一事实直到尝试执行一个查询和失败。
    防止这种情况下，通过抢先关闭并重新打开连接如果它已经闲置太久（7小时默认情况下）。
    """
    if (self._db is None or
        (time.time() - self._last_use_time &gt; self.max_idle_time)):
        self.reconnect()
    self._last_use_time = time.time()
</code></pre>

<h2>一.常用方法</h2>

<h3>1.close()：关闭数据库连接</h3>

<pre><code>def close(self):
    """Closes this database connection."""
    if getattr(self, "_db", None) is not None:
        self._db.close()
        self._db = None
</code></pre>

<h3>2.reconnect():重新连接数据库</h3>

<pre><code>def reconnect(self):
    """Closes the existing database connection and re-opens it."""
    self.close()
    self._db = MySQLdb.connect(**self._db_args)
    self._db.autocommit(True)
</code></pre>

<h3>3.iter(query, *parameters, **kwparameters)：通过给定的查询和参数返回一个迭代器</h3>

<pre><code>def iter(self, query, *parameters, **kwparameters):
    self._ensure_connected()    #确保数据库处于连接状态

    #取大的结果集时一定使用SSCursor
    cursor = MySQLdb.cursors.SSCursor(self._db)
    try:
        self._execute(cursor, query, parameters, kwparameters)
        column_names = [d[0] for d in cursor.description]
        for row in cursor:
            yield Row(zip(column_names, row))  #yield返回生成器
    finally:
        cursor.close()
</code></pre>

<p>iter生成生成器函数，对于性能上肯定比下面的query好，这里使用了mysqldb的SSCurosr，当取大的结果集的时候，使用SSCurosr能避免客户端占用大量内存，使用迭代器而不用fetchall.</p>

<p>如下在mysqldb中体现：</p>

<pre><code>import MySQLdb
import MySQLdb.cursors

connection = MySQLdb.connect(
    host=host, port=port, user=username, passwd=password, db=database, 
    cursorclass=MySQLdb.cursors.SSCursor) # put the cursorclass here
cursor = connection.cursor()

cursor.execute(query)
for row in cursor:
    print(row)
</code></pre>

<p>这样执行execute就能生成iterator结果集</p>

<h3>4.query(query, *parameters, **kwparameters):通过给定查询和参数返回一列数据。</h3>

<pre><code>def query(self, query, *parameters, **kwparameters):
    cursor = self._cursor()
    try:
        self._execute(cursor, query, parameters, kwparameters)
        column_names = [d[0] for d in cursor.description]
        #与上面的iter()最大区别就是它返回所有数据
        return [Row(itertools.izip(column_names, row)) for row in cursor]
    finally:
        cursor.close()
</code></pre>

<h3>5.get(query, *parameters, **kwparameters)：返回单行数据</h3>

<p>如果没有数据则返回None.如果多行则触发异常。这点就像django ORM的 get和filter的区别一样。</p>

<pre><code>def get(self, query, *parameters, **kwparameters):
    rows = self.query(query, *parameters, **kwparameters)
    if not rows:
        return None
    elif len(rows) &gt; 1:
        raise Exception("Multiple rows returned for Database.get() query")
    else:
        return rows[0]
</code></pre>

<p>当然返回单行还是多行依赖于你的查询语句。</p>

<h3>6.execute(query, *parameters, **kwparameters)：执行查询语句并返回最后一条id</h3>

<pre><code>def execute(self, query, *parameters, **kwparameters):
    """Executes the given query, returning the lastrowid from the query."""
    #下面方法
    return self.execute_lastrowid(query, *parameters, **kwparameters)
</code></pre>

<h3>7.execute_lastrowid(query, *parameters, **kwparameters): 执行查询并返回最后一条的id</h3>

<pre><code>    def execute_lastrowid(self, query, *parameters, **kwparameters):
    """Executes the given query, returning the lastrowid from the query."""
    cursor = self._cursor()
    try:
        self._execute(cursor, query, parameters, kwparameters)
        return cursor.lastrowid
    finally:
        cursor.close()
</code></pre>

<h3>8.execute_rowcount(query, *parameters, **kwparameters):执行查询并返回最后影响的行数</h3>

<pre><code>def execute_rowcount(self, query, *parameters, **kwparameters):
    """Executes the given query, returning the rowcount from the query."""
    cursor = self._cursor()
    try:
        self._execute(cursor, query, parameters, kwparameters)
        return cursor.rowcount
    finally:
        cursor.close()
</code></pre>

<h3>9.executemany(query, parameters)：通过所有给定参数序列来执行查询</h3>

<pre><code>def executemany(self, query, parameters):
    """Executes the given query against all the given param sequences.

    We return the lastrowid from the query.
    """
    return self.executemany_lastrowid(query, parameters)
</code></pre>

<h3>10.executemany_lastrowid(query, parameters):同上</h3>

<pre><code>def executemany_lastrowid(self, query, parameters):
    """Executes the given query against all the given param sequences.

    We return the lastrowid from the query.
    """
    cursor = self._cursor()
    try:
        cursor.executemany(query, parameters)
        return cursor.lastrowid
    finally:
        cursor.close()
</code></pre>

<p>上述两个方法都是调用<code>cursor.executemany()</code>来进行批量插入数据。</p>

<pre><code>cursor.executemany(  
  """INSERT INTO breakfast (name, spam, eggs, sausage, price) 
  VALUES (%s, %s, %s, %s, %s)""",  
  [  
  ("Spam and Sausage Lover's Plate", 5, 1, 8, 7.95 ),  
  ("Not So Much Spam Plate", 3, 2, 0, 3.95 ),  
  ("Don't Wany ANY SPAM! Plate", 0, 4, 3, 5.95 )  
  ] )  
</code></pre>

<h3>11.executemany_rowcount(query, parameters)：同上并返回影响的行数。</h3>

<pre><code>.....
cursor.executemany(query, parameters)
return cursor.rowcount
</code></pre>

<h3>12.其他；</h3>

<pre><code>update = execute_rowcount            #update(query, *parameters, **kwparameters)
updatemany = executemany_rowcount    #updatemany(query,parameters)

insert = execute_lastrowid           # insert(query, *parameters, **kwparameters)
insertmany = executemany_lastrowid   # insertmany(query, parameters)
</code></pre>

<h2>二.class torndb.Row</h2>

<p>A dict that allows for object-like property access syntax,</p>

<pre><code>class Row(dict):
"""A dict that allows for object-like property access syntax."""
def __getattr__(self, name):
    try:
        return self[name]
    except KeyError:
        raise AttributeError(name)
</code></pre>
