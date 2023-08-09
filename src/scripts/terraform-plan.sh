#!/bin/bash

if [ -z "$DIR" ]
then
      echo "DIR is empty"
      exit 1
fi

cd "$DIR" || exit

if terraform plan -detailed-exitcode --out /tmp/tfplan.binary;
then
    terraform show /tmp/tfplan.binary
else
    echo "No changes detected."
fi



