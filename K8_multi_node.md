# Set Up EC2 Instances
> 1. Choose Ubuntu 20.04 for the EC2 instances.
> 2. The master node must be T2 medium, and the agent nodes can be T2 micro.
> 3. For their security groups, you must allow these ports (and let yourself ssh into the instance):
```
port 6443 - Custom TCP - kube-apiserver
port 443 - Custom TCP - kube-apiserver (can be either 443 or 6443)
ports 2379-2380 - Custom TCP - etcd server client API
port 10250 - Custom TCP - Kubelet API
port 10259 - Custom TCP - Kubelet scheduler 
port 10257 - Custom TCP - kube-controller-manager
port 179 Custom TCP - Calico networking (BGP)
port 5473 Custom TCP - Typha (part of Calico)
ports 30000 - 32767 - Custom TCP - Nodeport range
port 3000 - Custom TCP - nodejs
27017 - Custom TCP - mongo
port 80 - (http)
Remember to also allow your IP to SSH into the instances as well.
```
# Run these commands on both your Master node and Agent node(s)

### Create meaningful names for all nodes

Give your instances meaningful names with the command `sudo hostnamectl set-hostname "k8-master"`. You might name your worker nodes `k8-worker-node1` and `k8-worker-node2` for example.

### Login as root user and disable swap
* Login as root user with `sudo su -`.
* Disable swap: `swapoff -a; sed -i '/swap/d' /etc/fstab`. 

### Update sysctl settings for Kubernetes networking
Copy and paste this whole block into the terminal in one go. 
```bash
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
```

### Install Docker Engine
Copy and paste all of this into your terminal in one go.
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
#### Add Apt Repository
Copy and paste this block into your terminal in one go.
```bash
{
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
}
```

#### Install Specific Versions

```bash
apt update && apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
```

# On Your Master Node Only

### Initialize Kubernetes Cluster

Run the below command, but replace the ip address and the CIDR block. The ip address should be the one you can see in your master node terminal, and the CIDR block should be the same one that the VPC uses:

`kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16  --ignore-preflight-errors=all`.

### Deploy Calico Network

`kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml`

### Cluster Join Command 

`kubeadm token create --print-join-command`

Do not worry if you see a warning.

### Install helm

* Download helm with `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`.
* Make the file executable with `chmod 700 get_helm.sh`.
* Run the script with `./get_helm.sh`.

# On Your Agent Nodes Only

### Run the kubeadm join command

This command can be found at the bottom of the output found on the master node when you run `kubeadm token create --print-join-command`.

Run kubectl get pods, and you should see an error. We will deal with this blocker.

### Dealing with the 8080 blocker

Run this command in your master node:

```bash 
export KUBECONFIG=/etc/kubernetes/admin.conf
```

In your master node, go to `cd /etc/kubernetes/`. Copy admin.conf with `cat admin.conf`.

In your agent node, type `mkdir -p $HOME/.kube`.

Navigate to `cd ~/.kube` in your agent node.

In your agent node, type in `sudo nano config`, and paste all of the contents from admin.conf (which you should have copied from the master node admin.conf file).

Run `kubectl get nodes`.

# On Your Master Node - Setting Up a Kubernetes Cluster with Helm

> 1. Run `helm repo add custom-name-here https://samuel-walters.github.io/eng110-helm/`. Documentation for how to set up a helm repository on GitHub can be found [here](https://github.com/samuel-walters/Complete-CICD/blob/main/Set_Up_Helm_Repository.md).
> 2. Run `helm repo update`.
> 3. To find your new local helm repository, use the command `helm search repo`.
> 4. To install the cluster, use this repository name in the following command: `helm install custom_name repositoryname`. For example, I would use the following command: `helm install custom-name-here custom-name-here/eng110-nodeapp`.

### Useful commands for potential future use

> 1. `echo $(hostname -I | awk '{print $1}')` - Gets the ip address needed in the kubeadm init command.
> 2. `kubeadm token create --print-join-command 2> /dev/null` - Prints just the join token (possible to use with IaC).

# Potential set up with IaC

> 1. Make sure you are the root user.
> 2. Initialise kubeadm: `kubeadm init --apiserver-advertise-address=$(hostname -I | awk '{print $1}') --pod-network-cidr=172.31.0.0/16 --ignore-preflight-errors=all`.
> 3. Install calico network: `kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml`.
> 4. Run `export KUBECONFIG=/etc/kubernetes/admin.conf`.