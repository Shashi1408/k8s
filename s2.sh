yum update -y
swapoff -a
modprobe br_netfilter

tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
sleep 15
yum install docker -y
systemctl start docker
systemctl enable docker

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
EOF

sleep 15
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sleep 30
systemctl enable --now kubelet
