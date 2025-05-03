#!/bin/bash

# 🛠️ EKS 개발 도구 설치 스크립트 (kubectl 1.31.3 + Helm 3.16.4)
# 도구: kubectl, eksctl, helm, fzf, kns, ktx, jq, gettext, sponge

set -e

KUBECTL_VERSION="1.31.3"
HELM_VERSION="3.16.4"
CURRENT_USER=$(whoami)
export HOME="/home/${CURRENT_USER}"

echo "------------------------------------------------------"
echo "👤 사용자 확인: $CURRENT_USER"
echo "🏠 HOME 디렉토리: $HOME"
echo "------------------------------------------------------"

# kubectl 설치
echo "📦 [1/6] kubectl ${KUBECTL_VERSION} 설치 중..."
curl -sLO "https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/2024-12-12/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client --output=yaml
kubectl completion bash > "${HOME}/.kubectl_completion"
echo "source ${HOME}/.kubectl_completion" >> "${HOME}/.bashrc"
source "${HOME}/.kubectl_completion"
echo "✅ kubectl 설치 완료"
echo "------------------------------------------------------"

# 필수 유틸리티 설치
echo "🔧 [2/6] jq, gettext, bash-completion, sponge 설치 중..."
sudo yum -y install jq gettext bash-completion

if ! command -v sponge &>/dev/null; then
  echo "📦 sponge 수동 설치 중..."
  curl -sLO https://raw.githubusercontent.com/joeyh/moreutils/master/sponge
  chmod +x sponge
  sudo mv sponge /usr/local/bin/
fi

for cmd in kubectl jq envsubst sponge; do
  which $cmd &>/dev/null && echo "✅ $cmd: OK" || echo "❌ $cmd: 설치 실패"
done
echo "✅ 유틸리티 설치 완료"
echo "------------------------------------------------------"

# fzf, kns, ktx 설치
echo "🔍 [3/6] fzf, kns, ktx 설치 중..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-zsh --no-fish --no-bash

wget -q https://raw.githubusercontent.com/blendle/kns/master/bin/kns
wget -q https://raw.githubusercontent.com/blendle/kns/master/bin/ktx
chmod +x kns ktx
sudo mv kns ktx /usr/local/bin/

echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" >> "${HOME}/.bashrc"

echo "✅ fzf, kns, ktx 설치 완료"
echo "------------------------------------------------------"

# eksctl 설치
echo "🚀 [4/6] eksctl 설치 중..."
curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
. <(eksctl completion bash)
eksctl version
echo "✅ eksctl 설치 완료"
echo "------------------------------------------------------"

# Helm 설치 (3.16.4)
echo "⚓ [5/6] Helm ${HELM_VERSION} 설치 중..."
cd ~
wget -q "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
tar -zxf helm-v${HELM_VERSION}-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm version --short

helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm completion bash > ~/.helm_completion
echo "source ~/.helm_completion" >> "${HOME}/.bashrc"
. ~/.helm_completion

echo "✅ Helm 설치 완료"
echo "------------------------------------------------------"

# Bash 자동완성 설정
echo "🧠 [6/6] Bash 자동완성 구성 중..."

# /etc/profile.d/bash_completion.sh가 존재하면 로드
if [ -f /etc/profile.d/bash_completion.sh ]; then
  echo "[ -f /etc/profile.d/bash_completion.sh ] && . /etc/profile.d/bash_completion.sh" >> "${HOME}/.bash_profile"
fi

echo "------------------------------------------------------"
echo "🎉 EKS 개발 도구 설치가 완료되었습니다!"
echo "🛠️  설치된 도구: kubectl ${KUBECTL_VERSION}, eksctl, helm ${HELM_VERSION}, fzf, kns, ktx, jq, sponge"
echo "📘 Welcome to the exciting world of EKS!"
echo "------------------------------------------------------"
