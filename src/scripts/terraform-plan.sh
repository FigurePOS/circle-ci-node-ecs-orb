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

if [ -z "$SCRIPT_SSH_TUNNEL" ]
then
      echo "SCRIPT_SSH_TUNNEL is empty"
      exit 1
fi

if [ -z "$TF_VAR_deployment_tag" ]
then
      TF_VAR_deployment_tag=${CIRCLE_SHA1:0:7}
fi

if [ -z "$TF_VAR_git_commit_hash" ]
then
      TF_VAR_git_commit_hash=$CIRCLE_SHA1
fi


eval "$SCRIPT_SSH_TUNNEL"

cd "$DIR" || exit

if terraform plan -detailed-exitcode --out /tmp/"$ENV"-tfplan.binary;
then
    rm -rf /tmp/"$ENV"-tfplan.binary
    echo "No changes detected."
    echo "No changes detected." > /tmp/"$ENV"-plan.txt
else
    if [ $? -eq 1 ]
    then
        echo "Error running terraform plan"
        exit 1
    fi
    terraform show -no-color /tmp/"$ENV"-tfplan.binary > /tmp/"$ENV"-plan.txt
fi

export CIRCLE_PR_NUMBER=${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}
if [ -z "$CIRCLE_PR_NUMBER" ]; then echo "Not a pull request - aborting"; exit 0; fi

COMMENT_TPL="Output from **${ENV}** \`terraform plan\`\n\`\`\`\n{{.}}\n\`\`\`"

github-commenter \
    -owner "${CIRCLE_PROJECT_USERNAME}" \
    -repo "${CIRCLE_PROJECT_REPONAME}" \
    -number "$CIRCLE_PR_NUMBER" \
    -delete-comment-regex "Output from \*\*${ENV}\*\*" \
    -type pr \
    -template "$COMMENT_TPL" < /tmp/"$ENV"-plan.txt



