#!/bin/bash

# 🧰 EKS Toolset 설치 스크립트: kubectl, fzf, kns, ktx, eksctl, helm

set -e

source ./helper.sh 2>/dev/null || true

echo "👤 현재 사용자: $(whoami)"

# 🏠 홈 디렉토리 설정
if [ $(id -u) -eq 0 ]; then
  export HOME="/root"
else
  export HOME="/home/$(whoami)"
fi

echo "📦 환경 변수 설정 완료"
env | grep -E '^HOME|^USER'

echo "🔧 EKS Toolset 설치 시작"
echo "------------------------------------------------------"

# ============================================
# 📌 Step 1: kubectl 설치 (Amazon EKS용 버전 선택)
# ============================================

echo "📡 EKS에서 지원하는 kubectl 버전을 확인 중입니다..."
K8S_VERSIONS=("1.30.7" "1.31.3" "1.32.0")  # 필요한 경우 자동화 가능

for i in "${!K8S_VERSIONS[@]}"; do
  echo "$((i+1)). ${K8S_VERSIONS[$i]}"
done

read -p "👉 설치할 kubectl 버전 번호를 선택하세요 (1-${#K8S_VERSIONS[@]}): " SELECTED_INDEX
if ! [[ "$SELECTED_INDEX" =~ ^[0-9]+$ ]] || [ "$SELECTED_INDEX" -lt 1 ] || [ "$SELECTED_INDEX" -gt ${#K8S_VERSIONS[@]} ]; then
  echo "❌ 잘못된 선택입니다. 종료합니다."
  exit 1
fi

KUBECTL_VERSION="${K8S_VERSIONS[$((SELECTED_INDEX-1))]}"
KUBECTL_DATE="2024-12-12"
if [[ "$KUBECTL_VERSION" == "1.32.0" ]]; then
  KUBECTL_DATE="2024-12-20"
fi

KUBECTL_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64/kubectl"

echo "⬇️  kubectl ${KUBECTL_VERSION} 다운로드 중..."
curl -s -O "$KUBECTL_URL"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/

echo "✅ kubectl 설치 완료:"
kubectl version --client --output yaml
kubectl completion bash >> "${HOME}/.bash_completion"

echo "------------------------------------------------------"

# ============================================
# 🔍 Step 2: fzf 설치
# ============================================
echo "🔍 fzf 설치 중..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
source ~/.bashrc

# ============================================
# 🎛 Step 3: kns & ktx 설치
# ============================================
echo "🎛 kns 및 ktx 설치 중..."
wget -q https://raw.githubusercontent.com/blendle/kns/master/bin/kns
wget -q https://raw.githubusercontent.com/blendle/kns/master/bin/ktx
chmod +x kns ktx
sudo mv kns /usr/local/bin/kns
sudo mv ktx /usr/local/bin/ktx

# 🔗 유용한 kubectl alias 추가
echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" >> "${HOME}/.bashrc"

echo "✅ fzf, kns, ktx 설치 완료"
echo "------------------------------------------------------"

# ============================================
# 🚀 Step 4: eksctl 설치
# ============================================
echo "🚀 eksctl 설치 중..."
curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
eksctl version

echo "✅ eksctl 설치 완료"
echo "------------------------------------------------------"

# ============================================
# ⚓ Step 5: Helm 설치
# ============================================
echo "⚓ Helm 설치 중..."
wget -q https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
tar -zxf helm-v3.13.2-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/helm
helm version --short

# Helm 저장소 설정
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "✅ Helm 설치 및 저장소 구성 완료"
echo "------------------------------------------------------"

# ============================================
# 🎯 Bash 자동완성 설정
# ============================================
echo ". /etc/profile.d/bash_completion.sh" >> "${HOME}/.bash_profile"
echo ". ${HOME}/.bash_completion" >> "${HOME}/.bash_profile"

echo "🥳 모든 EKS 도구 설치가 완료되었습니다!"
log_text "Success" "✅ Completed EKS Tools Setup"
