#!/bin/bash

# 🛠️ AWS CLI, Session Manager, jq 등 도구 설치 스크립트

set -e

echo "------------------------------------------------------"
echo "☁️  [1/3] AWS CLI 설치 중..."
echo "------------------------------------------------------"

# AWS CLI 다운로드 및 설치
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && echo "✅ AWS CLI zip 파일 다운로드 완료"
unzip -q awscliv2.zip && echo "✅ 압축 해제 완료"
sudo ./aws/install && echo "✅ AWS CLI 설치 완료"

# PATH 및 자동완성 설정
export PATH=/usr/local/bin:$PATH
source ~/.bashrc
source ~/.bash_profile 2>/dev/null || true

# 자동완성 등록
if command -v aws_completer &> /dev/null; then
  complete -C "$(which aws_completer)" aws && echo "✅ AWS CLI 자동완성 활성화 완료"
fi

# 버전 확인
aws --version && echo "✅ AWS CLI 버전 확인 완료"

echo "------------------------------------------------------"
echo "🔐 [2/3] Session Manager 플러그인 설치 중..."
echo "------------------------------------------------------"

# Session Manager Plugin 설치
curl -s "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && echo "✅ 플러그인 RPM 다운로드 완료"
sudo yum install -y session-manager-plugin.rpm && echo "✅ 플러그인 설치 완료"
session-manager-plugin --version && echo "✅ Session Manager 버전 확인 완료"

echo "------------------------------------------------------"
echo "🔧 [3/3] jq, gettext, bash-completion 설치 중..."
echo "------------------------------------------------------"

sudo yum -y install jq gettext bash-completion && echo "✅ 유틸리티 설치 완료"

echo "------------------------------------------------------"
echo "🎉 모든 도구 설치가 성공적으로 완료되었습니다!"
echo "🧩 설치된 항목: AWS CLI, Session Manager, jq, gettext, bash-completion"
echo "------------------------------------------------------"
