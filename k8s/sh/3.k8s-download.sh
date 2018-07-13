#!/bin/bash
# Blog http://hyman.shop

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }


docker images &>/dev/null
[[ $? = 0 ]] && { echo "docker ok"; } || { echo "docker error";exit; }


echo 'install kubelet kubeadm '
echo '#k8s
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
'>/etc/yum.repos.d/kubernetes.repo

yum -y install kubelet kubeadm kubectl kubernetes-cni
echo 'configuration kubelet'
sed -i 's/driver=systemd/driver=cgroupfs/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl enable kubelet


echo 'download K8S images'
MyUrl=registry.cn-shenzhen.aliyuncs.com/hyman0603
images=(
kube-proxy-amd64:v1.11.0 kube-controller-manager-amd64:v1.11.0 kube-scheduler-amd64:v1.11.0 
kube-apiserver-amd64:v1.11.0 etcd-amd64:3.2.18 coredns:1.1.3 kubernetes-dashboard-amd64:v1.8.3 
heapster-grafana-amd64:v4.4.3 heapster-influxdb-amd64:v1.3.3 heapster-amd64:v1.5.3 
k8s-dns-dnsmasq-nanny-amd64:1.14.10 k8s-dns-sidecar-amd64:1.14.10 k8s-dns-kube-dns-amd64:1.14.10 pause-amd64:3.1
)

#metrics-server-amd64:v0.2.1  k8s-dns-dnsmasq-nanny-amd64:1.14.8 k8s-dns-sidecar-amd64:1.14.8 k8s-dns-kube-dns-amd64:1.14.8


#
for imageName in ${images[@]} ; do
  docker pull $MyUrl/$imageName
  docker image tag $MyUrl/$imageName k8s.gcr.io/$imageName
  docker image rm $MyUrl/$imageName
done
  
#flannel-amd64
docker pull $MyUrl/flannel:v0.10.0-amd64
docker tag $MyUrl/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
docker rmi $MyUrl/flannel:v0.10.0-amd64

echo 'download yaml files'
mkdir -p $HOME/k8s/heapster ; cd $HOME/
YmlUrl=http://hyman.shop/k8s/yml

#heapster
curl -s https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml > k8s/kube-flannel.yml
curl -s https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml > k8s/kubernetes-dashboard.yaml
curl -s https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml > k8s/heapster-rbac.yaml
curl -s https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml > k8s/heapster/influxdb.yaml 
curl -s https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml > k8s/heapster/heapster.yaml
curl -s https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml > k8s/heapster/grafana.yaml 

#metrics-server
#curl -s https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-delegator.yaml > k8s/metrics-server/auth-delegator.yaml
#curl -s https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-reader.yaml > k8s/metrics-server/auth-reader.yaml
#curl -s https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-apiservice.yaml > k8s/metrics-server/metrics-apiservice.yaml
#curl -s https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-deployment.yaml > k8s/metrics-server/metrics-server-deployment.yaml
#curl -s https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-service.yaml > k8s/metrics-server/metrics-server-service.yaml
#curl -s https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/resource-reader.yaml > k8s/metrics-server/resource-reader.yaml

echo  
echo 'images list'
docker images |egrep 'gcr.io|quay.io'
echo  
echo "configuration yaml"
ls -l $HOME/k8s/
echo  

##############################