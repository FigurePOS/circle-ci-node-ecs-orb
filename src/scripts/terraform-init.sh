#!/bin/bash
set -e

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

if [ -z "$BUCKET_NAME" ]
then
      BUCKET_NAME="figure-application-$ENV"
fi

eval "$SCRIPT_ASSUME"

eval "$SCRIPT_SET_VARS"

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

cd "$DIR" || exit

terraform get
terraform init -reconfigure \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="profile=assumed-role"
