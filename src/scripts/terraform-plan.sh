#!/bin/bash

if [ -z "$DIR" ]
then
      echo "DIR is empty"
      exit 1
fi

cd "$DIR" || exit

if terraform plan -detailed-exitcode --out /tmp/tfplan.binary;
then
    rm -rf /tmp/tfplan.binary
    echo "No changes detected."
    echo "false" > /tmp/tfplan.change
else
    echo "true" > /tmp/tfplan.change
    terraform show -json /tmp/tfplan.binary > /tmp/tfplan.json
fi



