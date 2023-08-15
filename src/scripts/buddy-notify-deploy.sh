#!/bin/bash

if [ -z "$CIRCLE_SHA1" ]
then
      echo "CIRCLE_SHA1 variable is empty"
      exit 1
fi

if [ -z "$CIRCLE_WORKFLOW_ID" ]
then
      echo "CIRCLE_WORKFLOW_ID variable is empty"
      exit 1
fi

if [ -z "$SERVICE_NAME" ]
then
      echo "SERVICE_NAME variable is empty"
      exit 1
fi

if [ -z "$FIGURE_BUDDY_TRIGGER_URL" ]
then
      echo "FIGURE_BUDDY_TRIGGER_URL variable is empty"
      exit 1
fi

# git message of current commit
commit_message=$(git log --oneline -n 1 "$CIRCLE_SHA1")

curl \
    -X POST \
    -H "Content-type: application/json" \
    --data "{\"type\":\"dev-deployed\",\"service_name\":\"$SERVICE_NAME\",\"commit_message\":\"$commit_message\",\"workflow_id\":\"$CIRCLE_WORKFLOW_ID\"}" \
    "$FIGURE_BUDDY_TRIGGER_URL"

echo "SUCCESS"
