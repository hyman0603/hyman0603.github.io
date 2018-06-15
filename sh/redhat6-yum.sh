#!/bin/bash
# Blog http://hyman.shop
# Redhat 6.4 

# 清除原有RHEL的YUM及相关软件包。
rpm -qa | grep yum | xargs rpm -e --nodeps
rpm -qa |grep python-urlgrabber|xargs rpm -e --nodeps
# 下载centos6的相关软件包并按照

rpm -ivh http://mirrors.163.com/centos/6/os/x86_64/Packages/python-iniparse-0.3.1-2.1.el6.noarch.rpm
rpm -ivh http://mirrors.163.com/centos/6/os/x86_64/Packages/python-urlgrabber-3.9.1-11.el6.noarch.rpm
rpm -ivh http://mirrors.163.com/centos/6/os/x86_64/Packages/yum-metadata-parser-1.1.2-16.el6.x86_64.rpm
rpm -ivh http://mirrors.163.com/centos/6/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.30-40.el6.noarch.rpm http://mirrors.163.com/centos/6/os/x86_64/Packages/yum-3.2.29-81.el6.centos.noarch.rpm

# 注释yum-plugin-fastestmirror和yum-3.2.29要一起安装。

# 下载163源
wget -P http://mirrors.163.com/.help/CentOS6-Base-163.repo /etc/yum.repos.d/
sed -i 's/$releasever/6/g' /etc/yum.repos.d/CentOS6-Base-163.repo

# 清理yum缓存
yum clean all && yum makecache

