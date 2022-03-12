#!/bin/bash

read -p "Enter ng_public01 ip address: " ng_public01
read -p "Enter ng_public02 ip address: " ng_public02
read -p "Enter ng_public03 ip address: " ng_public03
read -p "Enter ng_private01 ip address: " ng_private01
read -p "Enter ng_private02 ip address: " ng_private02
read -p "Enter ng_private03 ip address: " ng_private03
read -p "Enter mgmd_ng_public01 ip address: " mgmd_ng_public01
read -p "Enter mgmd_ng_public02 ip address: " mgmd_ng_public02
read -p "Enter mgmd_ng_public03 ip address: " mgmd_ng_public03
read -p "Enter mgmd_ng_private01 ip address: " mgmd_ng_private01
read -p "Enter mgmd_ng_private02 ip address: " mgmd_ng_private02
read -p "Enter mgmd_ng_private03 ip address: " mgmd_ng_private03

echo "export ng_public01=${ng_public01}" | tee -a ~/.bash_profile
echo "export ng_public02=${ng_public02}" | tee -a ~/.bash_profile
echo "export ng_public02=${ng_public03}" | tee -a ~/.bash_profile
echo "export ng_private01=${ng_private01}" | tee -a ~/.bash_profile
echo "export ng_private02=${ng_private02}" | tee -a ~/.bash_profile
echo "export ng_private03=${ng_private03}" | tee -a ~/.bash_profile
echo "export mgmd_ng_public01=${mgmd_ng_public01}" | tee -a ~/.bash_profile
echo "export mgmd_ng_public02=${mgmd_ng_public02}" | tee -a ~/.bash_profile
echo "export mgmd_ng_public02=${mgmd_ng_public03}" | tee -a ~/.bash_profile
echo "export mgmd_ng_private01=${mgmd_ng_private01}" | tee -a ~/.bash_profile
echo "export mgmd_ng_private02=${mgmd_ng_private02}" | tee -a ~/.bash_profile
echo "export mgmd_ng_private03=${mgmd_ng_private03}" | tee -a ~/.bash_profile

