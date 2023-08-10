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

cd "$DIR" || exit

if [ -f /tmp/workspace/"$ENV"-tfplan.binary ] && [[ $(cat /tmp/workspace/"$ENV"-tfplan.change) == "true" ]];
then
    terraform apply --auto-approve /tmp/workspace/"$ENV"-tfplan.binary;
else
    echo "No plan found."
fi
