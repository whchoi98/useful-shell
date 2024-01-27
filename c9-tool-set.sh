#!/bin/bash
# toolset install in Cloud9
echo "Install the latest version of aws cli."
echo "------------------------------------------------------"
# AWS CLI Upgrade
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
source ~/.bashrc
aws --version
which aws_completer
export PATH=/usr/local/bin:$PATH
source ~/.bash_profile
complete -C '/usr/local/bin/aws_completer' aws
source ~/.bashrc
aws --version

echo "Install session manager."
echo "------------------------------------------------------"
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo sudo yum install -y session-manager-plugin.rpm
session-manager-plugin --version

echo "Install bash-comletion jq"
echo "------------------------------------------------------"
sudo yum -y install jq gettext bash-completion moreutils


