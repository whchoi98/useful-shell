#!/bin/bash

source ./helper.sh

whoami

if [ $(id -u) -eq 0 ]; then
  export HOME="/root" 
else
  export HOME="/home/$(whoami)"
fi

env

echo "Install EKS toolset"

echo "------------------------------------------------------"

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.11/2023-03-17/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/

kubectl version --client --output yaml

echo "Installed Kubectl and util tools"

echo "------------------------------------------------------"

/usr/local/bin/kubectl completion bash >>  /home/ec2-user/.bash_completion

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
source ~/.bashrc  # bash

wget https://raw.githubusercontent.com/blendle/kns/master/bin/kns
wget https://raw.githubusercontent.com/blendle/kns/master/bin/ktx

chmod +x ./kns
chmod +x ./ktx

sudo mv ./kns /usr/local/bin/kns
sudo mv ./ktx /usr/local/bin/ktx

echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" | tee -a /home/ec2-user/.bashrc

echo "Installed additional tools"

echo "------------------------------------------------------"

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin

eksctl version

echo "Downloaded and installed eksctl"

echo "------------------------------------------------------"

# curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

wget https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
tar -zxvf helm-v3.13.2-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/helm

helm version --short

helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "Completed setup of Helm"

echo "------------------------------------------------------"

echo ". /etc/profile.d/bash_completion.sh" |  tee -a  /home/ec2-user/.bash_profile
echo ". /home/ec2-user/.bash_completion" | tee -a  /home/ec2-user/.bash_profile

log_text "Success" "Completed EKS Tools Setup..."
