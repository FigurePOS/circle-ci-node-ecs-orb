#!/bin/bash

DATADOG_API_KEY=$(aws ssm get-parameters --names "secret.datadog.terraform_api_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --with-decryption --profile "$AWS_PROFILE")
echo "export DATADOG_API_KEY=$DATADOG_API_KEY" >> "$BASH_ENV"

DATADOG_APP_KEY=$(aws ssm get-parameters --names "secret.datadog.terraform_app_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --with-decryption --profile "$AWS_PROFILE")
echo "export DATADOG_APP_KEY=$DATADOG_APP_KEY" >> "$BASH_ENV"

if [ -n "$EXPORT_TIMESCALE_CREDENTIALS" ]; then
    TF_VAR_timescale_project_id=$(aws ssm get-parameters --names "timescale_project_id" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --profile "$AWS_PROFILE")
    echo "export TF_VAR_timescale_project_id=$TF_VAR_timescale_project_id" >> "$BASH_ENV"

    TF_VAR_timescale_public_key=$(aws ssm get-parameters --names "timescale_public_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --profile "$AWS_PROFILE")
    echo "export TF_VAR_timescale_public_key=$TF_VAR_timescale_public_key" >> "$BASH_ENV"

    TF_VAR_timescale_secret_key=$(aws ssm get-parameters --names "timescale_secret_key" --region="$AWS_REGION" --query 'Parameters[].Value' --output text --with-decryption --profile "$AWS_PROFILE")
    echo "export TF_VAR_timescale_secret_key=$TF_VAR_timescale_secret_key" >> "$BASH_ENV"
fi
