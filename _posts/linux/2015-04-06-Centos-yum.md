---
layout: post
title: "Centos yum详解"
description: "Centos yum详解"
category: "linux"
tags: [linux基础]
---

<p>yum,[jʌm]（全称为 Yellow dog Updater, Modified）是一个在Fedora和RedHat以及CentOS中的<strong>Shell前端软件包管理器</strong>。基于RPM包管理，能够从指定的服务器自动下载RPM包并且安装，可以自动处理依赖性关系，并且一次安装所有依赖的软件包，无须繁琐地一次次下载、安装。</p>

<!--more-->

<h2>yum的配置</h2>

<p>yum配置分两部分，main和repository.</p>

<ul>
<li>main 部分定义了全局配置选项，整个yum 配置文件应该只有一个main。常位于/etc/yum.conf 中。</li>
<li>repository 部分定义了每个源/服务器的具体配置，可以有一到多个。常位于/etc/yum.repo.d 目录下的各文件中。</li>
</ul>

<p>关于repo 文件的格式</p>

<p>所有repository 服务器设置都应该遵循如下格式：</p>

<pre><code>[serverid]
name=Some name for this server
baseurl=url://path/to/repository/
</code></pre>

<p><strong>serverid</strong> 是用于区别各个不同的repository，必须有一个独一无二的名称；</p>

<p><strong>name</strong> 是对repository 的描述，支持像<code>$releasever</code>, <code>$basearch</code>这样的变量；</p>

<p><strong>baseurl</strong> 是服务器设置中最重要的部分，只有设置正确，才能从上面获取软件。它的格式是：</p>

<pre><code>baseurl=url://server1/path/to/repository/
        url://server2/path/to/repository/
        url://server3/path/to/repository/
</code></pre>

<p>其中url 支持的协议有 http:// ftp:// file:// 三种。baseurl 后可以跟多个url，你可以自己改为速度比较快的镜像站，<strong>但baseurl 只能有一个</strong>，也就是说不能像如下格式：</p>

<pre><code>#多个baseurl则错误
baseurl=url://server1/path/to/repository/
baseurl=url://server2/path/to/repository/
baseurl=url://server3/path/to/repository/
</code></pre>

<p>其中url 指向的目录必须是这个repository header 目录的上一级，它也支持<code>$releasever</code>, <code>$basearch</code> 这样的变量。
url 之后可以加上多个选项，如gpgcheck、exclude、failovermethod 等</p>

<p><strong>关于变量</strong></p>

<ol>
<li><p>$releasever：代表发行版的版本，从[main]部分的distroverpkg获取，如果没有，则根据redhat-release包进行判断。</p></li>
<li><p>$arch：cpu体系，如i686,athlon等</p></li>
<li><p>$basearch：cpu的基本体系组，如i686和athlon同属i386，alpha和alphaev6同属alpha。</p></li>
</ol>

<p>如在yum加入nginx源，To add nginx yum repository, create a file named <code>/etc/yum.repos.d/nginx.repo</code> and paste one of the configurations below:</p>

<pre><code>[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
</code></pre>

<p>then:</p>

<pre><code>yum install nginx  
</code></pre>

<p>或者将上面的代码写入yum.conf中也行。</p>

<h2>配置yum源</h2>

<p>在/etc/yum.repos.d中包含各种源的配置文件，如上我们创建了一个nginx源配置文件。</p>

<p><strong>CentOS-Base.repo 是yum 网络源的配置文件；CentOS-Media.repo 是yum 本地源的配置文件</strong></p>

<p>步骤：</p>

<ol>
<li>下载repo</li>
<li>替换本地源，将CentOS-Base.repo替换成你下载的repo</li>
<li>更新 cache</li>
<li>验证</li>
</ol>

<p>如配置网易yum源：</p>

<pre><code>#下载 repo
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo

#替换 repo
cd /etc/yum.repos.d/
mv CentOS-Base.repo CentOS-Base.repo.bak    #备份
mv CentOS6-Base-163.repo CentOS-Base.repo

#更新 cache
yum clean all
yum makecache

#验证
yum repolist
</code></pre>

<h2>使用</h2>

<p>1.系统更新(更新所有可以升级的rpm包,包括kernel)</p>

<pre><code>yum -y update
</code></pre>

<p>2.每天定期执行系统更新</p>

<pre><code>chkconfig yum on
service yum start
</code></pre>

<p>3.rpm包的更新，检查可更新的rpm包</p>

<pre><code>yum check-update
</code></pre>

<p>4.更新所有的rpm包</p>

<pre><code>yum update
</code></pre>

<p>5.更新指定的rpm包,如更新kernel和kernel source</p>

<pre><code>yum update kernel kernel-source
</code></pre>

<p>6.大规模的版本升级,与yum update不同的是,连旧的淘汰的包也升级</p>

<pre><code>yum upgrade
</code></pre>

<p>7.删除rpm包,包括与该包有倚赖性的包</p>

<pre><code>yum remove licq
注:同时会提示删除licq-gnome,licq-qt,licq-text
</code></pre>

<p>8.yum暂存(/var/cache/yum/)的相关参数</p>

<pre><code>清除暂存中rpm包文件
yum clean packages
</code></pre>

<p>9.清除暂存中rpm头文件</p>

<pre><code>yum clean headers
</code></pre>

<p>10.清除暂存中旧的rpm头文件</p>

<pre><code>yum clean oldheaders
</code></pre>

<p>11.清除暂存中旧的rpm头文件和包文件</p>

<pre><code>yum clean 或#yum clean all
注:相当于yum clean packages + yum clean oldheaders
</code></pre>

<p>12.rpm包列表</p>

<pre><code>列出资源库中所有可以安装或更新的rpm包
yum list
</code></pre>

<p>13.列出资源库中特定的可以安装或更新以及已经安装的rpm包</p>

<pre><code>yum list mozilla
yum list mozilla*
注:可以在rpm包名中使用匹配符,如列出所有以mozilla开头的rpm包
</code></pre>

<p>14.列出资源库中所有可以更新的rpm包</p>

<pre><code>yum list updates
</code></pre>

<p>15.列出已经安装的所有的rpm包</p>

<pre><code>yum list installed
</code></pre>

<p>16.列出已经安装的但是不包含在资源库中的rpm包</p>

<pre><code>yum list extras
注:通过其它网站下载安装的rpm包，*rpm包信息显示(info参数同list)
</code></pre>

<p>17.列出资源库中所有可以安装或更新的rpm包的信息</p>

<pre><code>yum info
</code></pre>

<p>18.列出资源库中特定的可以安装或更新以及已经安装的rpm包的信息</p>

<pre><code>yum info mozilla
yum info mozilla*
注:可以在rpm包名中使用匹配符,如列出所有以mozilla开头的rpm包的信息
</code></pre>

<p>19.列出资源库中所有可以更新的rpm包的信息</p>

<pre><code>yum info updates
</code></pre>

<p>20.列出已经安装的所有的rpm包的信息</p>

<pre><code>yum info installed
</code></pre>

<p>21.列出已经安装的但是不包含在资源库中的rpm包的信息</p>

<pre><code>yum info extras
注:通过其它网站下载安装的rpm包的信息
</code></pre>

<p>22.搜索rpm包</p>

<pre><code>搜索匹配特定字符的rpm包
yum search mozilla
注:在rpm包名,包描述等中搜索
</code></pre>

<p>23.搜索有包含特定文件名的rpm包</p>

<pre><code>yum provides realplay
</code></pre>

<p><strong>选项：</strong></p>

<ol>
<li>-y 直接装（不用交互没用提示信息）</li>
<li>-q 静默模式</li>
<li>-d 调试级别</li>
<li>--nogpgcheck 不检查包签名</li>
<li>-t --tolerant 忽略以装过的包，不再提示错误</li>
</ol>

<p><strong>注意：</strong></p>

<p>如果网速慢的话可以通过增加yum的超时时间，这样就不会总是因为超时而退出。</p>

<pre><code>#vi /etc/yum.conf
#加上这么一句
timeout=120
</code></pre>

<p>2、yum Existing lock错误的解决办法
如果系统启动的时候， yum出现Existing lock /var/run/yum.pid: another copy is running as pid 3380. Aborting.可以用下面的办法解决：</p>

<pre><code>方法一
etc/init.d/yum-updatesd stop

方法二
rm -f /var/run/yum.pid
</code></pre>

<p>主要原因就是yum在自动更新，只要关掉它就可以了。</p>

<h2>参考</h2>

<p><a href="http://www.cnblogs.com/mchina/archive/2013/01/04/2842275.html">1.CentOS yum 源的配置与使用</a></p>

<p><a href="http://maitianli.blog.51cto.com/8538087/1357070">2.为 CentOS 6.5 配置163 yum 源</a></p>

<p><a href="http://www.cnblogs.com/shuaixf/archive/2011/11/30/2268496.html">3.配置 yum 源的两种方法</a></p>
