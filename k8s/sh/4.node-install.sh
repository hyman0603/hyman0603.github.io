#!/bin/bash

# k8s安装Node节点
# Blog http://hyman.shop

echo '初始化环境'
curl -s http://hyman.shop/k8s/sh/1.set.sh |bash

#docker check 
docker images &>/dev/null
[[ $? = 0 ]] || { curl -s http://hyman.shop/k8s/sh/docker.sh |bash ; }
docker images &>/dev/null
[[ $? = 0 ]] && { echo "docker ok"; } || { echo "docker error";exit; }

#安装kubelet kubeadm 
curl -s http://hyman.shop/k8s/sh/kube.sh |bash

echo '下载K8S相关镜像'
MyUrl=registry.cn-shenzhen.aliyuncs.com/hyman0603
images=(kube-proxy-amd64:v1.10.2 pause-amd64:3.1)
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