#!/bin/bash

DATADOG_API_KEY=$(aws ssm get-parameters --names "secret.datadog.terraform_api_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --with-decryption --profile "$AWS_PROFILE")
export DATADOG_API_KEY

DATADOG_APP_KEY=$(aws ssm get-parameters --names "secret.datadog.terraform_app_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --with-decryption --profile "$AWS_PROFILE")
export DATADOG_APP_KEY

export TF_VAR_aws_profile=$AWS_PROFILE
export TF_VAR_env=$ENV
