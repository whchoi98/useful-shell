#!/bin/bash
#VPC_NAME=
#CLUSTER1_NAME=
#EKS_VERSION=
#Valuse="Subnet's Name tag's Value"
export NODE_INSTANCE_TYPE=m5.xlarge
export public_mgmd_node="managed-frontend-workloads"
export private_mgmd_node="managed-backend-workloads"
echo "export public_mgmd_node=${public_mgmd_node}" | tee -a ~/.bash_profile
echo "export private_mgmd_node=${private_mgmd_node}" | tee -a ~/.bash_profile

AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region "$AWS_REGION"))
echo "export C1_VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME | jq -r '.Vpcs[].VpcId')" | tee -a ~/.bash_profile

echo "export C1_PublicSubnet01=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PublicSubnet01' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export C1_PublicSubnet02=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PublicSubnet02' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
#echo "export C1_PublicSubnet03=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PublicSubnet03' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export C1_PrivateSubnet01=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PrivateSubnet01' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
echo "export C1_PrivateSubnet02=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PrivateSubnet02' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile
#echo "export C1_PrivateSubnet03=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=LatticeWorkshop-Client-PrivateSubnet03' | jq -r '.Subnets[].SubnetId')" | tee -a ~/.bash_profile

source ~/.bash_profile

cat << EOF > ~/environment/eks_c1.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${CLUSTER1_NAME}
  region: ${AWS_REGION}
  version: "${EKS_VERSION}"

vpc: 
  id: ${C1_VPC_ID}
  subnets:
    public:
      PublicSubnet01:
        az: ${AWS_REGION}a
        id: ${C1_PublicSubnet01}
      PublicSubnet02:
        az: ${AWS_REGION}b
        id: ${C1_PublicSubnet02}
#      PublicSubnet03:
#        az: ${AWS_REGION}c
#        id: ${C1_PublicSubnet03}
    private:
      PrivateSubnet01:
        az: ${AWS_REGION}a
        id: ${C1_PrivateSubnet01}
      PrivateSubnet02:
        az: ${AWS_REGION}b
        id: ${C1_PrivateSubnet02}
#      PrivateSubnet03:
#        az: ${AWS_REGION}c
#        id: ${C1_PrivateSubnet03}

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
  minSize: 2
  maxSize: 4
  desiredCapacity: 2
  instanceType: ${NODE_INSTANCE_TYPE}
  subnets:
    - ${C1_PrivateSubnet01}
    - ${C1_PrivateSubnet02}
#    - ${C1_PrivateSubnet03}
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

cd ~/environment/
eksctl create cluster -f lattice_eks01.yaml --dry-run



