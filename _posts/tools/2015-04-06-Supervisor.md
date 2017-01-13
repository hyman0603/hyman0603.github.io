---
layout: post
title: "Supervisor学习"
description: "Supervisor学习"
category: "linux"
tags: [linux服务器]
---
<h2>一.Supervisor安装配置</h2>

<h3>1.介绍</h3>

<p>在官网<a href="http://supervisord.org/">http://supervisord.org/</a>中介绍到：</p>

<blockquote>
  <p>Supervisor,是一个进程控制系统，是一个客户端/服务器端系统允许用户在UNIX-LIKE 操作系统中去监控，控制一些进程。Supervisor作为主进程，Supervisor下管理的时一些子进程，当某一个子进程异常退出时，Supervisor会立马对此做处理，通常会守护进程，重启该进程。</p>
</blockquote>

<p><a href="http://lixcto.blog.51cto.com/4834175/1539136"><strong>推荐阅读：supervisor(一)基础篇</strong></a></p>

<p>下面列举其主要的组件：</p>

<p><strong><code>supervisord</code></strong></p>

<p>是服务端程序，主要功能是启动supervisord服务，启动supervisor管理的子进程，对进程进行管理的服务。</p>

<p><strong><code>supervisorctl</code></strong></p>

<p>是客户端程序，主要功能就是管理(启动/关闭/重启/状态等)子进程,提供shell环境进行处理。</p>

<p><strong><code>web server</code></strong></p>

<p>Web Server主要可以在界面上管理进程，Web Server其实是通过XML_RPC来实现的，可以向supervisor请求数据，也可以控制supervisor及子进程。配置在[inet_http_server]块里面</p>

<p><strong><code>XML_RPC</code></strong></p>

<p>远程调用的，上面的supervisorctl和Web Server就它实现</p>

<!--more-->

<h3>2.安装</h3>

<pre><code># pip &gt;=1.4
pip install supervisor --pre   
# other
pip install supervisor
</code></pre>

<h3>3.创建配置文件</h3>

<p>通过<code>echo_supervisord_conf</code>命令来创建配置文件：</p>

<pre><code>echo_supervisord_conf &gt; /etc/supervisor.conf
</code></pre>

<h3>4.启动supervisor</h3>

<pre><code>supervisord -c /to/your/path/supervisord.conf
</code></pre>

<h3>5.配置文件详解</h3>

<p>生成  supervisord.conf 后要进行配置，那么首先要熟悉配置文件，下面参考http://lixcto.blog.51cto.com/4834175/1539136的总结：</p>

<pre><code>[unix_http_server]            
file=/tmp/supervisor.sock   ; socket文件的路径，supervisorctl用XML_RPC和supervisord通                                信就是通过它进行的。如果不设置的话，supervisorctl也就不能用了  
                          不设置的话，默认为none。 非必须设置        
;chmod=0700                 ; 这个简单，就是修改上面的那个socket文件的权限为0700
                          不设置的话，默认为0700。 非必须设置
;chown=nobody:nogroup       ; 这个一样，修改上面的那个socket文件的属组为user.group
                          不设置的话，默认为启动supervisord进程的用户及属组。非必须设置
;username=user              ; 使用supervisorctl连接的时候，认证的用户
                           不设置的话，默认为不需要用户。 非必须设置
;password=123               ; 和上面的用户名对应的密码，可以直接使用明码，也可以使用SHA加密
                          如：{SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d
                          默认不设置。。。非必须设置

;[inet_http_server]         ; 侦听在TCP上的socket，Web Server和远程的supervisorctl都要用到他
                          不设置的话，默认为不开启。非必须设置
;port=127.0.0.1:9001        ; 这个是侦听的IP和端口，侦听所有IP用 :9001或*:9001。
                          这个必须设置，只要上面的[inet_http_server]开启了，就必须设置它
;username=user              ; 这个和上面的uinx_http_server一个样。非必须设置
;password=123               ; 这个也一个样。非必须设置

[supervisord]                ;这个主要是定义supervisord这个服务端进程的一些参数的
                          这个必须设置，不设置，supervisor就不用干活了
logfile=/tmp/supervisord.log ; 这个是supervisord这个主进程的日志路径，注意和子进程的日志不搭嘎。
                           默认路径$CWD/supervisord.log，$CWD是当前目录。。非必须设置
logfile_maxbytes=50MB        ; 这个是上面那个日志文件的最大的大小，当超过50M的时候，会生成一个新的日 
                           志文件。当设置为0时，表示不限制文件大小
                           默认值是50M，非必须设置。              
logfile_backups=10           ; 日志文件保持的数量，上面的日志文件大于50M时，就会生成一个新文件。文件
                           数量大于10时，最初的老文件被新文件覆盖，文件数量将保持为10
                           当设置为0时，表示不限制文件的数量。
                           默认情况下为10。。。非必须设置
loglevel=info                ; 日志级别，有critical, error, warn, info, debug, trace, or blather等
                           默认为info。。。非必须设置项
pidfile=/tmp/supervisord.pid ; supervisord的pid文件路径。
                           默认为$CWD/supervisord.pid。。。非必须设置
nodaemon=false               ; 如果是true，supervisord进程将在前台运行
                           默认为false，也就是后台以守护进程运行。。。非必须设置
minfds=1024                  ; 这个是最少系统空闲的文件描述符，低于这个值supervisor将不会启动。
                           系统的文件描述符在这里设置cat /proc/sys/fs/file-max
                           默认情况下为1024。。。非必须设置
minprocs=200                 ; 最小可用的进程描述符，低于这个值supervisor也将不会正常启动。
                          ulimit  -u这个命令，可以查看linux下面用户的最大进程数
                          默认为200。。。非必须设置
;umask=022                   ; 进程创建文件的掩码
                           默认为022。。非必须设置项
;user=chrism                 ; 这个参数可以设置一个非root用户，当我们以root用户启动supervisord之后。
                           我这里面设置的这个用户，也可以对supervisord进行管理
                           默认情况是不设置。。。非必须设置项
;identifier=supervisor       ; 这个参数是supervisord的标识符，主要是给XML_RPC用的。当你有多个
                           supervisor的时候，而且想调用XML_RPC统一管理，就需要为每个
                           supervisor设置不同的标识符了
                           默认是supervisord。。。非必需设置
;directory=/tmp              ; 这个参数是当supervisord作为守护进程运行的时候，设置这个参数的话，启动
                           supervisord进程之前，会先切换到这个目录
                           默认不设置。。。非必须设置
;nocleanup=true              ; 这个参数当为false的时候，会在supervisord进程启动的时候，把以前子进程
                           产生的日志文件(路径为AUTO的情况下)清除掉。有时候咱们想要看历史日志，当 
                           然不想日志被清除了。所以可以设置为true
                           默认是false，有调试需求的同学可以设置为true。。。非必须设置
;childlogdir=/tmp            ; 当子进程日志路径为AUTO的时候，子进程日志文件的存放路径。
                           默认路径是这个东西，执行下面的这个命令看看就OK了，处理的东西就默认路径
                           python -c "import tempfile;print tempfile.gettempdir()"
                           非必须设置
;environment=KEY="value"     ; 这个是用来设置环境变量的，supervisord在linux中启动默认继承了linux的
                           环境变量，在这里可以设置supervisord进程特有的其他环境变量。
                           supervisord启动子进程时，子进程会拷贝父进程的内存空间内容。 所以设置的
                           这些环境变量也会被子进程继承。
                           小例子：environment=name="haha",age="hehe"
                           默认为不设置。。。非必须设置
;strip_ansi=false            ; 这个选项如果设置为true，会清除子进程日志中的所有ANSI 序列。什么是ANSI
                           序列呢？就是我们的\n,\t这些东西。
                           默认为false。。。非必须设置

; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]    ;这个选项是给XML_RPC用的，当然你如果想使用supervisord或者web server 这 
                          个选项必须要开启的
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface 

[supervisorctl]              ;这个主要是针对supervisorctl的一些配置  
serverurl=unix:///tmp/supervisor.sock ; 这个是supervisorctl本地连接supervisord的时候，本地UNIX socket
                                    路径，注意这个是和前面的[unix_http_server]对应的
                                    默认值就是unix:///tmp/supervisor.sock。。非必须设置
;serverurl=http://127.0.0.1:9001 ; 这个是supervisorctl远程连接supervisord的时候，用到的TCP socket路径
                               注意这个和前面的[inet_http_server]对应
                               默认就是http://127.0.0.1:9001。。。非必须项

;username=chris              ; 用户名
                           默认空。。非必须设置
;password=123                ; 密码
                          默认空。。非必须设置
;prompt=mysupervisor         ; 输入用户名密码时候的提示符
                           默认supervisor。。非必须设置
;history_file=~/.sc_history  ; 这个参数和shell中的history类似，我们可以用上下键来查找前面执行过的命令
                           默认是no file的。。所以我们想要有这种功能，必须指定一个文件。。。非
                           必须设置

; The below sample program section shows all possible program subsection values,
; create one or more 'real' program: sections to be able to control them under
; supervisor.

;[program:theprogramname]      ;这个就是咱们要管理的子进程了，":"后面的是名字，最好别乱写和实际进程
                            有点关联最好。这样的program我们可以设置一个或多个，一个program就是
                            要被管理的一个进程
;command=/bin/cat              ; 这个就是我们的要启动进程的命令路径了，可以带参数
                            例子：/home/test.py -a 'hehe'
                            有一点需要注意的是，我们的command只能是那种在终端运行的进程，不能是
                            守护进程。这个想想也知道了，比如说command=service httpd start。
                            httpd这个进程被linux的service管理了，我们的supervisor再去启动这个命令
                            这已经不是严格意义的子进程了。
                            这个是个必须设置的项
;process_name=%(program_name)s ; 这个是进程名，如果我们下面的numprocs参数为1的话，就不用管这个参数
                             了，它默认值%(program_name)s也就是上面的那个program冒号后面的名字，
                             但是如果numprocs为多个的话，那就不能这么干了。想想也知道，不可能每个
                             进程都用同一个进程名吧。


;numprocs=1                    ; 启动进程的数目。当不为1时，就是进程池的概念，注意process_name的设置
                             默认为1    。。非必须设置
;directory=/tmp                ; 进程运行前，会前切换到这个目录
                             默认不设置。。。非必须设置
;umask=022                     ; 进程掩码，默认none，非必须
;priority=999                  ; 子进程启动关闭优先级，优先级低的，最先启动，关闭的时候最后关闭
                             默认值为999 。。非必须设置
;autostart=true                ; 如果是true的话，子进程将在supervisord启动后被自动启动
                             默认就是true   。。非必须设置
;autorestart=unexpected        ; 这个是设置子进程挂掉后自动重启的情况，有三个选项，false,unexpected
                             和true。如果为false的时候，无论什么情况下，都不会被重新启动，
                             如果为unexpected，只有当进程的退出码不在下面的exitcodes里面定义的退 
                             出码的时候，才会被自动重启。当为true的时候，只要子进程挂掉，将会被无
                             条件的重启
;startsecs=1                   ; 这个选项是子进程启动多少秒之后，此时状态如果是running，则我们认为启
                             动成功了
                             默认值为1 。。非必须设置
;startretries=3                ; 当进程启动失败后，最大尝试启动的次数。。当超过3次后，supervisor将把
                             此进程的状态置为FAIL
                             默认值为3 。。非必须设置
;exitcodes=0,2                 ; 注意和上面的的autorestart=unexpected对应。。exitcodes里面的定义的
                             退出码是expected的。
;stopsignal=QUIT               ; 进程停止信号，可以为TERM, HUP, INT, QUIT, KILL, USR1, or USR2等信号
                              默认为TERM 。。当用设定的信号去干掉进程，退出码会被认为是expected
                              非必须设置
;stopwaitsecs=10               ; 这个是当我们向子进程发送stopsignal信号后，到系统返回信息
                             给supervisord，所等待的最大时间。 超过这个时间，supervisord会向该
                             子进程发送一个强制kill的信号。
                             默认为10秒。。非必须设置
;stopasgroup=false             ; 这个东西主要用于，supervisord管理的子进程，这个子进程本身还有
                             子进程。那么我们如果仅仅干掉supervisord的子进程的话，子进程的子进程
                             有可能会变成孤儿进程。所以咱们可以设置可个选项，把整个该子进程的
                             整个进程组都干掉。 设置为true的话，一般killasgroup也会被设置为true。
                             需要注意的是，该选项发送的是stop信号
                             默认为false。。非必须设置。。
;killasgroup=false             ; 这个和上面的stopasgroup类似，不过发送的是kill信号
;user=chrism                   ; 如果supervisord是root启动，我们在这里设置这个非root用户，可以用来
                             管理该program
                             默认不设置。。。非必须设置项
;redirect_stderr=true          ; 如果为true，则stderr的日志会被写入stdout日志文件中
                             默认为false，非必须设置
;stdout_logfile=/a/path        ; 子进程的stdout的日志路径，可以指定路径，AUTO，none等三个选项。
                             设置为none的话，将没有日志产生。设置为AUTO的话，将随机找一个地方
                             生成日志文件，而且当supervisord重新启动的时候，以前的日志文件会被
                             清空。当 redirect_stderr=true的时候，sterr也会写进这个日志文件
;stdout_logfile_maxbytes=1MB   ; 日志文件最大大小，和[supervisord]中定义的一样。默认为50
;stdout_logfile_backups=10     ; 和[supervisord]定义的一样。默认10
;stdout_capture_maxbytes=1MB   ; 这个东西是设定capture管道的大小，当值不为0的时候，子进程可以从stdout
                             发送信息，而supervisor可以根据信息，发送相应的event。
                             默认为0，为0的时候表达关闭管道。。。非必须项
;stdout_events_enabled=false   ; 当设置为ture的时候，当子进程由stdout向文件描述符中写日志的时候，将
                             触发supervisord发送PROCESS_LOG_STDOUT类型的event
                             默认为false。。。非必须设置
;stderr_logfile=/a/path        ; 这个东西是设置stderr写的日志路径，当redirect_stderr=true。这个就不用
                             设置了，设置了也是白搭。因为它会被写入stdout_logfile的同一个文件中
                             默认为AUTO，也就是随便找个地存，supervisord重启被清空。。非必须设置
;stderr_logfile_maxbytes=1MB   ; 这个出现好几次了，就不重复了
;stderr_logfile_backups=10     ; 这个也是
;stderr_capture_maxbytes=1MB   ; 这个一样，和stdout_capture一样。 默认为0，关闭状态
;stderr_events_enabled=false   ; 这个也是一样，默认为false
;environment=A="1",B="2"       ; 这个是该子进程的环境变量，和别的子进程是不共享的
;serverurl=AUTO                ; 

; The below sample eventlistener section shows all possible
; eventlistener subsection values, create one or more 'real'
; eventlistener: sections to be able to handle event notifications
; sent by supervisor.

;[eventlistener:theeventlistenername] ;这个东西其实和program的地位是一样的，也是suopervisor启动的子进
                                   程，不过它干的活是订阅supervisord发送的event。他的名字就叫
                                   listener了。我们可以在listener里面做一系列处理，比如报警等等
                                   楼主这两天干的活，就是弄的这玩意
;command=/bin/eventlistener    ; 这个和上面的program一样，表示listener的可执行文件的路径
;process_name=%(program_name)s ; 这个也一样，进程名，当下面的numprocs为多个的时候，才需要。否则默认就
                             OK了
;numprocs=1                    ; 相同的listener启动的个数
;events=EVENT                  ; event事件的类型，也就是说，只有写在这个地方的事件类型。才会被发送


;buffer_size=10                ; 这个是event队列缓存大小，单位不太清楚，楼主猜测应该是个吧。当buffer
                             超过10的时候，最旧的event将会被清除，并把新的event放进去。
                             默认值为10。。非必须选项
;directory=/tmp                ; 进程执行前，会切换到这个目录下执行
                             默认为不切换。。。非必须
;umask=022                     ; 淹没，默认为none，不说了
;priority=-1                   ; 启动优先级，默认-1，也不扯了
;autostart=true                ; 是否随supervisord启动一起启动，默认true
;autorestart=unexpected        ; 是否自动重启，和program一个样，分true,false,unexpected等，注意
                              unexpected和exitcodes的关系
;startsecs=1                   ; 也是一样，进程启动后跑了几秒钟，才被认定为成功启动，默认1
;startretries=3                ; 失败最大尝试次数，默认3
;exitcodes=0,2                 ; 期望或者说预料中的进程退出码，
;stopsignal=QUIT               ; 干掉进程的信号，默认为TERM，比如设置为QUIT，那么如果QUIT来干这个进程
                             那么会被认为是正常维护，退出码也被认为是expected中的
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
;killasgroup=false             ; SIGKILL the UNIX process group (def false)
;user=chrism                   ;设置普通用户，可以用来管理该listener进程。
                            默认为空。。非必须设置
;redirect_stderr=true          ; 为true的话，stderr的log会并入stdout的log里面
                            默认为false。。。非必须设置
;stdout_logfile=/a/path        ; 这个不说了，好几遍了
;stdout_logfile_maxbytes=1MB   ; 这个也是
;stdout_logfile_backups=10     ; 这个也是
;stdout_events_enabled=false   ; 这个其实是错的，listener是不能发送event
;stderr_logfile=/a/path        ; 这个也是
;stderr_logfile_maxbytes=1MB   ; 这个也是
;stderr_logfile_backups        ; 这个不说了
;stderr_events_enabled=false   ; 这个也是错的，listener不能发送event
;environment=A="1",B="2"       ; 这个是该子进程的环境变量
                             默认为空。。。非必须设置
;serverurl=AUTO                ; override serverurl computation (childutils)

; The below sample group section shows all possible group values,
; create one or more 'real' group: sections to create "heterogeneous"
; process groups.

;[group:thegroupname]  ;这个东西就是给programs分组，划分到组里面的program。我们就不用一个一个去操作了
                     我们可以对组名进行统一的操作。 注意：program被划分到组里面之后，就相当于原来
                     的配置从supervisor的配置文件里消失了。。。supervisor只会对组进行管理，而不再
                     会对组里面的单个program进行管理了
;programs=progname1,progname2  ; 组成员，用逗号分开
                             这个是个必须的设置项
;priority=999                  ; 优先级，相对于组和组之间说的
                             默认999。。非必须选项

; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

;[include]                         ;这个东西挺有用的，当我们要管理的进程很多的时候，写在一个文件里面
                                就有点大了。我们可以把配置信息写到多个文件中，然后include过来
;files = relative/directory/*.ini
</code></pre>

<h3>6.配置一个进程</h3>

<p>比如有一个python服务，如tornado，需要占用8112端口，那么我们在conf中配置就如下：</p>

<pre><code>;在末尾添加(;是注释的格式)
[program:myapp]
command=python /var/www/myapp/manage.py --port=8112   ;启动的命令
directory=/var/www                                    ;进程运行前，会前切换到这个目录默认不设置非必须设置
autorestart=true                                       ;自动重启
redirect_stderr=true                                  ;启用日志
stdout_logfile=/var/www/supervisor_log/log.txt        ;输出路径
stderr_logfile=/var/www/supervisor_log/err.txt        ;错误日志路径
stdout_logfile_maxbytes=1MB                           ;日志文件最大大小，和[supervisord]中定义的一样。默认为50
stdout_logfile_backups=10                             ;和[supervisord]定义的一样。默认10
</code></pre>

<p>配置完后要重新加载supervisord.conf, 如下命令：</p>

<pre><code>supervisorctl reload
</code></pre>

<p>如果出现如下异常：</p>

<p>error: <class 'socket.error'>, [Errno 111] Connection refused: file: /usr/lib64/python2.6/socket.py line: 567</p>

<p>解决办法如下：</p>

<pre><code>#先启动supervisor服务
sudo supervisord -c /path/to/your/supervisord.conf
sudo supervisorctl -c /path/to/your/supervisord.conf
</code></pre>

<p>然后：</p>

<pre><code>supervisorctl start myapp # 就启动了
</code></pre>

<p>接下来就是对Nginx进行配置了，新建配置文件：</p>

<pre><code>$ vim /etc/nginx/conf.d/tornado.conf
</code></pre>

<p>Nginx配置如下：</p>

<pre><code>upstream tornado {
server 127.0.0.1:8112;
</code></pre>

<p>}</p>

<pre><code>server {
    listen   80;
    location / {
        proxy_read_timeout 1800;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
        proxy_pass http://tornado;
    }
}       
</code></pre>

<p>然后重新加载Nginx:</p>

<pre><code>service nginx reload
</code></pre>

<h3>7.配置多个进程</h3>

<p>针对上述的配置，如果还想配置8110,8111,8112,8113端口总不可能每个都写一遍吧，那么这里就会有如下解决办法：</p>

<pre><code>[program:ycloud]
command=sudo python /var/www/myapp/manage.py --port=811(process_num)d
process_name=%(program_name)s-811%(process_num)d ; process_name expr (default %(program_name)s)
numprocs=4                    ; number of processes copies to start (def 1)
numprocs_start=1
</code></pre>

<p>1</p>

<p>或者可以这样写：</p>

<pre><code>[program:myapp]
command=python /var/www/res/manage.py --port=%(process_num)s
process_name=%(program_name)s_%(process_num)02d
directory=/var/www/res
numprocs_start=8110
autorestart=true
redirect_stderr=true
stdout_logfile=/var/www/supervisor_log/log.txt
</code></pre>

<p>同时Nginx配置如下：</p>

<pre><code>#user root;
worker_processes 4;

error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    worker_connections 65536;
    use epoll;
}

http {
# Enumerate all the Tornado servers here

upstream myapp {
    server 127.0.0.1:8110;
    server 127.0.0.1:8111;
    server 127.0.0.1:8112;
    server 127.0.0.1:8113;
}

include /etc/nginx/mime.types;
default_type application/octet-stream;

access_log /var/log/nginx/access.log;

keepalive_timeout 65;
proxy_read_timeout 200;
sendfile on;
#tcp_nopush on;
#tcp_nodelay on;
gzip on;
gzip_min_length 1000;
gzip_proxied any;
gzip_types text/plain text/html text/css text/xml text/json
           application/x-javascript application/xml
           application/atom+xml text/javascript;

# Only retry if there was a communication error, not a timeout
# on the Tornado server (to avoid propagating "queries of death"
# to all frontends)
proxy_next_upstream error;

server {
    listen 80;

    # Allow file uploads
    client_max_body_size 50M;

    location ^~ /static/ {
                        root /var/www/myapp;
                        if ($query_string) {
                            expires max;
                        }
                    }
    location = /favicon.ico {
        rewrite (.*) /static/favicon.ico;
    }
    location = /robots.txt {
        rewrite (.*) /static/robots.txt;
    }

    location / {
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
        proxy_pass http://myapp;
    }
}
</code></pre>

<p>注意如果出现：socket.error: [Errno 98] Address already in use 错误，那一定是你的tornado程序指定了固定的端口， 需改成如下：</p>

<pre><code>server.listen(options.port)
</code></pre>

<p>然后就可以了。</p>

<p><strong>Nginx启动后监听来自80端口的连接，然后分配这些请求到配置文件中列出的上游主机。</strong></p>

<p>反向代理接收所有传入的HTTP请求，然后把它们分配给独立的Tornado实例。</p>

<p><img src="http://mirrors.segmentfault.com/itt2zh/static/images/Figure8-1.jpg" alt="" /></p>

<h3>8.开启web Server</h3>

<p>需要配置inet_http_server：</p>

<pre><code>[inet_http_server]         ; inet (TCP) server disabled by default
port=9001        ; (ip_address:port specifier, *:port for all iface)
username=root              ; (default is no username (open server))
password=******               ; (default is no password (open server))

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket
;serverurl=http://0.0.0.0:9001 ; use an http:// url to specify an inet socket
username=root              ; should be same as http_username if set
password=*******                ; should be same as http_password if set
prompt=supervisor         ; cmd line prompt (default "supervisor")
</code></pre>

<p>重启服务后访问: http://106.186.126.128:9001/</p>

<p>就能看到这个页面：</p>

<p><img src="http://images.cnblogs.com/cnblogs_com/BeginMan/486940/o_QQ20141203-2.png" alt="" /></p>

<h2>二.常用命令</h2>

<p><code>supervisorctl update</code>:  添加新的配置文件后，执行该命令，会把新添加的服务启动起来，且不会影响正在运行的服务</p>

<p><code>supervisorctl start &lt;name&gt;</code>:启动进程 ：supervisorctl start all 表示启动所有</p>

<p><code>supervisorctl stop &lt;name&gt;</code>:  停止进程</p>

<p><code>supervisorctl restart &lt;name&gt;</code>: 重启进程</p>

<p><code>supervisorctl reload</code>: 重新载入会读取最新配置并重新启动所有进程。</p>

<p><code>supervisorctl status</code>:查看运行状态</p>
