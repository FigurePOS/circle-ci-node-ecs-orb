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

if terraform plan -detailed-exitcode --out /tmp/"$ENV"-tfplan.binary;
then
    rm -rf /tmp/"$ENV"-tfplan.binary
    echo "No changes detected."
else
    terraform show -json /tmp/"$ENV"-tfplan.binary > /tmp/"$ENV"-tfplan.json
fi



