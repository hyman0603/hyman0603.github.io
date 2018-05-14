#!/bin/bash
# Blog http://hyman.shop
# CentOS 7.4 

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

echo '# »ù´¡ÅäÖÃ#
#¹Ø±Õ·À»ðÇ½
#¹Ø±ÕSelinux
#¹Ø±ÕSwap
#ÄÚºËÅäÖÃ
'
#·À»ðÇ½#
systemctl stop firewalld &>/dev/null
systemctl disable firewalld &>/dev/null
[[ -f /etc/init.d/ufw ]] && { ufw disable;}
[[ -f /etc/init.d/iptables ]] && { /etc/init.d/iptables stop; }

#¹Ø±ÕSelinux
setenforce  0 &>/dev/null
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config 

#¹Ø±ÕSwap
swapoff -a 
sed 's/.*swap.*/#&/' /etc/fstab &>/dev/null

#ÄÚºË#
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl -p /etc/sysctl.d/k8s.conf &>/dev/null
echo "sysctl -p /etc/sysctl.d/k8s.conf" >>/etc/profile
echo "#myset
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
* soft  memlock  unlimited
* hard memlock  unlimited
">> /etc/security/limits.conf

#hosts

##############################