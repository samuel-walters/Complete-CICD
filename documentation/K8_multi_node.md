# Architecture Diagram

![](https://miro.medium.com/max/700/1*WHXv2Z0bBfC7GW4egoIwTw.png)

# Set Up EC2 Instances
> 1. Choose Ubuntu 20.04 for the EC2 instances.
> 2. The master node (i.e. the controlplane) must be T2 medium, and the agent/worker nodes can be T2 micro.
> 3. For their security groups, you must allow these ports (and remember to let yourself ssh into the instance as well):

| Protocol | Port Range  | Purpose           |
|----------|-------------|-------------------|
| TCP      | 443         | Kubernetes API server (can also be 6443) |
| TCP      | 6443        | Kubernetes API server|
| TCP      | 2379-2380   | etcd server client API|
| TCP      | 10250       | Kubelet API|
| TCP      | 10259       | Kube-scheduler|
| TCP      | 10257       | Kube-controller-manager|
| TCP      | 30000 - 32767 | Nodeport range|
| TCP      | 6783 |  Weave’s control and data ports|
| TCP      | 6784 |  Weave Net daemon|
| UDP      | 6783 - 6784 |  Weave’s control and data ports|


# Run these commands on both your Master node and Agent node(s)

### Create meaningful names for all nodes

Give your instances meaningful names with the command `sudo hostnamectl set-hostname "k8-master"`. You might name your worker nodes `k8-worker-node1` and `k8-worker-node2` for example.

### Login as root user and disable swap
* Login as root user with `sudo su -`.
* Disable swap: `swapoff -a; sed -i '/swap/d' /etc/fstab`. 

### Update sysctl settings for Kubernetes networking
These commands allow IPtables to see bridged traffic.

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

Regardless of whether you want to use the below versions or not, ensure that kubeadm, kubelet and kubectl are running on the **same** version. In this case, 1.18.5-00 is used, as seen by the command below:

```bash
apt update && apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
```

# On Your Master Node Only

### Switch to root user

Double check that you are the root user. If you are not, run the "`sudo su -`" command again.

### Initialize Kubernetes Cluster

Run the below command, but replace the ip address and the CIDR block. The ip address should be the one you can see in your master node terminal, and the CIDR block should be the same one that the VPC uses:

`kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16  --ignore-preflight-errors=all`.

After it has initialised, create the environment variable `KUBECONFIG` with this command: `export KUBECONFIG=/etc/kubernetes/admin.conf`.

### Deploy Weave Network

Weave Net is a resilient and simple to use network for Kubernetes. It provides a network to connect all the pods together, and to set it up simply run the command below:

`kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`

#### Notes on Weave
By default, Weave uses the CIDR block `10.32.0.0/12`. Make sure this does not overlap with the pod network CIDR block you specified in the `kubeadm init` command. For example, if you used the CIDR block `10.0.0.0/8`, this will overlap with `10.32.0.0/12` because after the first `octet`, the rest of the `octets` could change - including the second `octet` changing to 32. 

Comprehensive documentation for integrating weave into your cluster can be found on [Weave's official website](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/).

### Cluster Join Command 

Note down the output generated from this command for later use: `kubeadm token create --print-join-command`

### Install helm

* Download helm with `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`.
* Make the file executable with `chmod 700 get_helm.sh`.
* Run the script with `./get_helm.sh`.

# Connecting the Agent Nodes

### Switch to root user on both master and agent nodes

Double check that you are the root user on your master and agent nodes. If you are not, run the `sudo su -` command again.

### Run the kubeadm join command on your agent nodes

This command can be found at the bottom of the output on the master node when you run the command `kubeadm token create --print-join-command`.

Run `kubectl get pods` in your agent nodes, and you should see an error. We will deal with this blocker.

### Dealing with the 8080 blocker

In your master node, go to `cd /etc/kubernetes/`. Copy admin.conf with `cat admin.conf`.

In your agent node, type `mkdir -p $HOME/.kube`.

Navigate to `cd ~/.kube` in your agent node.

In your agent node, type in `sudo nano config`, and paste all of the contents from admin.conf (which you should have copied from the master node admin.conf file).

Run `kubectl get nodes`, and you will see all of the nodes in the cluster.

# On Your Master Node - Setting Up a Kubernetes Cluster with Helm

> 1. Run `helm repo add custom-name-here https://samuel-walters.github.io/eng110-helm/`. Documentation for how to set up a helm repository on GitHub can be found [here](https://github.com/samuel-walters/Complete-CICD/blob/main/documentation/Set_Up_Helm_Repository.md).
> 2. Run `helm repo update`.
> 3. To find your new local helm repository, use the command `helm search repo`.
> 4. To install the cluster, use this repository name in the following command: `helm install custom_name repositoryname`. For example, I would use the following command: `helm install custom-name-here custom-name-here/eng110-nodeapp`.

# Perform a Rolling Update

To perform a rolling update, run this command: `kubectl set image deployments/eng110-node-deployment node=samuelwalters/app:latest`. 

This will update the pods without the user experiencing any downtime since the pods are incrementally updated.