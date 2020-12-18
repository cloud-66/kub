#!/bin/bash
#!/usr/bin/env bash

## Install Docker CE
## Set up the repository:
## Install packages to allow apt to use a repository over HTTPS
sudo apt update -y && sudo  apt install apt-transport-https ca-certificates curl software-properties-common gnupg2 -y

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

### Add Docker apt repository.
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
sudo apt update -y && sudo apt install docker-ce=5:19.03.14* -y


# Setup daemon.
sudo bash -c 'cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF'


sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl set-property docker.service MemoryAccounting=yes CPUAccounting=yes
sudo systemctl set-property containerd.service MemoryAccounting=yes CPUAccounting=yes
sudo systemctl daemon-reload && sudo systemctl enable docker && sudo systemctl restart docker

sudo usermod -aG docker admin

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Disable swap
swapoff -a
sed -i 's/^\(.*swap.*\)$/#\1/' /etc/fstab

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet=1.17.* kubeadm=1.17.* kubectl=1.17.*
sudo apt-mark hold kubelet kubeadm kubectl
