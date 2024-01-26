#!/bin/bash
# Run in each region cloudshell.

export AWS_REGION=ap-northeast-2
export EC2_TYPE=m5.xlarge
export C9_ROLE_NAME=c9_role
export C9_PROFILE=c9_profile

aws iam create-role --path / \
--role-name ${C9_ROLE_NAME} \
--description "Role used by Cloud9 environment" \
--assume-role-policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"ec2.amazonaws.com\"]},\"Action\":[\"sts:AssumeRole\"]}]}"

aws iam attach-role-policy --role-name ${C9_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

aws iam create-instance-profile --instance-profile-name ${C9_PROFILE}

aws iam add-role-to-instance-profile --instance-profile-name ${C9_PROFILE} --role-name ${C9_ROLE_NAME}

#AMI aliased
#Amazon Linux 2: amazonlinux-2-x86_64
#Amazon Linux 2023 (recommended): amazonlinux-2023-x86_64
#Ubuntu 18.04: ubuntu-18.04-x86_64
#Ubuntu 22.04: ubuntu-22.04-x86_64

aws cloud9 create-environment-ec2 --name ${C9_NAME} --description "Cloud9 Environment." --instance-type "${EC2_TYPE}" --image-id resolve:ssm:/aws/service/cloud9/amis/amazonlinux-2023-x86_64 --region $AWS_REGION --automatic-stop-time-minutes 300

C9_IDS=$(aws cloud9 list-environments | jq -r '.environmentIds | join(" ")')
C9_EC2=$(aws cloud9 describe-environments --environment-ids "${C9_IDS}" | jq -r '.environments[] | select(.name == "MyCloud9") | .id')

sleep 60

C9_EC2_ID=$(aws ec2 describe-instances --region "${AWS_REGION}" --filters "Name=tag:aws:cloud9:environment,Values=${C9_EC2}" --query "Reservations[*].Instances[*].InstanceId" --output text)

aws ec2 associate-iam-instance-profile --instance-id "${C9_EC2}" --iam-instance-profile Name=${C9_PROFILEP} --region "${AWS_REGION}"

aws cloud9 update-environment --environment-id "${C9_EC2}" --managed-credentials-action DISABLE
