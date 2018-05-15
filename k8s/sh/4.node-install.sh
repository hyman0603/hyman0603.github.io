#!/bin/bash

# k8s��װNode�ڵ�
# Blog http://hyman.shop

echo '��ʼ������'
curl -s http://hyman.shop/k8s/sh/1.set.sh |bash

#docker check 
docker images &>/dev/null
[[ $? = 0 ]] || { curl -s http://hyman.shop/k8s/sh/docker.sh |bash ; }
docker images &>/dev/null
[[ $? = 0 ]] && { echo "docker ok"; } || { echo "docker error";exit; }

#��װkubelet kubeadm 
curl -s http://hyman.shop/k8s/sh/kube.sh |bash

echo '����K8S��ؾ���'
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
echo '���Node�ڵ㵽Master       kubeadm join MasterIP:6443 --token'
echo  
echo '��Master�鿴���Node����   cat $HOME/k8s.add.node.txt'
echo  

##############################