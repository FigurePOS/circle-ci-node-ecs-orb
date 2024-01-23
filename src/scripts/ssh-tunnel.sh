#!/bin/bash

if [ -n "$DB_TUNNEL_MAPPING" ]
then
      SSH_CMD="ssh -v -4 -N -o StrictHostKeyChecking=no"

      # $DB_TUNNEL_MAPPING has form of "port1:param1:port2:param2"
      IFS=',' read -ra MAPPING <<< "$DB_TUNNEL_MAPPING"
      for i in "${MAPPING[@]}"; do
            IFS=':' read -ra PARTS <<< "$i"
            PORT=${PARTS[0]}
            PARAM=${i#"$PORT":}

            URL=$(aws ssm get-parameters --names "$PARAM" --region=us-east-1 --query 'Parameters[].Value' --output text --profile assumed-role)
            # shellcheck disable=SC2181
            if [ $? -ne 0 ]; then
                  echo "Error getting parameter $PARAM"
                  exit 1
            fi

            SSH_CMD="$SSH_CMD -L $PORT:$URL:5432"
      done

      INSTANCE_ID=$(aws ec2 describe-instances --filter "Name=tag:Connection,Values=Bastion" --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[] | [0]" --profile assumed-role --output text)

      echo "Running: $SSH_CMD -o ProxyCommand=\"aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartSSHSession --parameters portNumber=22 --profile assumed-role\" ec2-user@bastion"

      $SSH_CMD -o ProxyCommand="aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartSSHSession --parameters portNumber=22 --profile assumed-role" ec2-user@bastion &
      sleep 1
else
      echo "DB_TUNNEL_MAPPING is empty, no tunnel created."
fi
