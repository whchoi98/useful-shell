# Account , Region 정보를 AWS Cli로 추출합니다.
export ACCOUNT_ID=$(aws sts get-caller-identity --region ap-northeast-2 --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo $ACCOUNT_ID
echo $AWS_REGION
# bash_profile에 Account 정보, Region 정보를 저장합니다.
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile

#CMK 생성
# kms 를 생성합니다.
export EKSCLUSTER_KEY=eksworkshop
aws kms create-alias --alias-name alias/${EKSCLUSTER_KEY} --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
# kms 값을 환경변수에 저장합니다.
export MASTER_ARN=$(aws kms describe-key --key-id alias/eksworkshop --query KeyMetadata.Arn --output text)
echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile
echo $MASTER_ARN




