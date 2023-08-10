#!/bin/bash

if [ -z "$CHECKOV_CONFIG" ]
then
      echo "CHECKOV_CONFIG variable is empty"
      exit 1
fi

if [ -z "$DIR" ]
then
      echo "DIR variable is empty"
      exit 1
fi

if [ -z "$ENV" ]
then
      echo "ENV variable is empty"
      exit 1
fi

cd "$DIR" || exit

if [ -f /tmp/workspace/"$ENV"-tfplan.binary ] && [[ $(cat /tmp/workspace/"$ENV"-tfplan.change) == "true" ]];
then
    terraform show -json /tmp/workspace/"$ENV"-tfplan.binary > tfplan.json
    echo "$CHECKOV_CONFIG" > .checkov.yml
    checkov -f tfplan.json --config-file .checkov.yml
else
    echo "No changes in the plan."
fi
