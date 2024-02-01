#!/bin/bash

if [ -z "$DIR" ]
then
      echo "DIR is empty"
      exit 1
fi

if [ -z "$ENV" ]
then
      echo "ENV is empty"
      exit 1
fi

if [ -z "$SCRIPT_SSH_TUNNEL" ]
then
      echo "SCRIPT_SSH_TUNNEL is empty"
      exit 1
fi

if [ -z "$TF_VAR_deployment_tag" ]
then
      TF_VAR_deployment_tag=${CIRCLE_SHA1:0:7}
fi

if [ -z "$TF_VAR_git_commit_hash" ]
then
      TF_VAR_git_commit_hash=$CIRCLE_SHA1
fi


eval "$SCRIPT_SSH_TUNNEL"

cd "$DIR" || exit

terraform apply --auto-approve
