#!/bin/bash

if [ -z "$DIR" ]
then
      echo "DIR is empty"
      exit 1
fi

if [ -z "$CIRCLE_WORKING_DIRECTORY" ]
then
      echo "CIRCLE_WORKING_DIRECTORY is empty"
      exit 1
fi

cd "$DIR" || exit

if [ -f /tmp/tfplan.binary/tfplan.binary ]; then
    checkov -f /tmp/tfplan.binary/tfplan.binary --config-file "$CIRCLE_WORKING_DIRECTORY"/.checkov.terraform-plan.yaml
else
    echo "No changes in the plan."
fi
