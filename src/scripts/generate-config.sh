#!/bin/bash

cat "$CONFIG_JSON_FILE"

echo "version: 2.1" > /tmp/generated-config.yml

lambda=$(jq -r '.lambda' "$CONFIG_JSON_FILE")
if [ "$lambda" == true ]; then
    echo "Lambda deployment triggered"
    if [ ! -f .circleci/serverless.yml ]; then
    echo "Config .circleci/serverless.yml not found"
    exit 1
    fi
    yq eval-all --inplace 'select(fileIndex == 0) * select(fileIndex == 1)' /tmp/generated-config.yml .circleci/serverless.yml
fi

tf=$(jq -r '.tf' "$CONFIG_JSON_FILE")
if [ "$tf" == true ]; then
    echo "Terraform deployment triggered"
    git clone --depth 1 --no-checkout git@github.com:FigurePOS/circle-ci-node-ecs-orb.git
    cd circle-ci-node-ecs-orb || exit
    git sparse-checkout set workflows
    git checkout v1.9.2
    cd ..
    yq eval-all --inplace 'select(fileIndex == 0) * select(fileIndex == 1)' /tmp/generated-config.yml circle-ci-node-ecs-orb/workflows/tf.yml
fi

yq eval-all --inplace 'select(fileIndex == 0) * select(fileIndex == 1)' /tmp/generated-config.yml .circleci/app.yml
