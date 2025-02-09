#!/bin/bash

# IAM 사용자 이름 유효성 검사 함수
validate_username() {
  local username="$1"
  if [[ ! "$username" =~ ^[a-zA-Z0-9+=,.@_-]{1,64}$ ]]; then
    echo "❌ 오류: 사용자 이름은 1~64자의 영문자, 숫자, 특수문자(+=,.@_-)만 포함할 수 있습니다."
    exit 1
  fi
}

# AWS 계정 별칭 고유성 검사 함수
check_account_alias() {
  local alias="$1"
  if aws iam list-account-aliases --query "AccountAliases[]" --output text | grep -wq "$alias"; then
    echo "⚠️  경고: '${alias}' 별칭이 이미 존재합니다. 다른 별칭을 입력하세요."
    exit 1
  fi
}

# 사용자 입력 받기
read -p "🆔 생성할 IAM 사용자 이름을 입력하세요: " USER_NAME
validate_username "$USER_NAME"  # 사용자 이름 검증

read -s -p "🔑 설정할 비밀번호를 입력하세요: " PASS_WORD
echo ""  # 줄바꿈

read -p "🏷️  설정할 AWS 계정 별칭을 입력하세요: " ACCOUNT_ALIAS
check_account_alias "$ACCOUNT_ALIAS"  # 계정 별칭 중복 확인

# AWS IAM 사용자 생성
echo "🚀 IAM 사용자 생성 중: ${USER_NAME}"
aws iam create-user --user-name "${USER_NAME}"

# AWS IAM 로그인 프로필 생성 (비밀번호 설정)
echo "🔐 로그인 프로필 생성 (비밀번호 설정)"
aws iam create-login-profile --user-name "${USER_NAME}" --password "${PASS_WORD}" --no-password-reset-required

# AdministratorAccess 정책 부여
echo "📜 관리자 권한 부여"
aws iam attach-user-policy --user-name "${USER_NAME}" --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# 계정 별칭 생성
echo "🏷️  계정 별칭 설정: ${ACCOUNT_ALIAS}"
aws iam create-account-alias --account-alias "${ACCOUNT_ALIAS}"

echo "✅ AWS IAM 사용자 '${USER_NAME}'가 성공적으로 생성되었습니다."
echo "🌐 AWS 계정 별칭: ${ACCOUNT_ALIAS}"
