#!/bin/bash
# Blog http://hyman.shop

echo "install kubelet kubeadm"

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

#install kubeadm、kubelet
yum -y install kubelet kubeadm kubectl kubernetes-cni
#配置kubelet
sed -i 's/driver=systemd/driver=cgroupfs/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl enable kubelet

echo "download k8s images"
MyUrl=registry.cn-shenzhen.aliyuncs.com/hyman0603
images=(kube-proxy-amd64:v1.11.0 pause-amd64:3.1)
for imageName in ${images[@]} ; do
  docker pull $MyUrl/$imageName
  docker tag $MyUrl/$imageName k8s.gcr.io/$imageName
  docker rmi $MyUrl/$imageName
done
docker pull $MyUrl/flannel-amd64:v0.10.0-amd64
docker tag $MyUrl/flannel:v0.10.0-amd64  quay.io/coreos/flannel:v0.10.0-amd64
docker rmi $MyUrl/flannel:v0.10.0-amd64
docker images |egrep 'gcr.io|quay.io'

echo  
echo  
echo '添加Node节点到Master       kubeadm join MasterIP:6443 --token'
echo  
echo '在Master查看添加Node命令   cat $HOME/k8s.add.node.txt'
echo  

##############################