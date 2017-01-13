---
layout: post
title: "最优最小化初始化生成环境CentOS 6.x脚本攻略"
description: "最优最小化初始化生成环境CentOS 6.x脚本攻略"
category: "ops"
tags: [ops]
---

## 第一步：更换yum源为163

	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
	wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
	mv CentOS6-Base-163.repo CentOS-Base.repo
	yum clean all
	yum makecache

## 第二步：更新yum

	yum update

## 第三步：更新系统的基础软件

	yum -y install gcc gcc-c++ make autoconf libtool-ltdl-devel gd-devel freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel curl-devel bison patch unzip libmcrypt-devel libmhash-devel ncurses-devel sudo bzip2 mlocate flex lrzsz sysstat lsof setuptool  system-config-network-tui system-config-firewall-tui ntsysv ntp libaio-devel wget ntp

## 第四步：关闭SEKINUX

	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
	setenforce 0

## 第五步：修改文件打开数
	
	echo "ulimit -SHn 102400" >> /etc/rc.local
	cat >> /etc/security/limits.conf << EOF
	*           soft   nofile       102400
	*           hard   nofile       102400
	*           soft   nproc        102400
	*           hard   nproc        102400
	EOF

## 第六步：增加系统进程数（线程）的限制

	sed -i 's/1024.*/102400/' /etc/security/limits.d/90-nproc.conf

## 第七步：关闭control-alt-delete

	sed -i 's#exec /sbin/shutdown -r now#\#exec /sbin/shutdown -r now#' /etc/init/control-alt-delete.conf

## 第八步：关闭不需要的系统服务

	closeUnlessSysService.sh

	for i in `ls /etc/rc3.d/S*`
	do
	  CURSRV=`echo $i|cut -c 15-`
	  echo $CURSRV
	case $CURSRV in
	  crond | irqbalance | network | sshd | rsyslog | sysstat )
	  echo "Base services, Skip!"
	  ;;
	  *)
	  echo "change $CURSRV to off"
	  chkconfig --level 2345 $CURSRV off
	  service $CURSRV stop
	  ;;
	esac
	done
	echo "service is init is ok.............."

## 第九步：设置系统语言

	setLang.sh
	:> /etc/sysconfig/i18n
	cat >> /etc/sysconfig/i18n << EOF
	LANG="en_US.UTF-8"
	EOF

## 第十步：设置ssh

	sed -i '/^#Port/s/#Port 22/Port 65535/g' /etc/ssh/sshd_config
	sed -i '/^#UseDNS/s/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
	sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
	iptables -A INPUT -p tcp --dport 65535 -j ACCEPT
	/etc/init.d/sshd restart

## 第十一步：优化系统内核参数

	setsysctl.sh
	true > /etc/sysctl.conf
	cat >> /etc/sysctl.conf << EOF
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
	EOF
	/sbin/sysctl -p
	echo "sysctl set OK!!"

## 第十二步：关闭IPV6

	echo "alias net-pf-10 off" >> /etc/modprobe.conf
	echo "alias ipv6 off" >> /etc/modprobe.conf
	/sbin/chkconfig ip6tables off
	echo "ipv6 is disabled!"

## 第十三步：vi相关设置

	sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
	echo 'syntax on' > /root/.vimrc

## 第十四步：ntp时间同步

	/usr/sbin/ntpdate ntp.api.bz
	echo "*/5 * * * * /usr/sbin/ntpdate ntp.api.bz > /dev/null 2>&1" >> /var/spool/cron/root
	service crond restart

## 第十五步：设置硬件时钟

	hwclock --set --date="`date +%D\ %T`"
	hwclock --hctosys

## 第十六步：设置chkconfig

	set_chkconfig.sh
	chkconfig --list | awk '{print "chkconfig " $1 " off"}' > /tmp/chkconfiglist.sh;/bin/sh /tmp/chkconfiglist.sh;rm -rf /tmp/chkconfiglist.sh
	chkconfig crond on
	chkconfig irqbalance on
	chkconfig network on
	chkconfig sshd on
	chkconfig rsyslog on #CentOS 6
	chkconfig syslog on #CentOS/RHEL 5
	chkconfig iptables on
	chkconfig sendmail on
	service sendmail restart

## 第十七步：设置hosts
	
	[ "$(hostname -i)" != "127.0.0.1" ] && sed -i "s@^127.0.0.1\(.*\)@127.0.0.1   `hostname` \1@" /etc/hosts

## 第十八步：设置时区
	
	# Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

## 第十九步：增加用户并sudo提权

	#!/bin/bash
	input_fun()
	{
	    OUTPUT_VAR=$1
	    INPUT_VAR=""
	    while [ -z $INPUT_VAR ];do

	        read -p "$OUTPUT_VAR" INPUT_VAR

	    done
	    echo $INPUT_VAR

	}
	#增加用户并sudo提权
	user_add()
	{
	    USERNAME=$(input_fun "please input new user name:")
	    useradd $USERNAME

	    passwd $USERNAME

	}
	user_add

	chmod +w /etc/sudoers

	echo "$USERNAME        ALL=(ALL)     ALL" >>/etc/sudoers

	chmod -w /etc/sudoers
	
至此我们的最小化安装centos, 上述可以写成一个Centos 6.x 初始化生成脚本。

参考：http://opsmysql.blog.51cto.com/2238445/985316
