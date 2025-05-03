#!/bin/bash

# 🛠️ EKS 개발 환경을 위한 필수 도구 설치 스크립트

set -e

# Kubernetes 버전 설정
export K8S_VERSION="v1.30.2"
export HELM_VERSION="3.16.4"

echo "------------------------------------------------------"
echo "📦 [1/7] kubectl ${K8S_VERSION} 설치 중..."
echo "------------------------------------------------------"

cd ~
curl -sLO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client --output=yaml

# 자동완성 설정
kubectl completion bash > ~/.kubectl_completion
echo "source ~/.kubectl_completion" >> ~/.bashrc
source ~/.kubectl_completion

echo "✅ kubectl 설치 완료"
echo "------------------------------------------------------"

echo "🧰 [2/7] 필수 유틸리티 설치 중 (jq, gettext, bash-completion, moreutils)..."
sudo yum -y install jq gettext bash-completion moreutils

for cmd in kubectl jq envsubst aws; do
  which $cmd &>/dev/null && echo "✅ $cmd: 사용 가능" || echo "❌ $cmd: 설치되지 않음"
done

# yq (도커 기반)
echo "🐳 yq alias 추가"
echo '
yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc
source ~/.bashrc

echo "✅ 유틸리티 설치 완료"
echo "------------------------------------------------------"

echo "🚀 [3/7] eksctl 설치 중..."
curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
. <(eksctl completion bash)
eksctl version
echo "✅ eksctl 설치 완료"
echo "------------------------------------------------------"

echo "📊 [4/7] K9s 설치 중..."
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | sudo tar xfz - -C /usr/local/bin k9s
echo "✅ K9s 설치 완료"
echo "------------------------------------------------------"

echo "🔌 [5/7] Krew 설치 중..."
(
  set -x
  cd "$(mktemp -d)"
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
  KREW="krew-${OS}_${ARCH}"
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
  tar zxvf "${KREW}.tar.gz"
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
echo "✅ Krew 설치 완료"
echo "------------------------------------------------------"

echo "🧩 [6/7] Krew 플러그인 설치 중 (ctx)..."
kubectl krew install ctx
# 추가로 필요한 경우
# kubectl krew install ns
# kubectl krew install tree
echo "✅ ctx 플러그인 설치 완료"
echo "------------------------------------------------------"

echo "⚓ [7/7] Helm ${HELM_VERSION} 설치 중..."
cd ~/environment
curl -L https://git.io/get_helm.sh | bash -s -- --version ${HELM_VERSION}
helm version --short

helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Helm 자동완성
helm completion bash > ~/.helm_completion
echo "source ~/.helm_completion" >> ~/.bashrc
. /etc/profile.d/bash_completion.sh
. ~/.helm_completion

echo "✅ Helm 설치 및 설정 완료"
echo "------------------------------------------------------"

echo "🎉 모든 EKS 개발 도구 설치 완료!"
echo "🚀 이제 kubectl, eksctl, Helm, K9s, Krew(ctx) 등 사용이 가능합니다."
echo "------------------------------------------------------"
echo "📘 Welcome to the exciting world of EKS. :)"
echo "------------------------------------------------------"
