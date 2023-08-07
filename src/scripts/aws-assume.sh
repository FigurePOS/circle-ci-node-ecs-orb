#!/bin/bash
set -e

if [ -z "$ACCOUNT_ID" ]
then
      echo "ACCOUNT_ID variable is empty"
      exit 1
fi

if [ -z "$ROLE_NAME" ]
then
      echo "ROLE_NAME variable is empty"
      exit 1
fi

if [ -z "$DURATION" ]
then
      DURATION=3600
fi

AWS_PROFILE=assumed-role
AWS_USERNAME=$(aws sts get-caller-identity | jq .Arn | xargs | sed 's/^.*\///')

temp_role=$(aws sts assume-role --duration-seconds "$DURATION" --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}" --role-session-name "${AWS_USERNAME}-$(date +%F-%H-%M-%S)-session")

AWS_ACCESS_KEY_ID=$(echo "$temp_role" | jq .Credentials.AccessKeyId | xargs)
AWS_SECRET_ACCESS_KEY=$(echo "$temp_role" | jq .Credentials.SecretAccessKey | xargs)
AWS_SESSION_TOKEN=$(echo "$temp_role" | jq .Credentials.SessionToken | xargs)

AWS_REGION=us-east-1

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile $AWS_PROFILE
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile $AWS_PROFILE
aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile $AWS_PROFILE
aws configure set region $AWS_REGION --profile $AWS_PROFILE

# TODO exported for the terraform s3 backend provider -- there seems to be some bug in using profiles
export AWS_PROFILE
export AWS_REGION
export AWS_USERNAME
export AWS_PAGER=""

echo "AWS Role Assumption has completed successfully"
aws sts get-caller-identity --profile $AWS_PROFILE
