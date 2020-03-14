#!/bin/bash
#!/usr/bin/env bash


# Load netfilter,overlay probe specifically
sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
sudo bash -c 'cat <<EOF > /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF'

sudo sysctl --system

. /etc/os-release

sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${NAME}_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/x${NAME}_${VERSION_ID}/Release.key -O- | sudo apt-key add -
sudo apt update -qq
sudo apt install cri-o-1.17 -y

# dependency  package  conmon doesn't have binary
# because of that you need to install download and install conmon package
# https://launchpad.net/~projectatomic/+archive/ubuntu/ppa/+packages
# it is already fixed

# for 14/03/2020  fix this issue on testing repo (crio don't find runc)
# create synlink
ln -s /usr/lib/cri-o-runc/sbin/runc /usr/bin/runc

sudo systemctl daemon-reload && sudo systemctl start crio