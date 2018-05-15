#!/bin/bash
# Blog http://hyman.shop
#����k8s���񣬰�װkubeadm����

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

#docker check 
docker images &>/dev/null
[[ $? = 0 ]] || { curl -s http://hyman.shop/k8s/sh/docker.sh |bash ; }
docker images &>/dev/null
[[ $? = 0 ]] && { echo "docker ok"; } || { echo "docker error";exit; }

#��װkubelet kubeadm 
curl -s http://hyman.shop/k8s/sh/kube.sh |bash

echo '����K8S��ؾ���'
MyUrl=registry.cn-shenzhen.aliyuncs.com/hyman0603
images=(kube-proxy-amd64:v1.10.2 kube-controller-manager-amd64:v1.10.2 kube-scheduler-amd64:v1.10.2 kube-apiserver-amd64:v1.10.2 etcd-amd64:3.2.18 kubernetes-dashboard-amd64:v1.8.3 heapster-grafana-amd64:v4.4.3 heapster-influxdb-amd64:v1.3.3 heapster-amd64:v1.4.2 k8s-dns-dnsmasq-nanny-amd64:1.14.10 k8s-dns-sidecar-amd64:1.14.10 k8s-dns-kube-dns-amd64:1.14.10 pause-amd64:3.1)
#
for imageName in ${images[@]} ; do
  docker pull $MyUrl/$imageName
  docker tag $MyUrl/$imageName k8s.gcr.io/$imageName
  docker rmi $MyUrl/$imageName
done
#flannel-amd64
docker pull $MyUrl/flannel:v0.10.0-amd64
docker tag $MyUrl/flannel:v0.10.0-amd64  quay.io/coreos/flannel:v0.10.0-amd64
docker rmi $MyUrl/flannel:v0.10.0-amd64

echo '����yml�ļ�,����flannel����,dashboard�õ�'
mkdir -p $HOME/k8s/heapster ; cd $HOME/
YmlUrl=http://hyman.shop/k8s/yml
curl -s $YmlUrl/kube-flannel.yml >k8s/kube-flannel.yml
curl -s $YmlUrl/kubernetes-dashboard.yaml >k8s/kubernetes-dashboard.yaml
curl -s $YmlUrl/heapster-rbac.yaml >k8s/heapster-rbac.yaml
curl -s $YmlUrl/heapster/influxdb.yaml >k8s/heapster/influxdb.yaml 
curl -s $YmlUrl/heapster/heapster.yaml >k8s/heapster/heapster.yaml
curl -s $YmlUrl/heapster/grafana.yaml >k8s/heapster/grafana.yaml 

echo  
echo '�����б�'
docker images |egrep 'k8s.gcr.io|quay.io'
echo  
echo "yml�����ļ�"
ls -l $HOME/k8s/
echo  

##############################