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

eval "$SCRIPT_SSH_TUNNEL"

cd "$DIR" || exit

terraform apply --auto-approve
