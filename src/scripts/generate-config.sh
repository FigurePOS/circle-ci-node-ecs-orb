#!/bin/bash

if [ -z "$TF_WORKFLOW_GIT_REF" ]
then
      TF_WORKFLOW_GIT_REF="master"
fi

cat "$CONFIG_JSON_FILE"

if [ ! -f .circleci/app.yml ]; then
    echo "Config .circleci/app.yml not found"
    exit 1
fi

service_name=$(yq eval '.parameters.service_name' .circleci/app.yml)
if [ "$service_name" = "null" ]; then
    echo "Config .circleci/app.yml does not contain 'service_name' parameter"
    exit 1
fi

test_unit=$(yq eval '.jobs.test_unit' .circleci/app.yml)
if [ "$test_unit" = "null" ]; then
    echo "Config .circleci/app.yml does not contain 'test_unit' job"
    exit 1
fi

build=$(yq eval '.jobs.build' .circleci/app.yml)
if [ "$build" = "null" ]; then
    echo "Config .circleci/app.yml does not contain 'build' job"
    exit 1
fi

push=$(yq eval '.jobs.push' .circleci/app.yml)
if [ "$push" = "null" ]; then
    echo "Config .circleci/app.yml does not contain 'push' job"
    exit 1
fi

git clone --depth 1 --no-checkout --branch "$TF_WORKFLOW_GIT_REF" --single-branch git@github.com:FigurePOS/circle-ci-node-ecs-orb.git
cd circle-ci-node-ecs-orb || exit
git sparse-checkout set workflows
git checkout "$TF_WORKFLOW_GIT_REF"
cd ..

echo "version: 2.1" > /tmp/generated-config.yml
# shellcheck disable=SC2016
yq eval-all --inplace '. as $item ireduce ({}; . * $item )' /tmp/generated-config.yml circle-ci-node-ecs-orb/workflows/deploy.yml circle-ci-node-ecs-orb/workflows/jobs-tf.yml .circleci/app.yml

# Remove test_acceptance from workflow if not present in app.yml
test_acceptance=$(yq eval '.jobs.test_acceptance' .circleci/app.yml)
if [ "$test_acceptance" = "null" ]; then
    yq --inplace 'del(.workflows.cicd_app.jobs[] | select(has("test_acceptance")))' /tmp/generated-config.yml
    yq --inplace 'del(.workflows.cicd_app.jobs[] | select(has("push")) | .push.requires[] | select(. == "test_acceptance"))' /tmp/generated-config.yml
fi

# Remove test_e2e from workflow if not present in app.yml
test_e2e=$(yq eval '.jobs.test_e2e' .circleci/app.yml)
if [ "$test_e2e" = "null" ]; then
    yq --inplace 'del(.workflows.cicd_app.jobs[] | select(has("test_e2e")))' /tmp/generated-config.yml
    yq --inplace 'del(.workflows.cicd_app.jobs[] | select(has("push")) | .push.requires[] | select(. == "test_e2e"))' /tmp/generated-config.yml
fi

# Remove test_ui from workflow if not present in app.yml
test_ui=$(yq eval '.jobs.test_ui' .circleci/app.yml)
if [ "$test_ui" = "null" ]; then
    yq --inplace 'del(.workflows.cicd_app.jobs[] | select(has("test_ui")))' /tmp/generated-config.yml
    yq --inplace 'del(.workflows.cicd_app.jobs[] | select(has("push")) | .push.requires[] | select(. == "test_ui"))' /tmp/generated-config.yml
fi

lambda=$(jq -r '.lambda' "$CONFIG_JSON_FILE")
if [ "$lambda" == true ]; then
    echo "Lambda deployment triggered"
    if [ ! -f .circleci/serverless.yml ]; then
        echo "Config .circleci/serverless.yml not found"
        exit 1
    fi
    yq eval-all --inplace 'select(fileIndex == 0) * select(fileIndex == 1)' /tmp/generated-config.yml .circleci/serverless.yml
fi
