#!/bin/bash

# AWS NLB 서브넷 제거 스크립트 (설정 점검 기능 포함)
# 필요 패키지: aws-cli
# 실행 : chmod +x ./remove_nlb_subnet.sh

# 입력받기
read -p "Enter AWS NLB Name: " NLB_NAME

# NLB ARN 가져오기
NLB_ARN=$(aws elbv2 describe-load-balancers \
    --names "$NLB_NAME" \
    --query "LoadBalancers[0].LoadBalancerArn" \
    --output text)

if [ -z "$NLB_ARN" ]; then
    echo "Error: NLB not found."
    exit 1
fi

echo "NLB ARN: $NLB_ARN"

# 현재 서브넷 및 AZ 목록 조회
echo "Fetching current subnets and AZs for $NLB_NAME..."
SUBNET_INFO=$(aws elbv2 describe-load-balancers \
    --names "$NLB_NAME" \
    --query "LoadBalancers[0].AvailabilityZones[*].[SubnetId, ZoneName]" \
    --output text)

# 서브넷 정보 출력
echo "Current Subnets and AZs:"
echo "$SUBNET_INFO" | awk '{print "  - Subnet ID: " $1 ", Availability Zone: " $2}'

# 현재 서브넷 ID만 배열로 저장
SUBNET_IDS=($(echo "$SUBNET_INFO" | awk '{print $1}'))

# ✅ **Terminate connections on deregistration 설정 확인**
TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
    --query "TargetGroups[?LoadBalancerArns[?contains(@, '$NLB_ARN')]].TargetGroupArn" \
    --output text)

if [ -z "$TARGET_GROUP_ARN" ]; then
    echo "⚠️ Warning: No target groups found for this NLB."
else
    TERMINATE_ON_DEREG=$(aws elbv2 describe-target-groups \
        --target-group-arns "$TARGET_GROUP_ARN" \
        --query "TargetGroups[0].ConnectionTermination.Enabled" \
        --output text)

    if [ "$TERMINATE_ON_DEREG" == "True" ]; then
        echo "✅ Terminate connections on deregistration is ENABLED."
    else
        echo "⚠️ Warning: Terminate connections on deregistration is DISABLED. It is recommended to enable it before proceeding."
    fi
fi

# ✅ **Cross-Zone Load Balancing 설정 확인**
CROSS_ZONE_SETTING=$(aws elbv2 describe-load-balancer-attributes \
    --load-balancer-arn "$NLB_ARN" \
    --query "Attributes[?Key=='load_balancing.cross_zone.enabled'].Value" \
    --output text)

if [ "$CROSS_ZONE_SETTING" == "true" ]; then
    echo "⚠️ Warning: Cross-Zone Load Balancing is ENABLED. It is recommended to DISABLE it before proceeding."
else
    echo "✅ Cross-Zone Load Balancing is DISABLED."
fi

# ✅ **ARC Zonal Shift Integration 활성화 여부 확인**
ARC_INTEGRATION=$(aws elbv2 describe-load-balancer-attributes \
    --load-balancer-arn "$NLB_ARN" \
    --query "Attributes[?Key=='routing.http.desync_mitigation_mode'].Value" \
    --output text)

if [ "$ARC_INTEGRATION" == "enable" ]; then
    echo "✅ ARC Zonal Shift Integration is ENABLED."
else
    echo "⚠️ Warning: ARC Zonal Shift Integration is DISABLED. It is recommended to ENABLE it before proceeding."
fi

# ✅ **서브넷 삭제 안내 메시지**
echo -e "\n⚠️ **Recommended Actions Before Subnet Removal** ⚠️"
echo "---------------------------------------------"
echo "  ✅ Terminate connections on deregistration: ${TERMINATE_ON_DEREG:-UNKNOWN} (Recommended: ENABLED)"
echo "  ⚠️ Cross-Zone Load Balancing: $CROSS_ZONE_SETTING (Recommended: DISABLED)"
echo "  ⚠️ ARC Zonal Shift Integration: ${ARC_INTEGRATION:-UNKNOWN} (Recommended: ENABLED)"
echo "---------------------------------------------"
echo "❗ If any of the recommended settings are not configured properly, consider updating them before proceeding."
echo ""

# 서브넷 제거 여부 재확인
read -p "Do you still want to proceed with subnet removal? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborting subnet removal."
    exit 0
fi

# 제거할 서브넷 입력 받기
read -p "Enter the Subnet ID to remove: " REMOVE_SUBNET

# 제거할 서브넷이 목록에 있는지 확인
FOUND=false
for SUBNET in "${SUBNET_IDS[@]}"; do
    if [[ "$SUBNET" == "$REMOVE_SUBNET" ]]; then
        FOUND=true
        break
    fi
done

if [[ "$FOUND" == "false" ]]; then
    echo "Error: Specified subnet ($REMOVE_SUBNET) is not part of the NLB."
    exit 1
fi

# 남길 서브넷 목록 생성
NEW_SUBNETS=()
while IFS=$'\t' read -r SUBNET_ID AZ_NAME; do
    if [[ "$SUBNET_ID" != "$REMOVE_SUBNET" ]]; then
        NEW_SUBNETS+=("$SUBNET_ID")
    fi
done <<< "$SUBNET_INFO"

# 남길 서브넷이 최소 1개 이상인지 확인 (NLB는 최소 1개 AZ 필요)
if [ ${#NEW_SUBNETS[@]} -eq 0 ]; then
    echo "Error: Cannot remove the last subnet. At least one subnet is required."
    exit 1
fi

echo "Updating NLB with new subnet list: ${NEW_SUBNETS[*]}"

# AWS CLI를 사용하여 서브넷 업데이트 수행
aws elbv2 set-subnets \
    --load-balancer-arn "$NLB_ARN" \
    --subnets "${NEW_SUBNETS[@]}"

# 변경된 서브넷 확인
UPDATED_SUBNET_INFO=$(aws elbv2 describe-load-balancers \
    --names "$NLB_NAME" \
    --query "LoadBalancers[0].AvailabilityZones[*].[SubnetId, ZoneName]" \
    --output text)

echo "Updated Subnets and AZs:"
echo "$UPDATED_SUBNET_INFO" | awk '{print "  - Subnet ID: " $1 ", Availability Zone: " $2}'
echo "Subnet removal process completed successfully."
