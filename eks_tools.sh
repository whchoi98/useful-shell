#!/bin/bash
#Latest k8s version = 1.23.17, 1.24.17, 1.25.16, 1.26.11, 1.27.8, 1.28.4, 
export K8S_VERSION="v1.25.12"
echo "--------------------------"
echo "Install - KUBECTL"
echo "--------------------------"
cd ~
curl -LO https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --short --client
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "-------------------------"
echo "Completed setup of kubectl"

echo "-------------------------"
echo "Install - utils"
echo "--------------------------"
# Utils
sudo yum -y install jq gettext bash-completion moreutils
for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done
 
  echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc
echo "-------------------------"
echo "Completed setup of utils"


# eksctl
echo "--------------------------"
echo "Install - eksctl"
echo "--------------------------"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
# eksctl 자동완성 - bash
. <(eksctl completion bash)
eksctl version
echo "-------------------------"
echo "Completed setup of eksctl"
echo "-------------------------"

echo "Install - K9s"
echo "--------------------------"
#K9s
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | sudo tar xfz - -C /usr/local/bin k9s
echo "-------------------------"
echo "Completed setup of K9s"
echo "-------------------------"

echo "Install - kube krew"
echo "--------------------------"
#kube krew 
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
source ~/.bashrc
echo "--------------------------"
echo "Completed setup of Krew"
echo "--------------------------"

echo "--------------------------"
#krew ctx
kubectl krew install ctx
echo "-------------------------"
echo "Completed setup of krew ctx"

#krew ns, tree
#kubectl krew install ns
#kubectl krew install tree


echo "-------------------------"
echo "Install - Helm"
echo "--------------------------"
cd ~/environment
export HELM_VERSION=3.13.2
curl -L https://git.io/get_helm.sh | bash -s -- --version ${HELM_VERSION}
helm version --short

helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)
echo "-------------------------"
echo "Completed setup of Helm"
echo "-------------------------"
echo "Welcome to the exciting world of EKS. :)"
echo "-------------------------"
