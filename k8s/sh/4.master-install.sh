#!/bin/bash
# Blog http://hyman.shop

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

#kubeadm reset#
kubeadm reset &>/dev/null

echo -e "\033[32m install K8S Master \033[0m" 
kubeadm init --kubernetes-version=v1.11.0  --pod-network-cidr=10.244.0.0/16 |tee /tmp/install.log

echo  
echo -e "\033[32mk8s node节点代码保存到 $HOME/k8s.add.node.txt\033[0m" 
grep 'kubeadm join' /tmp/install.log >$HOME/k8s.add.node.txt
rm -f /tmp/install.log 
sleep 2

#kubectl认证
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
##
echo "# used for kubectl ,k8s" >/etc/profile
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >>/etc/profile


sleep 5
echo -e "\033[32m查看K8S状态\033[0m" 
kubectl get cs

#让master也运行pod
kubectl taint nodes --all node-role.kubernetes.io/master-

cd $HOME/
echo -e "\033[32m部署flannel网络 \033[0m" 
kubectl create -f k8s/kube-flannel.yml
sleep 5
echo  
echo -e "\033[32m部署dashboard\033[0m" 
kubectl create -f k8s/kubernetes-dashboard.yaml
#dashboard监控图形化
sleep 5
kubectl create -f k8s/heapster/
kubectl create -f k8s/heapster-rbac.yaml

sleep 10
echo -e "\033[32m查看pod \033[0m" 
kubectl get pods --all-namespaces

echo  
echo -e "\033[32mdashboard登录令牌,保存到$HOME/k8s.token.dashboard.txt\033[0m" 
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') |awk '/token:/{print$2}' >$HOME/k8s.token.dashboard.txt

echo 'dashboard登录令牌如下:'
echo  
cat $HOME/k8s.token.dashboard.txt
echo  
echo 'dashboard登录地址 https://本机IP:30000即: '
IP=`sed -r 's#^.*join (.*):6443.*$#\1#' $HOME/k8s.add.node.txt`
echo "  https://$IP:30000"
echo  
echo '登录dashboard，输入令牌token'
echo '推荐 火狐浏览器'
echo '若提示 不安全的连接, 高级->添加例外'
echo  
echo  
echo -e "\033[32m添加k8s node节点代码如下:\033[0m" 
echo  
cat $HOME/k8s.add.node.txt
echo  
echo  "重新登录查看Node    kubectl get nodes"
echo  
exit

# 安装失败，重新执行

##############################