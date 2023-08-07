#!/bin/bash

if [ -z "$DIR" ]
then
      echo "DIR is empty"
      exit 1
fi

cd "$DIR" || exit

if terraform plan -detailed-exitcode --out tfplan.binary;
then
    terraform show tfplan.binary
    echo "export DEPLOY_TF=true" >> "$BASH_ENV"
else
    echo "No changes detected."
fi


