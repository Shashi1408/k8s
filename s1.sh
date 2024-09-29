yum install -y yum-utils device-mapper-persistent-data lvm2
swapoff -a
modprobe br_netfilter
tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
yum install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker root

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=Mem

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

sleep 60
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
