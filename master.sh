#!/bin/bash

# 1. Get Private IP of the EC2 Instance
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# 2. Initialize Cluster
# Note: --pod-network-cidr=192.168.0.0/16 is the default for Calico
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=$PRIVATE_IP

# 3. Setup Kubeconfig for current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 4. Install Calico CNI (Operator based)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

# 5. Generate Join command for Workers
echo "--------------------------------------------------------"
echo "MASTER READY. Run the following on your Worker Nodes:"
kubeadm token create --print-join-command
