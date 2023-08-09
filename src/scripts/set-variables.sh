#!/bin/bash

DATADOG_API_KEY=$(aws ssm get-parameters --names "secret.datadog.terraform_api_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --with-decryption --profile "$AWS_PROFILE")
echo "export DATADOG_API_KEY=$DATADOG_API_KEY" >> "$BASH_ENV"

DATADOG_APP_KEY=$(aws ssm get-parameters --names "secret.datadog.terraform_app_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --with-decryption --profile "$AWS_PROFILE")
echo "export DATADOG_APP_KEY=$DATADOG_APP_KEY" >> "$BASH_ENV"
