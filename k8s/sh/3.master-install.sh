#!/bin/bash
# Blog http://hyman.shop
#k8s v1.10.2 master ���ڵ㰲װ

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

#����#
kubeadm reset &>/dev/null

echo -e "\033[32m��ʼ����װK8S Master \033[0m" 
kubeadm init --kubernetes-version=v1.10.2  --pod-network-cidr=10.244.0.0/16 |tee /tmp/install.log

echo  
echo -e "\033[32mk8s node�ڵ���뱣�浽 $HOME/k8s.add.node.txt\033[0m" 
grep 'kubeadm join' /tmp/install.log >$HOME/k8s.add.node.txt
rm -f /tmp/install.log 
sleep 2

#kubectl��֤
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
##
echo "# used for kubectl ,k8s" >/etc/profile
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >>/etc/profile

sleep 5
echo -e "\033[32m�鿴K8S״̬\033[0m" 
kubectl get cs

#��masterҲ����pod
kubectl taint nodes --all node-role.kubernetes.io/master-

cd $HOME/
echo -e "\033[32m����flannel���� \033[0m" 
kubectl create -f k8s/kube-flannel.yml
sleep 5
echo  
echo -e "\033[32m����dashboard\033[0m" 
kubectl create -f k8s/kubernetes-dashboard.yaml
#dashboard���ͼ�λ�
sleep 5
kubectl create -f k8s/heapster/
kubectl create -f k8s/heapster-rbac.yaml
sleep 10
echo -e "\033[32m�鿴pod \033[0m" 
kubectl get pods --all-namespaces

echo  
echo -e "\033[32mdashboard��¼����,���浽$HOME/k8s.token.dashboard.txt\033[0m" 
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') |awk '/token:/{print$2}' >$HOME/k8s.token.dashboard.txt

echo 'dashboard��¼��������:'
echo  
cat $HOME/k8s.token.dashboard.txt
echo  
echo 'dashboard��¼��ַ https://����IP:30000��: '
IP=`sed -r 's#^.*join (.*):6443.*$#\1#' $HOME/k8s.add.node.txt`
echo "  https://$IP:30000"
echo  
echo '��¼dashboard����������token'
echo '�Ƽ� ��������'
echo '����ʾ ����ȫ������, �߼�->�������'
echo  
echo  
echo -e "\033[32m���k8s node�ڵ��������:\033[0m" 
echo  
cat $HOME/k8s.add.node.txt
echo  
echo  "���µ�¼�鿴Node    kubectl get nodes"
echo  
exit

# ��װʧ�ܣ�����ִ��

##############################