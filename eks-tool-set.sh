#!/bin/bash
# This script sets up the EKS toolset, including kubectl, fzf, kns, ktx, eksctl, and Helm.
# 이 스크립트는 kubectl, fzf, kns, ktx, eksctl, Helm 등 EKS 도구를 설정합니다.

source ./helper.sh 
# Load helper functions or variables from helper.sh / helper.sh 파일 로드

whoami 
# Display the current user / 현재 사용자 출력

if [ $(id -u) -eq 0 ]; then
  export HOME="/root" 
  # If the user is root, set HOME to /root / 사용자가 root라면 HOME을 /root로 설정
else
  export HOME="/home/$(whoami)"
  # Otherwise, set HOME to the user's home directory / 그렇지 않으면 사용자의 홈 디렉토리로 설정
fi

env 
# Display environment variables / 환경 변수를 출력

echo "Install EKS toolset"
# EKS 도구 설치 시작 메시지 출력

echo "------------------------------------------------------"

# Download kubectl / kubectl 다운로드
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.10/2024-12-12/bin/linux/amd64/kubectl
#curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.6/2024-12-12/bin/linux/amd64/kubectl
#curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-12-12/bin/linux/amd64/kubectl
chmod +x ./kubectl 
# Make kubectl executable / kubectl 실행 가능하도록 권한 설정
sudo mv ./kubectl /usr/local/bin/
# Move kubectl to /usr/local/bin / kubectl을 /usr/local/bin으로 이동

kubectl version --client --output yaml 
# Check the kubectl version / kubectl 버전 확인

echo "Installed Kubectl and util tools"
# kubectl 및 유틸리티 도구 설치 완료 메시지 출력

echo "------------------------------------------------------"

/usr/local/bin/kubectl completion bash >> /home/ec2-user/.bash_completion 
# Enable kubectl bash completion / kubectl bash 자동완성 설정

# Install fzf for command-line fuzzy finder / 커맨드라인 fuzzy finder fzf 설치
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all 
source ~/.bashrc 
# Reload bash configuration / bash 설정 다시 로드

# Download and install kns and ktx utilities / kns와 ktx 유틸리티 다운로드 및 설치
wget https://raw.githubusercontent.com/blendle/kns/master/bin/kns
wget https://raw.githubusercontent.com/blendle/kns/master/bin/ktx
chmod +x ./kns ./ktx 
# Make them executable / 실행 가능하도록 권한 설정
sudo mv ./kns /usr/local/bin/kns
sudo mv ./ktx /usr/local/bin/ktx
# Move them to /usr/local/bin / /usr/local/bin으로 이동

# Add an alias for kubectl node management / kubectl 노드 관리 alias 추가
echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" | tee -a /home/ec2-user/.bashrc

echo "Installed additional tools"
# 추가 도구 설치 완료 메시지 출력

echo "------------------------------------------------------"

# Download and install eksctl / eksctl 다운로드 및 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
# Move eksctl to /usr/local/bin / eksctl을 /usr/local/bin으로 이동

eksctl version 
# Check eksctl version / eksctl 버전 확인

echo "Downloaded and installed eksctl"
# eksctl 설치 완료 메시지 출력

echo "------------------------------------------------------"

# Install Helm / Helm 설치
wget https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
tar -zxvf helm-v3.13.2-linux-amd64.tar.gz 
# Extract the Helm package / Helm 패키지 해제
sudo cp linux-amd64/helm /usr/local/bin/helm 
# Move Helm binary to /usr/local/bin / Helm 바이너리를 /usr/local/bin으로 이동

helm version --short 
# Check Helm version / Helm 버전 확인

# Add Helm repositories and update / Helm 저장소 추가 및 업데이트
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "Completed setup of Helm"
# Helm 설치 완료 메시지 출력

echo "------------------------------------------------------"

# Enable bash completion / bash 자동완성 활성화
echo ". /etc/profile.d/bash_completion.sh" | tee -a /home/ec2-user/.bash_profile
echo ". /home/ec2-user/.bash_completion" | tee -a /home/ec2-user/.bash_profile

log_text "Success" "Completed EKS Tools Setup..."
# Log a success message / 설치 완료 성공 메시지 로그
