---
layout: post
title: "Sentry实践"
category: "sentry"
tags: [sentry, python, 工具, 项目管理, 集成]
---

[Sentry](https://github.com/getsentry/sentry) 由python开发，django为框架的跨平台多语言/框架的日志聚合平台，功能十分强悍。截至目前最新版本是8.9

    $ python -c "import sentry; print(sentry.__version__)"
    8.9.0

下面以Centos6.5平台下分三部处理sentry:

1. 安装
2. 配置
3. 使用


# 一.安装

它依赖PostgreSQL数据库，首先要安装它。
    
    # 在系统中添加官网提供的对应版本的Yum仓库, 如下是9.6版本
    sudo yum install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm
    
    # 然后安装PostgreSQL数据库
    yum update      # 这一步可省略
    sudo yum install postgresql96-server postgresql96-contrib


接下来配置PostgreSQL依赖的环境，然后启动数据库

    sudo mkdir -p /data/pgsql                   # 数据库物理文件的存放目录
    sudo chown postgres:postgres /data/pgsql    # 所属组/成员
    sudo su - postgres                          
    cp /etc/skel/.bash* /var/lib/pgsql
    
编辑 `/var/lib/pgsql/.bashrc`文件，设置PGDATE环境变量并添加pgsql的bin路径到PATH变量。

    export PGDATA=/data/pgsql
    export PATH=/usr/pgsql-9.3/bin:$PATH
    
是环境生效：

    source .bashrc

然后初始化数据库并启动：

    $ [postgres@me ~]$ initdb  # 初始化
    $ [postgres@me ~]$ ls /data/pgsql/
    ..
    
    $ [postgres@me ~]$ pg_ctl start
    
查看 `tail /data/pgsql/pg_log/postgresql-*.log` 日志信息:

    tail /data/pgsql/pg_log/postgresql-*.log
    < 2016-11-04 11:45:02.490 CST > LOG:  database system was shut down at 2016-11-04 11:44:46 CST
    < 2016-11-04 11:45:02.502 CST > LOG:  MultiXact member wraparound protections are now enabled
    < 2016-11-04 11:45:02.504 CST > LOG:  autovacuum launcher started
    < 2016-11-04 11:45:02.504 CST > LOG:  database system is ready to accept connections
    
则表明启动成功。

那么接下来为Sentry提供PostgreSQL数据库信息：

```bash
[postgres@me ~]$ psql
psql (9.6.1)
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(3 rows)

postgres=# CREATE USER app WITH PASSWORD '*****';
CREATE ROLE
postgres=# CREATE DATABASE sentry OWNER app;
CREATE DATABASE
postgres=# GRANT ALL PRIVILEGES ON DATABASE sentry to app;
GRANT
postgres=# \q
[postgres@me ~]$ su - myapp
```

这些依赖安装和配置成功后就开始安装sentry。

    $ sudo pip install sentry
    ...
    Error: pg_config executable not found
    

结果报错了， pg_config executable not found, 在这里[pg_config executable not found](http://stackoverflow.com/questions/11618898/pg-config-executable-not-found)有解决方案，原因就是`pg_config`可执行文件不在`PATH`环境变量里， pg_config就是上面安装PostgreSQL的文件。

    $ which pg_config
    ... 没有
    
在`.bashrc`下添加PATH：

    export PATH=$PATH:/usr/pgsql-9.6/bin/
    
然后激活环境： `source ~/.bashrc`

接下来安装：

    yum install postgresql-devel
    sudo pip install psycopg2 sentry
    
    # 查看是否安装成功
    python -c "import sentry;print(sentry.__version__)"
    
# 二. 配置

首先初始化sentry生成配置文件：

    $ sentry init
    
在Home目录下生成.sentry目录：

    [team@me .sentry]$ tree
    .
    ├── config.yml
    └── sentry.conf.py

其中在sentry.conf.py下配置 PostgreSQL DATABASES 和 BROKER_URL：

```python
DATABASES = {
    'default': {
        'ENGINE': 'sentry.db.postgres',
        'NAME': 'sentry',
        'USER': 'app',
        'PASSWORD': '*****',
        'HOST': '',
        'PORT': '',
        'AUTOCOMMIT': True,
        'ATOMIC_REQUESTS': False,
    }
}

BROKER_URL = "redis://:password@localhost:6379/2"

```

config.yaml 文件配置如下：

```yaml
# While a lot of configuration in Sentry can be changed via the UI, for all
# new-style config (as of 8.0) you can also declare values here in this file
# to enforce defaults or to ensure they cannot be changed via the UI. For more
# information see the Sentry documentation.

###############
# Mail Server #
###############

mail.backend: 'django_smtp_ssl.SSLEmailBackend'  # Use dummy if you want to disable email entirely
mail.host: 'smtp.exmail.qq.com'
mail.port: 465
mail.username: 'support@xxx.cn'
mail.password: '****'
mail.use-tls: true
# The email address to send on behalf of
mail.from: 'support@***.cn'

# If you'd like to configure email replies, enable this.
# mail.enable-replies: false

# When email-replies are enabled, this value is used in the Reply-To header
# mail.reply-hostname: ''

# If you're using mailgun for inbound mail, set your API key and configure a
# route to forward to /api/hooks/mailgun/inbound/
# mail.mailgun-api-key: ''

###################
# System Settings #
###################

# If this file ever becomes compromised, it's important to regenerate your a new key
# Changing this value will result in all current sessions being invalidated.
# A new key can be generated with `$ sentry config generate-secret-key`
system.secret-key: '(80z$b)5u)oxq^kkzr^1r5%6^_4y3hrv0+!nlp!q1w+^fb#yux'

# The ``redis.clusters`` setting is used, unsurprisingly, to configure Redis
# clusters. These clusters can be then referred to by name when configuring
# backends such as the cache, digests, or TSDB backend.
redis.clusters:
  default:
    hosts:
      0:
        host: 127.0.0.1
        port: 6379
        password: '*****'

```

这里注意，因为邮件使用SSL, 则需要 SMTP SSL email backend for Django

    pip install django-smtp-ssl
    
然后配置 supervisor文件：

```
[program:sentry-web]
command=sentry run web
autostart=true
autorestart=true


[program:sentry-worker]
command=sentry run worker
autostart=true
autorestart=true

[program:sentry-cron]
command=sentry run cron
autostart=true
autorestart=true

```

生效并启动配置：

    supervisorctl -c /etc/supervisor.conf reread    # 读取配置
    supervisorctl -c /etc/supervisor.conf update    # 启动
    supervisorctl -c /etc/supervisor.conf status    # 查看
    
**这里总结下supervisord常见的问题和解决方案：**
    
    1. 当 supervisord 启动异常时，可 `supervisord -n` 前台启动查看详细信息
    2. 一般supervisor异常分两种，配置不对或权限的问题。
    3. 善用日志信息，首先要在supervisord.conf设置的日志下查看详情。

  
# 三.使用

Sentry支持的语言及框架十分丰富，如下：

![](http://beginman.qiniudn.com/2016-11-04-14782439291236.jpg)

对于Python，则需要安装raven库：

    pip install raven
    
下面是我常用的形式：

```python
import os
from functools import wraps
from raven import Client

SENTRY_DSN = {
    'dev': {
        'ievent': 'http://d3f90f044af043...2',
        'iteam': 'http://d3f90f044af043...3',
        'iuser': 'http://d3f90f044af043...4',
        'queue': 'http://d3f90f044af043...5',
        'default': 'https://bf29705094f63dabe63de@sentry.io/91886'
    },
    'pro': {
        'ievent': 'http://d3f90f044af043...2',
        'iteam': 'http://d3f90f044af043...3',
        'iuser': 'http://d3f90f044af043...4',
        'queue': 'http://d3f90f044af043...5',
        'default': 'https://bf29705094f63dabe63de@sentry.io/91886'    
    },
    'online': 'https://bf29705094f63dabe63de@sentry.io/918866'
}


def wrapper_log(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        try:
            return fn(*args, **kwargs)
        except Exception as ex:
            log()
        return None


def get_dsn(name):
    return SENTRY_DSN.get(os.getenv('SENTRY_ENV', 'dev'))\
            .get(name, 'default')


def get_client(name):
    try:
        return Client(get_dsn(name))
    except:
        # https://sentry.io/ 线上服务
        client = Client(dsn=SENTRY_DSN['online']) # noqa
        client.captureException()
        return client


def log(name='default'):
    client = get_client(name)
    if client:
        client.captureException()


def log_msg(msg, name='default'):
    if isinstance(msg, basestring):
        client = get_client(name)
        if client:
            client.captureMessage(msg)
```

我们可以尝试下，看是否捕获到日志：

```python
In [1]: from log import log_msg, log

In [2]: log_msg("Hello, world")

In [3]: try:
   ...:     1 / 0
   ...: except ZeroDivisionError as e:
   ...:     log('iuser')
   ...:

In [4]: No handlers could be found for logger "sentry.errors"
```
如下是启动后的图形界面：

![](http://beginman.qiniudn.com/2016-11-04-14782490063646.jpg)


![](http://beginman.qiniudn.com/2016-11-04-14782486012668.jpg)

同时接受邮件：

![](http://beginman.qiniudn.com/2016-11-04-14782491769686.jpg)


(完~)


