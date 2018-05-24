#!/bin/bash
# Blog http://hyman.shop

[[ -f /etc/redhat-release ]] || { echo "It's only used for Redhat series";exit; }

#aliyun
echo '#Docker for centos 7
[docker-ce-stable]
name=Docker CE - Aliyun
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
'>/etc/yum.repos.d/docker-ce.repo

echo 'install docker'
sudo yum install -y yum-utils \
  device-mapper-persistent-data lvm2
yum install -y docker-ce

#
SetOPTS=" --registry-mirror=https://bv55mwyn.mirror.aliyuncs.com"
sed  -i "s#^ExecStart.*#& $SetOPTS #" /usr/lib/systemd/system/docker.service
#grep 'ExecStart' /usr/lib/systemd/system/docker.service
systemctl daemon-reload
echo 'start docker'
systemctl enable  docker &>/dev/null
systemctl restart  docker &>/dev/null
