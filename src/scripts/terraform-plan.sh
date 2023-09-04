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

if terraform plan -detailed-exitcode --out /tmp/"$ENV"-tfplan.binary;
then
    rm -rf /tmp/"$ENV"-tfplan.binary
    echo "No changes detected."
else
    if $? -eq 2;
    then
        echo "Error running terraform plan"
        exit 1
    fi
    terraform show -json /tmp/"$ENV"-tfplan.binary > /tmp/"$ENV"-tfplan.json
fi



