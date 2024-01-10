#!/bin/bash
set -e

if [ -z "$AWS_REGION" ]
then
      echo "AWS_REGION is empty"
      exit 1
fi

if [ -z "$BUCKET_NAME" ]
then
      BUCKET_NAME="figure-application-$ENV"
fi

if [ -z "$DIR" ]
then
      echo "DIR is empty"
      exit 1
fi

if [ -z "$SCRIPT_ASSUME" ]
then
      echo "SCRIPT_ASSUME is empty"
      exit 1
fi

if [ -z "$SCRIPT_SET_VARS" ]
then
      echo "SCRIPT_SET_VARS is empty"
      exit 1
fi

if [ -z "$SERVICE_NAME" ]
then
     echo "SERVICE_NAME is empty"
      exit 1
fi

eval "$SCRIPT_ASSUME"

eval "$SCRIPT_SET_VARS"

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

cd "$DIR" || exit

echo "Initializing terraform"
echo " - key: $SERVICE_NAME/terraform.tfstate"
echo " - bucket: $BUCKET_NAME"
echo " - region: $AWS_REGION"
echo " - profile: aassumed-role"

terraform get
terraform init -reconfigure \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="key=$SERVICE_NAME/terraform.tfstate" \
    -backend-config="region=$AWS_REGION" \
    -backend-config="profile=assumed-role"
