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

      BASTION_URL=$(aws ssm get-parameters --names "bastion_endpoint" --region=us-east-1 --query 'Parameters[].Value' --output text --profile assumed-role)
      SSH_CMD="$SSH_CMD ec2-user@$BASTION_URL"

      echo "Running $SSH_CMD"
      $SSH_CMD &
      sleep 1
else
      echo "DB_TUNNEL_MAPPING is empty, no tunnel created."
fi
