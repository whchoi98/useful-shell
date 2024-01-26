#!/bin/bash
aws iam create-user --user-name user01
aws iam create-login-profile --user-name user01 --password 1234Qwer --no-password-reset-required
aws iam attach-user-policy --user-name user01 --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-account-alias --account-alias testalias



