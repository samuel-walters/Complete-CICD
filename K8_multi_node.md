# Set Up EC2 Instances
> 1. Choose Ubuntu 20.04 for the EC2 instances.
> 2. The master node must be T2 medium, and the agent nodes can be T2 micro.
> 3. For their security groups, you must allow port 6443, port 443, and ports 30000 - 32767.

# Run these commands in both Master and Node apps

### Login as root user and disable swap
* Login as root user with `sudo su -`.
* Disable swap: `swapoff -a; sed -i '/swap/d' /etc/fstab`. 

### Update sysctl settings for Kubernetes networking
Type this line by line
```bash
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

### Install Docker Engine
Copy and paste all of this into your terminal.
```bash
{
  apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update
  apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io
}
```

### Kubernetes Setup
#### Add Apt repository
```bash
{
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
}
```

#### Install specific versions

```bash
apt update && apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
```

# On your master node only

### Initialize Kubernetes Cluster

Run the below command, but replace the ip address and the CIDR block. The ip address should be the one you can see in your master terminal, and the CIDR block should be the same one that the VPC uses:

`kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16  --ignore-preflight-errors=all`.

### Deploy Calico Network

`kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml`

### Cluster Join Command 

`kubeadm token create --print-join-command`

### Optional - run kubectl commands as non-root user
Run these as a non-root user. This part is optional.
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

# On your kubernete agent nodes only

### Run the kubeadm join command

This command can be found at the bottom of the output found on the master node when you run `kubeadm token create --print-join-command`.

Run kubectl get pods, and you should see an error.

### Dealing with the 8080 blocker

In your master node, go to `cd /etc/kubernetes/`. Copy admin.conf with `cat admin.conf`.

In your agent node, type `mkdir -p $HOME/.kube`.

Navigate to `cd ~/.kube`.

Type in `sudo nano config`, and paste all of the contents from admin.conf (from the master node).

# Master node final commands

In your master node, run these commands to set up a ready state for your nodes:

```bash
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
```

Run `Run kubectl get nodes` to check the ready state.