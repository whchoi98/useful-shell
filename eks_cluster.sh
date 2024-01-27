#!/bin/bash

#source ./helper.sh

AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region "$AWS_REGION"))
echo "export CLUSTER_VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME | jq -r '.Vpcs[].VpcId')" | tee -a ~/.bash_profile

echo "export CLIENTS_PublicSubnet01=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PublicSubnet01' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export CLIENTS_PublicSubnet02=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PublicSubnet02' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export CLIENTS_PublicSubnet03=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PublicSubnet03' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export CLIENTS_PrivateSubnet01=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PrivateSubnet01' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export CLIENTS_PrivateSubnet02=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PrivateSubnet02' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export CLIENTS_PrivateSubnet03=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PrivateSubnet03' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile

export public_mgmd_node="managed-frontend-workloads"
export private_mgmd_node="managed-backend-workloads"
echo "export public_mgmd_node=${public_mgmd_node}" | tee -a ~/.bash_profile
echo "export private_mgmd_node=${private_mgmd_node}" | tee -a ~/.bash_profile

#export PUBLIC_SUBNETS_LIST=($(aws ec2 describe-subnets --filters Name=vpc-id,Values=$CLUSTER_VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].{AZ: AvailabilityZone, SUBNET: SubnetId}' --output json))
#export PRIVATE_SUBNETS_LIST=($(aws ec2 describe-subnets --filters Name=vpc-id,Values=$CLUSTER_VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`true`].{AZ: AvailabilityZone, SUBNET: SubnetId}' --output json))
#echo "Identified Public subnets ${PUBLIC_SUBNETS_LIST[@]}"
#echo "Identified Private subnets ${PRIVATE_SUBNETS_LIST[@]}"
#AZ1=${AZS[0]}
#AZ2=${AZS[1]}
#AZ3=${AZS[2]}
#PUBLIC_SUBNETS[0]=$(echo ${PUBLIC_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ1" '.[] | select(.AZ == $AZ ).SUBNET')
#PUBLIC_SUBNETS[1]=$(echo ${PUBLIC_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ2" '.[] | select(.AZ == $AZ ).SUBNET')
#PUBLIC_SUBNETS[2]=$(echo ${PUBLIC_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ3" '.[] | select(.AZ == $AZ ).SUBNET')
#PRIVATE_SUBNETS[0]=$(echo ${PRIVATE_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ1" '.[] | select(.AZ == $AZ ).SUBNET')
#PRIVATE_SUBNETS[1]=$(echo ${PRIVATE_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ2" '.[] | select(.AZ == $AZ ).SUBNET')
#PRIVATE_SUBNETS[2]=$(echo ${PRIVATE_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ3" '.[] | select(.AZ == $AZ ).SUBNET')
#echo ${PUBLIC_SUBNETS[*]}
#echo ${PRIVATE_SUBNETS[*]}
#aws ec2 create-tags --resources ${PUBLIC_SUBNETS[0]} --tags Key=kubernetes.io/cluster/${CLUSTER1_NAME},Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER1_NAME}
#aws ec2 create-tags --resources ${PUBLIC_SUBNETS[1]} --tags Key=kubernetes.io/cluster/${CLUSTER1_NAME},Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER1_NAME}
#aws ec2 create-tags --resources ${PUBLIC_SUBNETS[2]} --tags Key=kubernetes.io/cluster/${CLUSTER1_NAME},Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER1_NAME}
#aws ec2 create-tags --resources ${PRIVATE_SUBNETS[0]} --tags Key=kubernetes.io/cluster/${CLUSTER1_NAME},Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER1_NAME}
#aws ec2 create-tags --resources ${PRIVATE_SUBNETS[1]} --tags Key=kubernetes.io/cluster/${CLUSTER1_NAME},Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER1_NAME}
#aws ec2 create-tags --resources ${PRIVATE_SUBNETS[2]} --tags Key=kubernetes.io/cluster/${CLUSTER1_NAME},Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER1_NAME}
#echo "Completed adding EKS tags to be make subnets compliant"

source ~/.bash_profile

cat << EOF > ~/environment/vpclattice/cloud9/lattice_eks01.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${CLUSTER1_NAME}
  region: ${AWS_REGION}
  version: "${EKS_VERSION}"

vpc: 
  id: ${CLUSTER_VPC_ID}
  subnets:
    public:
      PublicSubnet01:
        az: ${AWS_REGION}a
        id: ${CLIENTS_PublicSubnet01}
      PublicSubnet02:
        az: ${AWS_REGION}b
        id: ${CLIENTS_PublicSubnet02}
      PublicSubnet03:
        az: ${AWS_REGION}c
        id: ${CLIENTS_PublicSubnet03}
    private:
      PrivateSubnet01:
        az: ${AWS_REGION}a
        id: ${CLIENTS_PrivateSubnet01}
      PrivateSubnet02:
        az: ${AWS_REGION}b
        id: ${CLIENTS_PrivateSubnet02}
      PrivateSubnet03:
        az: ${AWS_REGION}c
        id: ${CLIENTS_PrivateSubnet03}

cloudWatch:
    clusterLogging:
        enableTypes: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
iam:
  withOIDC: true
addons:
- name: vpc-cni
  attachPolicyARNs:
    - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
- name: coredns
  version: latest
- name: kube-proxy
  version: latest
- name: aws-ebs-csi-driver
  wellKnownPolicies:
    ebsCSIController: true

managedNodeGroups:
- name: nodegroup
  minSize: 3
  maxSize: 3
  desiredCapacity: 3
  instanceType: ${NODE_INSTANCE_TYPE}
  subnets:
    - ${CLIENTS_PrivateSubnet01}
    - ${CLIENTS_PrivateSubnet02}
    - ${CLIENTS_PrivateSubnet03}
  volumeSize: 20
  volumeType: gp3
  privateNetworking: true
  ssh:
    enableSsm: true
  labels:
    nodegroup-type: "${private_mgmd_node}"
  tags:
    nodegroup-role: workshop
  iam:
    attachPolicyARNs:
    withAddonPolicies:
      autoScaler: true
      cloudWatch: true
      ebs: true
      fsx: true
      efs: true

EOF

cd ~/environment/vpclattice/cloud9/
eksctl create cluster -f lattice_eks01.yaml --dry-run



