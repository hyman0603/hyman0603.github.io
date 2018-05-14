#!/bin/bash
# Blog http://hyman.shop
# 安装kubelet kubeadm kubectl

[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

echo '安装kubelet kubeadm '

if [[ -f /etc/redhat-release ]];then
#CentOS / RHEL / Fedora
#配置源
echo '#k8s
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
'>/etc/yum.repos.d/kubernetes.repo
#kubeadm和相关工具包
yum -y install kubelet kubeadm kubectl kubernetes-cni
#配置kubelet
sed -i 's/driver=systemd/driver=cgroupfs/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl enable kubelet

#Debian / Ubuntu
elif [[ -f /etc/debian_version ]];then
apt-get update && apt-get install -y apt-transport-https
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
echo 'deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main' >/etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl

else
  echo "I don't know the OS"
  exit
fi

############################