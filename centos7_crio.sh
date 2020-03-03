#!/bin/bash
#!/usr/bin/env bash

## Disable firewall
systemctl stop firewalld && systemctl disable firewalld

## Install tool
yum -y update && yum -y install net-tools sysstat wget telnet yum-utils device-mapper-persistent-data lvm2 nfs-utils

# Load netfilter,overlay probe specifically
modprobe overlay
modprobe br_netfilter

# Enable IP Forwarding
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

## Install CRIO
yum-config-manager --add-repo=https://cbs.centos.org/repos/paas7-crio-114-release/x86_64/os/
yum install --nogpgcheck -y cri-o

# Start CRIO
#systemctl enable crio &&
systemctl enable crio && systemctl start crio

# Disable swap
swapoff -a
sed -i 's/^\(.*swap.*\)$/#\1/' /etc/fstab

# Lisable SELinux. If you want this enabled, comment out the next 2 lines. But you may encounter issues with enabling SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install kuberentes packages
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum -y install kubelet-1.14.* kubeadm-1.14.* kubectl-1.14.* --disableexcludes=kubernetes

cat <<EOF > /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --network-plugin=cni --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice --runtime-request-timeout=5m
EOF

systemctl daemon-reload && systemctl  restart kubelet && systemctl enable kubelet