#!/bin/bash
# This script installs AWS CLI, Session Manager, and other tools in the IDE terminal.
# 이 스크립트는 IDE 터미널에서 AWS CLI, Session Manager, 그리고 기타 도구들을 설치합니다.

echo "------------------------------------------------------"
echo "Install the latest version of AWS CLI."
# AWS CLI 최신 버전을 설치합니다.
echo "------------------------------------------------------"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && echo "AWS CLI zip file downloaded successfully." 
# Download AWS CLI zip file / AWS CLI zip 파일 다운로드 성공 메시지
unzip awscliv2.zip && echo "AWS CLI zip file extracted successfully."
# Extract the downloaded zip file / 다운로드한 zip 파일 해제 성공 메시지
sudo ./aws/install && echo "AWS CLI installed successfully."
# Install AWS CLI / AWS CLI 설치 성공 메시지
source ~/.bashrc && echo "Bash configuration reloaded successfully."
# Reload bashrc file / bashrc 파일 로드 성공 메시지
aws --version && echo "AWS CLI version checked successfully."
# Check the installed AWS CLI version / AWS CLI 버전 확인 성공 메시지

which aws_completer && echo "AWS completer path located successfully."
# Find the path of aws_completer / aws_completer 경로 확인 성공 메시지
export PATH=/usr/local/bin:$PATH && echo "PATH updated successfully."
# Add /usr/local/bin to PATH / PATH 업데이트 성공 메시지
source ~/.bash_profile && echo "Bash profile reloaded successfully."
# Reload bash_profile file / bash_profile 파일 로드 성공 메시지
complete -C '/usr/local/bin/aws_completer' aws && echo "AWS CLI auto-completion enabled successfully."
# Enable AWS CLI auto-completion / AWS CLI 자동완성 활성화 성공 메시지
source ~/.bashrc && echo "Bash configuration reloaded successfully."
# Reload bashrc file / bashrc 파일 로드 성공 메시지
aws --version && echo "AWS CLI version checked successfully."
# Recheck the AWS CLI version / AWS CLI 버전 확인 성공 메시지

echo "------------------------------------------------------"
echo "Install session manager."
# AWS Session Manager 플러그인을 설치합니다.
echo "------------------------------------------------------"
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && echo "Session Manager plugin downloaded successfully."
# Download Session Manager plugin rpm file / Session Manager 플러그인 다운로드 성공 메시지
sudo yum install -y session-manager-plugin.rpm && echo "Session Manager plugin installed successfully."
# Install Session Manager plugin / Session Manager 플러그인 설치 성공 메시지
session-manager-plugin --version && echo "Session Manager plugin version checked successfully."
# Check the installed Session Manager plugin version / Session Manager 플러그인 버전 확인 성공 메시지

echo "------------------------------------------------------"
echo "Install bash-completion, jq, and gettext."
# bash-completion, jq, gettext 도구들을 설치합니다.
echo "------------------------------------------------------"
sudo yum -y install jq gettext bash-completion && echo "bash-completion, jq, and gettext installed successfully."
# Install jq, gettext, and bash-completion / 도구 설치 성공 메시지
