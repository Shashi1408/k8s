yum install -y yum-utils device-mapper-persistent-data lvm2
swapoff -a
modprobe br_netfilter
tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sleep 15
sysctl --system
yum install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker root

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

systemctl enable --now kubelet

kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=Mem

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

sleep 20
#kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sleep 15
kubeadm token create --print-join-command
