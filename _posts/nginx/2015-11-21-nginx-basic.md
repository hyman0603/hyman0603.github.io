---
layout: post
title: "《深入理解Nginx》基础总结"
description: "《深入理解Nginx》基础总结"
category: "nginx"
tags: [nginx]
---

# 一.为什么选择nginx
- 更快，高扩展性
- 高可靠性，其架构设计比较牛B，常用模块也比较稳定，每个worker进程相对独立，master进程在1个worker进程出问题的时候迅速拉起一个新的worker子进程提供服务
- 低内存消耗，10 000个非活跃的HTTP Keep-Alive 连接只消耗2.5MB
- 单机支持10w以上并发连接，**并发连接的上限取决于内存**
- 热部署
- 自由的BSD许可协议

**Nginx 事件驱动设计，全异步的网络I/O处理机制，极少的进程间切换以及许多优化设计，使得Nginx善于处理高并发压力，同时更高效的使用服务器资源。**

# 二.nginx在linux下安装
在购置服务器后，最好做下优化安装，可参考[**最优最小化初始化生成环境CentOS 6.x脚本攻略
**](http://beginman.cn/ops/2015/11/20/init-centos/)

**(1).而安装nginx之前需要安装如下：**

	yum install -y gcc
	yum install -y gcc-c++
	yum install -y pcre pcre-devel
	yum install -y zlib zlib-devel
	yum install -y openssl openssl-devel

**(2)然后规划磁盘目录：**

- nginx 源码存放目录
- nginx 编译阶段产生的中间文件存放目录
- 部署目录，一般在/usr/local/nginx
- 日志文件目录，日志文件较大，应该放在更大磁盘里

**(3). 优化内核参数**

linux内核参数默认是最通用场景，并不符合高并发服务器，此时我们要修改/etc/sysctl.conf优化内核参数。如下：

fs.file_max = 999999

`file_max`：表示进程如一个worker进程可以同时打开的最大句柄数，这个参数直接限制最大并发连接数，需根据实际情况配置

net.ipv4.tcp_tw_resue = 1

`tcp_tw_resue`: 这个参数设置1表示允许TIME_WAIT状态的socket重新用于新的TCP连接，这对服务器来说很有意义，因为服务器总有大量的TIME_WAIT状态，如果一旦过多则影响服务器的性能

net.ipv4.tcp_keepalive_time = 600

`tcp_keepalive_time`: 当keepalive启用时TCP发送keepalive消息的频度，默认是2h，如果设置小一点可以更快清除无效的连接

net.ipv4.tcp_fin_timeout = 1

`tcp_fin_timeout`: 服务器主动关闭连接时，socket保持在FIN_WAIT_2状态的最大时间

全部如下：

	fs.file-max = 999999
	net.ipv4.ip_forward = 0
	net.ipv4.conf.default.rp_filter = 1
	net.ipv4.conf.default.accept_source_route = 0
	kernel.sysrq = 0
	kernel.core_uses_pid = 1
	net.ipv4.tcp_syncookies = 1
	kernel.msgmnb = 65536
	kernel.msgmax = 65536
	kernel.shmmax = 68719476736
	kernel.shmall = 4294967296
	net.ipv4.tcp_max_tw_buckets = 6000
	net.ipv4.tcp_sack = 1
	net.ipv4.tcp_window_scaling = 1
	net.ipv4.tcp_rmem = 4096 87380 4194304
	net.ipv4.tcp_wmem = 4096 16384 4194304
	net.core.wmem_default = 8388608
	net.core.rmem_default = 8388608
	net.core.rmem_max = 16777216
	net.core.wmem_max = 16777216
	net.core.netdev_max_backlog = 262144
	net.core.somaxconn = 262144
	net.ipv4.tcp_max_orphans = 3276800
	net.ipv4.tcp_max_syn_backlog = 262144
	net.ipv4.tcp_timestamps = 0
	net.ipv4.tcp_synack_retries = 1
	net.ipv4.tcp_syn_retries = 1
	net.ipv4.tcp_tw_recycle = 1
	net.ipv4.tcp_tw_reuse = 1
	net.ipv4.tcp_mem = 94500000 915000000 927000000
	net.ipv4.tcp_fin_timeout = 1
	net.ipv4.tcp_keepalive_time = 1200
	net.ipv4.ip_local_port_range = 1024 65535

**(4). 然后修改文件打开数：**

	echo "ulimit -SHn 102400" >> /etc/rc.local
	cat >> /etc/security/limits.conf << EOF
	*           soft   nofile       102400
	*           hard   nofile       102400
	*           soft   nproc        102400
	*           hard   nproc        102400
	EOF

**(5). 开始安装**

这个参考 [nginx服务器安装及配置文件详解](http://seanlook.com/2015/05/17/nginx-install-and-config/) 写的比较好

关于configure参数如下图：

[点击查看大图：http://beginman.qiniudn.com/nginx11.png](http://beginman.qiniudn.com/nginx11.png)

[点击查看大图：http://beginman.qiniudn.com/nginx22.png](http://beginman.qiniudn.com/nginx22.png)

[点击查看大图：http://beginman.qiniudn.com/nginx33.png](http://beginman.qiniudn.com/nginx33.png)

[点击查看大图：http://beginman.qiniudn.com/nginx44.png](http://beginman.qiniudn.com/nginx44.png)

[点击查看大图：http://beginman.qiniudn.com/nginx55.png](http://beginman.qiniudn.com/nginx55.png)

[点击查看大图：http://beginman.qiniudn.com/nginx66.png](http://beginman.qiniudn.com/nginx66.png)

[点击查看大图：http://beginman.qiniudn.com/nginx77.png](http://beginman.qiniudn.com/nginx77.png)

# 三.nginx命令控制

- `/usr/local/nginx/sbin/nginx`:  默认方式启动，会读取默认路径下的配置文件
- `/usr/local/nginx/sbin/nginx -c /path/to/conf`: 指定路径启动
- `/usr/local/nginx/sbin/nginx -p /usr/local/nginx/`: 指定安装目录启动
- `/usr/local/nginx/sbin/nginx -t`: 测试配置信息是否有误
- `/usr/local/nginx/sbin/nginx -v`:显示版本， `-V`则显示更多信息
- `/usr/local/nginx/sbin/nginx -s stop`: 快速强制停止
- `/usr/local/nginx/sbin/nginx -s quit`: 优雅地停止服务，也就是处理完所有连接后才终止
- `/usr/local/nginx/sbin/nginx -s reload`: 重读配置文件并生效
- `/usr/local/nginx/sbin/nginx -s reopen`: 重新打开日志文件，我们可以把日志文件更名或备份，不至于过大

# 四. nginx 进程
nginx需要一个master进程负责管理若干worker进程(worker进程数量应该与CPU核心数相等)

master进程不会处理请求，只负责管理提供真正服务的worker进程，它负责启动，停止，重载配置，平滑升级等任务。且权限比worker大。

worker进程提供真正的请求处理，并充分利用多核架构，从而在微观上实现多核并发处理。这里把worker进程设置与cpu核数一样的原因就是一个worker进程可以同时处理的请求数只受限于内存大小，不同的worker进程之间并发请求时几乎没有同步锁的限制，且通常不会进入休眠，进程间切换的代价也是最小的。

![](http://beginman.qiniudn.com/nginx_worker.png)

# 五. nginx语法

我所安装的是nginx/1.8.0, 安装后默认的nginx.conf如下：

	user  nginx;
	worker_processes  1;

	#error_log  logs/error.log;
	#error_log  logs/error.log  notice;
	#error_log  logs/error.log  info;

	#pid        logs/nginx.pid;


	events {
	    worker_connections  1024;
	}


	http {
	    include       mime.types;
	    default_type  application/octet-stream;

	    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
	    #                  '$status $body_bytes_sent "$http_referer" '
	    #                  '"$http_user_agent" "$http_x_forwarded_for"';

	    #access_log  logs/access.log  main;

	    sendfile        on;
	    #tcp_nopush     on;

	    #keepalive_timeout  0;
	    keepalive_timeout  65;

	    #gzip  on;

	    server {
	        listen       80;
	        server_name  localhost;

	        charset utf-8;

	        #access_log  logs/host.access.log  main;

	        location / {
	            root   html;
	            index  index.html index.htm;
	        }

	        #error_page  404              /404.html;

	        # redirect server error pages to the static page /50x.html
	        #
	        error_page   500 502 503 504  /50x.html;
	        location = /50x.html {
	            root   html;
	        }

	        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
	        #
	        #location ~ \.php$ {
	        #    proxy_pass   http://127.0.0.1;
	        #}

	        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	        #
	        #location ~ \.php$ {
	        #    root           html;
	        #    fastcgi_pass   127.0.0.1:9000;
	        #    fastcgi_index  index.php;
	        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
	        #    include        fastcgi_params;
	        #}

	        # deny access to .htaccess files, if Apache's document root
	        # concurs with nginx's one
	        #
	        #location ~ /\.ht {
	        #    deny  all;
	        #}
	    }


	    # another virtual host using mix of IP-, name-, and port-based configuration
	    #
	    #server {
	    #    listen       8000;
	    #    listen       somename:8080;
	    #    server_name  somename  alias  another.alias;

	    #    location / {
	    #        root   html;
	    #        index  index.html index.htm;
	    #    }
	    #}


	    # HTTPS server
	    #
	    #server {
	    #    listen       443 ssl;
	    #    server_name  localhost;

	    #    ssl_certificate      cert.pem;
	    #    ssl_certificate_key  cert.key;

	    #    ssl_session_cache    shared:SSL:1m;
	    #    ssl_session_timeout  5m;

	    #    ssl_ciphers  HIGH:!aNULL:!MD5;
	    #    ssl_prefer_server_ciphers  on;

	    #    location / {
	    #        root   html;
	    #        index  index.html index.htm;
	    #    }
	    #}

	}

对照这个配置文件来学习，分为：

- 块配置项
- 配置项语法格式
- 注释
- 单位
- 变量

## 5.1 块配置项
一个块配置名和一对花括号组成，如：

	events {....}

块配置项可以嵌套，内层块直接继承外层块。如果内外层配置冲突则具体视解析该配置项的模块决定。

## 5.2 配置项语法

	配置项名 配置项值1 配置项值2 ... ;

以空格间隔，以分号结尾

值可以是数字，字符串(或正则表达式)，**如果配置项值包含变量，空格则需要用单双引号**

## 5.3 注释

`#`号注释

## 5.4 单位

指定空间大小可以用:

- K或者k千字节(KiloByte, KB)
- M或者m兆字节(MegaByte, MB)

如：client_max_body 64M;

指定时间可以用：

ms(毫秒)，s,m,h,d,w(周),M(月),y(年)

如：expires	10d;

## 5.5 变量
变量名前面加`$`,并用单双引号括起来，如下常见的日志格式配置：

	access_log /mnt/logs/nginx/nginx-access.log;
    log_format new '$remote_addr^$http_x_forwarded_for^$host^$time_local^$status^'
			'$upstream_response_time^$request_time^$request_length^$bytes_sent^$http_referer^$request^$http_user_agent';


# 六. nginx服务的基本配置
就是针对加载的几个必须的模块配置分析，分为四类：

- 用于调试，定位问题的配置项
- 正常运行的必备配置项
- 优化性能的配置项
- 事件类配置项

好了，让我们实战吧！！

## 6.1 用于调试进程和定位问题的配置项

	error_log /path/file level;

错误日记是必须的，存放的磁盘必须大些，如果是`/dev/null`则关闭error日志， 如果是`stderr`日志会输出到标准错误文件中。

level级别：debug,info,notice,warn,error,crit,alert,emerg, 依次增大.

**如果level设置为debug, 必须在configure加入`--with-debug`配置项**

	debug_connection [IP|CIDR]

属于事件类配置，仅仅来自以上IP地址的请求才会输出到debug级别的日志，因此它必须放在events {..}, 如：

	events {
		debug_connection 115.183.147.186;		
		debug_connection 115.183.147.0/24;
	}

在我的机子上由于没有在configure加入`--with-debug`配置项有如下错误：

	nginx: [warn] "debug_connection" is ignored, you need to rebuild nginx using --with-debug option to enable it in /etc/nginx/nginx.conf:14

## 6.2 正常运行的配置项

	env VAR=VALUE

直接设置操作系统环境变量， 如：env TESTPATH=/tmp/;

	include /path/file

嵌入其他配置文件，可以是绝对路径，相对路径或文件名，通配符等，如：

	include mime.types;
	include /etc/nginx/conf.d/*.conf;

mime type 和 文件扩展名的对应关系一般放在 mime.types 里，然后 用 include       mime.types; 加载，mime.types 文件里其实就是用 types 指令来定义的，如：

application/javascript js;
application/json json;
text/css css;

我们还可以加载其他配置文件，如`include ...*.conf` 这是常用的。

	pid path/file;

用于保存master进程ID的pid文件存放路径。

	user username [groupname];

设置master进程启动后，fork出的worker进程运行在哪个用户和用户组下。在配置文件中如果指定了`--user=username`和`--group=groupname`则nginx配置文件中必须以此设定，如果没有该用户则`useradd username` 创建即可。

	worker_rlimit_nofile limit;

设置一个worker进程可以打开的最大文件句柄数， 常见错误Nginx: Too Many Open Files
其原因是Linux / Unix 设置了软硬文件句柄和打开文件的数目，解决方法是上面优化内核的一段shell脚本，同时修改nginx.conf：`worker_rlimit_nofile 30000;`,这样就可以解决Nginx连接过多的问题，Nginx就可以支持高并发。


## 6.3 性能优化的配置项

这里主要是worker进程的优化，如worker进程数与CPU核数的考量，这需要依据实际情况而定，**多进程有一个坏处就是带来了CPU上下文切换时间，所以一味提高进程个数反而使系统性能下降。当然如果当前进程小于CPU个数，就没有充分利用多核的资源，所以Nginx建议Worker数应该等于CPU个数。但是如果进程有阻塞呢？这时是应该提高进程数增加并行数的，如果Nginx主要负责静态内容的下载，而服务器内存比较小，大部分文件访问都需要读磁盘，这时候进程很容易阻塞，所以建议提高下Worker数目。**

如我们的是Http服务器，我的cpu核数4，则设置:

	worker_processes 4;

**一般情况下除了确保进程数等于CPU数，我们还可以绑定进程与CPU，这就保证了最少的CPU上下文切换。**,如下：

	worker_processes 4;
	worker_cpu_affinity 1000 0100 0010 0001;

## 6.4 事件类配置项

	use [kqueue|rtsig|epoll|select|poll...]

选择事件模型，我们当然选择最彪悍的epoll了。

	worker_connections number;

定义每个worker进程可以同时处理的最大连接数，nginx中worker_connections值设置是1024，worker_processes 值设置是4，按反向代理模式下最大连接数的理论计算公式：

	   最大连接数 = worker_processes * worker_connections/4

nginx理论上只支持1024个。高并发情况下活动连接数经常是大于1024，因而有时会导致连接数不够，直到NGINX无法再处理新的连接请求。生产环境中worker_connections 建议值最好超过9000，可设置为10240。

我们可以参考这篇文章：[**关于nginx的一些优化(突破十万并发)**](http://www.360doc.com/content/10/0106/11/11991_12790368.shtml)

	events {
	        worker_connections 65530;               #单个进程最大连接数（最大连接数=连接数*进程数）
	        use epoll;                                              #参考事件模型
	}

# 七. 用于HTTP核心模块配置一个静态Web服务器
web服务器主要功能由`ngx_http_core_module`模块实现，这里通过以下8类总结：

- 虚拟主机与请求分发
- 文件路径定义
- 内存以及磁盘资源的分配
- 网络连接的设置
- MIME类型设置
- 对客户端请求的限制
- 文件操作的优化
- 对客户端请求的特殊处理

# 7.1 虚拟主机与请求分发
### 1. listen 监听端口
关于listen 可参考官方文档：[listen](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen)

listen指令告诉nginx在一个特定的hostname，ip或者tcp端口监听连接。默认，http服务运行在80端口。

### 2. server_name 主机名称
因为IP数量有限，所以就存在多个主机域名对应一个IP，如下域名解析：

![](http://beginman.qiniudn.com/nignxtest1.png)

这时候就要使用`server_name`通过server块来定义虚拟主机了，默认情况下无论是请求play.beginman.cn还是love.beginman.cn都会进入默认的server块，因为在nginx中默认如下：

	server {
		listen 80 default_server;
		server_name localhost;
		...
	}

所以上述两个请求都会落在它上面，server_name指令主要用于配置基于名称的虚拟主机，在开始处理一个HTTP请求时，Nginx会取出header头中的Host,与每一个server中的server_name进行匹配，以此决定到底由哪个server块处理这个请求。

针对刚才的情景，每个域名要对应一个server，那么可以这样：

	server{
		listen 80;
		server_name play.beginman.cn;
		index play.html;
		root /tmp/wwwsite/$2;
		location / {
			index play.html;
			}
		}

	server{
		listen 80;
		server_name love.beginman.cn;
		index love.html;
		root /tmp/wwwsite/$2;
		location / {
			index love.html;
			}
	}


如果你请求了 [http://play.beginman.cn/](http://play.beginman.cn/) 你会发现出来一个神奇的Js特效，如果你请求了[http://love.beginman.cn/](http://love.beginman.cn/) 那么你会发现了我的表白~

注意server_name与Host的匹配优先级如下：

1. 首先选择完全匹配的server_name, 如：www.beginman.cn;
2. 其次选择通配符在前面的server_name,如：`*`.beginman.cn;
3. 再次选择通配符在后面的server_name,如：www.beginman.`*`;
4. 最后选择使用正则表达式的server_name,如：`~^\.beginman\.com$`

如果Host与所有的server_name都不匹配，则此时会按照如下顺序选择处理的server块：

1. 优先选择在listen配置项后加入`[default|default_server]`的server快
2. 找到匹配的listen端口的第一个server块;

server_name指令一项很实用的功能便是可以在使用正则表达式的捕获功能，这样可以尽量精简配置文件，毕竟太长的配置文件日常维护也很不方便。下面是2个具体的应用：

**1、在一个server块中配置多个站点：**

	server
	   {
	     listen       80;
	     server_name  ~^(www\.)?(.+)$;
	     index index.php index.html;
	     root  /data/wwwsite/$2;
	   }


站点的主目录应该类似于这样的结构：

	/data/wwwsite/domain.com
	/data/wwwsite/nginx.org
	/data/wwwsite/baidu.com
	/data/wwwsite/google.com

同时注意设置好权限，最好目录设置755，文件设置644.否则会出现403 Forbidden,如下查看error.log

	tail -n 10 /var/log/nginx/error.log

	2015/11/22 23:06:26 [error] 28052#0: *134 directory index of "/tmp/wwwsite/love.beginman.cn/" is forbidden, client: 115.183.147.186, server: ~^(www\.)?(.+)$, request: "GET / HTTP/1.1", host: "love.beginman.cn"
	
这样就可以只使用一个server块来完成多个站点的配置。


**2、在一个server块中为一个站点配置多个二级域名。**

实际网站目录结构中我们通常会为站点的二级域名独立创建一个目录，同样我们可以使用正则的捕获来实现在一个server块中配置多个二级域名：

	server
	   {
	     listen       80;
	     server_name  ~^(.+)?\.domain\.com$;
	     index index.html;
	     if ($host = domain.com){
	         rewrite ^ http://www.domain.com permanent;
	     }
	     root  /data/wwwsite/domain.com/$1/;
	   }

站点的目录结构应该如下：

	/data/wwwsite/domain.com/www/
	/data/wwwsite/domain
	.com/nginx/

这样访问www.domain.com时root目录为/data/wwwsite/domain.com/www/，nginx.domain.com时为/data/wwwsite/domain.com/nginx/，以此类推。

后面if语句的作用是将domain.com的方位重定向到www.domain.com，这样既解决了网站的主目录访问，又可以增加seo中对www.domain.com的域名权重。

ok，那么上面第一个例子，我们就可以改写成 2、在一个server块中为一个站点配置多个二级域名。如下配置：

	server{
		listen 80;
		server_name ~^(.+)?\.beginman\.cn$;
		index index.html;
		root /tmp/wwwsite/beginman.cn/$1/;
	}

那么我们的目录结构如下：

	wwwsite/
	└── beginman.cn
	    ├── love
	    │   └── index.html
	    └── play
	        ├── follow.js
	        └── index.html

### 3. location
用于匹配url,并选择location块中的配置去处理用户的请求：

	location=[=|~|~*\^~|@] /uri/ {...}

如下匹配规则：

1).`=`完全匹配， 如：

	location = / {
		# 只有当请求是/时，才会使用该location下的配置
	}

2). `~`表示匹配URI时是字母大小写敏感

3). `~*`表示匹配URI时忽略字母大小写问题

4). `^~`以某某开头, 如：

	location ^~ /images/ {
		# 以 /images/ 开始的请求都会匹配上
	}

5). `@`表示用于nginx服务内部请求之间重定向， 我也没用过..

还可以匹配正则：

	location ~* \.(gif|jpg|jpeg)$ {
		# 匹配以.git,.jpg,.jpeg结尾的请求
	}

**注意：如果有多个匹配则以第一个为主。**， 如果**通配**,则可以如下：

	location / {
		# / 可以匹配所有请求
	}


推荐看下这篇文章：[**Nginx 配置 Location 指令块**](http://blog.mimvp.com/2015/02/configure-nginx-location-directives/)

## 7.2 文件路径的定义
### 1.以root方式设置资源路径

	语法：root path;
	默认：root html;
	配置块：http、server、location、if

**注意：定义资源文件相对于HTTP请求的根目录**， 如：输入：http://play.beginman.cn/download/ 或 http://play.beginman.cn/download 来显示内容：

	server{
		listen 80;
		server_name ~^(.+)?\.beginman\.cn$;
		index index.html;
		root /tmp/wwwsite/beginman.cn/$1/;
		location /download {
			root /var/www/;
		}
	}

**注意，在使用文件路径定义的时候一定要注意文件目录权限, 可能会出现403 forbidden (13: Permission denied)**， 那么可以参考这篇文章：[Nginx报错403 forbidden (13: Permission denied)的解决办法](http://www.hi-docs.com/article/detail-MTE1.html). 

	mkdir -p /var/www
	# 修改web目录的读写权限
	chmod -R 775 /var/www

### 2. 以alias方式设置资源路径

语法： alias path;

如下例子，URI请求为/conf/nginx.conf：
	
	# alias
	location /conf {
		alias /etc/nginx/conf/;
	}

	#root
	location /conf {
		root /etc/nginx/;
	}

解释：

- alias: 将location后配置的/conf这部分字符串丢弃掉，/conf/nginx.conf请求将会根据alias path映射成：path/nginx.conf
- root: 根据完整的URL请求来映射，因此，/conf/nginx.conf请求会根据root path 映射为 path/conf/nginx.conf
- root能够在http,server,location和if块中使用，但是alias只能在location块中使用

alias后面还可以添加正则表达式，如：

	location ~^/test/(\w+)\.(\w+)$ {
		alias /etc/nginx/$2/$1.$2;
	}

当访问/test/nginx.conf时，会匹配 /etc/nginx/conf/nginx.conf

### 3.index访问首页

	语法： index file ...;
	默认：index index.html;
	配置块：http,server,location

这个比较简单。 比如访问`/`一般是首页

### 4.根据HTTP返回码重定向页面

	语法： error_page code [code ..][=|=answer-code] uri | @named_location
	配置块：http,server,location,if

常用的配置，比如重定向404，500等处理：

		#error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

比如你访问：[http://play.beginman.cn/](http://play.beginman.cn/)则正常，如果你访问 [http://play.beginman.cn/ssss](http://play.beginman.cn/ssss) 则就会404 然后你就能看到我所配置的页面。

为了全局性处理错误码，我放在http块中，如下：

	http {
        error_page 404 http://beginman.qiniudn.com/beginman_404.JPG;
        error_page 502 503 504 505 http://beginman.qiniudn.com/beginman_500.JPG;
        # .....
    }

还有一些注意的是：

- 虽然重定向了URI,但是返回HTTP错误码还是与原来相同，通过`=answer-code`更改返回的错误码，如: `error-page 404 =200 /404.gif`, 如果不确切指定错误码则`=`即可，由重定向后实际处理的真实结果来处理
- 请求重定向到location中处理，如：

	location / {
		error-page 404 @fallback;
	}

	location @fallback{
		proxy_pass http://backend;
	}

## 7.3 内存及磁盘资源分配
### 1. http包体尽量写入内存buffer中

	语法：client_body_in_single_buffer on|off;
	默认：off;
	配置块：http,server, location

用户请求的http包体写入内存buffer中，如果http 包体请求超过client_body_buffer_size的值，则还会写入到磁盘中。

### 2.存储HTTP头部的内存buffer大小

	语法：client_header_buffer_size size;
	默认 1k
	配置块: http, server

设置http header大小，如果超过则会使用 http_large_client_header_buffer。

### 3.存储超大HTTP头部的内存buffer大小

	语法：http_large_client_header_buffer number(个数) size(大小);
	默认：4 8k;
	配置块: http, server

![](http://beginman.qiniudn.com/nginx_learn_basic1.png)

![](http://beginman.qiniudn.com/nginx_learn_basic2.png)

## 7.4 网络连接的设置
### 1.读取HTTP头部的超时时间

	语法：client_header_timeout time(单位秒)
	默认：60
	配置块：http,server,location

在该时间内，如果server还没有收到client发来的http头部字节，则认为超时，并向client返回408(Request timed out)响应

### 2.读取HTTP包体的超时时间

	语法：client_body_timeout time
	默认：60
	配置块：http,server,location

同上，只不过是读取body.

### 3. 发送响应的超时时间

	语法：send_timeout time;
	默认：60
	配置块：http,server,location

Nginx向客户端发送数据包，但客户端一直没有去接收这个数据包，如果超过这个时间则Nginx将会关闭这个连接

### 4. reset_timeout_connection

	语法：reset_timeout_connection on|off
	默认：off;
	配置块：同上

**这个选项打开后，Nginx会在某个连接超时后不使用正常的四次挥手关闭TCP连接，而是直接向客户端发送RST重置包，不再等待用户的应答，直接释放nginx服务器上关于这个套接字使用的所有缓存，相比正常的关闭方式，它使得服务器避免产生许多的FIN_WAIT_1, FIN_WAIT_2, TIME_WAIT状态。**

### 5. keepalive超时时间

	语法：keepalive_timeout time;
	默认:75
	配置块：同上

当一个keepalive连接在闲置超过一定时间(默认75s)后nginx服务器和浏览器去关闭这个连接，每个浏览器对此有不同的逻辑

### 6.一个keepalive长连接上允许承载的请求最大数

	keepalive_requests n;
	默认:100

一个keepalive连接上默认最多只能发送100个请求

## 7.5 MIME类型的设置
主要是MIME type与文件扩展的映射，如：

	type {
		text/html 	html;
		text/gif 	gif;
	}

## 7.6 对客户端请求的限制
### 1.按HTTP方法名限制用户请求

	语法：limit_execpt method ... {..}
	配置块：location

这个用来限制用户的请求，注意get与head方法一致

### 2.HTTP请求包体的最大值

	语法：client_max_body_size size;
	默认：1m;
	配置块：http,server,location

**这个比较重要**，用来限制Content-Length字段所表示的大小，此时就不用等Nginx接受完所有的HTTP包体，而是直接通过发现Content-Length要是大于我们设置的最大包体值，则立马返回413(Request Entity Large)给客户端。

还有一些个人觉得不太常用或者等用到了再好好补充。

# 八.ngx_http_core_module模块提供的变量

![](http://beginman.qiniudn.com/nginx_learn_basic3.png)

![](http://beginman.qiniudn.com/nginx_learn_basic4.png)

# 九，Nginx反向代理

以图说话：

![](http://beginman.qiniudn.com/nginxlearnbasic1.png)

[点击查看大图](http://beginman.qiniudn.com/nginxlearnbasic1.png)

Nginx这种工作方式的优缺点：

- 缺点1:延长了一个请求的处理时间，因为当客户端发来http请求时，nginx并不会立即转发到上游服务器，而是把请求(包括HTTP包体)完整的接收到Nginx服务器的硬盘或内存中，然后再向上游服务器发起连接，把缓存的客户端请求转发给上游服务器，这相当于nginx来一个吃一个，吃一大堆东西放在胃里，然后等你的消化系统(上游服务器)来处理。
- 缺点2：请求会占用内存和磁盘空间（如上）
- 优点：降低了上游服务器的负载，直接把压力放在nginx上。

所谓负载均衡就是尽量把请求平均的分布到每台上游服务器上。关于此《深入理解Nginx》一书很详尽了，不再抄人家的书了。。 或者看下：[**负载均衡模块**](http://wiki.jikexueyuan.com/project/nginx/load-balancing-module.html)，突然发现[**Nginx 入门指南**](http://wiki.jikexueyuan.com/project/nginx/)其实写的也挺好呢。

关于《深入理解Nginx》基础篇已经学习了，暂时告一段落，在以后的工作中再慢慢总结吧~






