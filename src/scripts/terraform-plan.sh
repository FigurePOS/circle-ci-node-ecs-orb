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
    echo -n "No changes detected." > /tmp/"$ENV"-plan.txt
    COMMENT_TPL=$(cat <<EOF
Output from **${ENV}** \`terraform plan\`:
\`\`\`
{{.}}
\`\`\`
EOF
)
else
    if [ $? -eq 1 ]
    then
        echo "Error running terraform plan"
        exit 1
    fi
    terraform show -no-color /tmp/"$ENV"-tfplan.binary > /tmp/"$ENV"-plan.txt

    COMMENT_TPL=$(cat <<EOF
Output from **${ENV}** \`terraform plan\`:

<details>

<summary>$(grep "Plan: " /tmp/"${ENV}"-plan.txt)</summary>

\`\`\`
{{.}}
\`\`\`

</details>
EOF
)
fi

export CIRCLE_PR_NUMBER=${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}
if [ -z "$CIRCLE_PR_NUMBER" ]; then echo "Not a pull request - aborting"; exit 0; fi

if [ "$(stat -c%s /tmp/"$ENV"-plan.txt)" -gt 50000 ]; then
      echo "Output is too large, truncating..."
      head -c 50000 /tmp/"$ENV"-plan.txt > /tmp/"$ENV"-plan.txt.tmp
      mv /tmp/"$ENV"-plan.txt.tmp /tmp/"$ENV"-plan.txt
fi

github-commenter \
    -owner "${CIRCLE_PROJECT_USERNAME}" \
    -repo "${CIRCLE_PROJECT_REPONAME}" \
    -number "$CIRCLE_PR_NUMBER" \
    -edit-comment-regex "Output from \*\*${ENV}\*\* \`terraform plan\`" \
    -type pr \
    -template "$COMMENT_TPL" < /tmp/"$ENV"-plan.txt



