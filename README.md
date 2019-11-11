# kub
to install kubernetes run on a clean centos 7 server

curl -s https://raw.githubusercontent.com/cloud-66/kub/master/centos7.sh | sh -s

after install kubernetes component initialize cluster

!!!USE ip range for pod-network-cidr not used on your local network

for calico

kubeadm init --pod-network-cidr=192.168.0.0/16

for flannel

kubeadm init --pod-network-cidr=10.244.0.0/16

and install CNI