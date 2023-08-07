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

terraform plan --out tfplan.binary
terraform show -json tfplan.binary > tfplan.json
if [ -f "tfplan.json" ]; then
    checkov -f tfplan.json --config-file "$CIRCLE_WORKING_DIRECTORY"/.checkov.terraform-plan.yaml
fi
