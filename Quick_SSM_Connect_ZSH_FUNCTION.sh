qssm() {
  # Set the region here, or pass as second argument
  REGION="us-east-1"
  if [[ -z "$2" ]]; then
    set -- "$1" "$REGION"
  fi

  # First check if an instance ID was passed, and just connect with this skipping rest of script
  if [[ $1 = i-* ]]
  then
    INSTANCE_ID=$1
  else
    # Query by name, $1 will be the name of the instance to SSM connect to. First check if no arg provided
    if [ -n "$1" ]
    then
      INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Name,Values=*$1*" --query "Reservations[].Instances[].InstanceId[]" --output text)
    fi

    # If blank, no instance found, end the function
    if [[ -z "$INSTANCE_ID" ]]; then
      echo "No Instance found with that name"
      return 1
    fi

    # Check if multiple responses for instance IDs, allows for partial name entry, return
    if [[ ${#INSTANCE_ID}  -gt 20 ]]; then
      echo "---Multiple instances found with this name---"
      for i in $INSTANCE_ID
      do
        NAME=$(aws ec2 describe-instances --region "$REGION" --instance-id "$i" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" --output text)
        PRIV_IP=$(aws ec2 describe-instances --region "$REGION" --instance-id "$i" --query "Reservations[].Instances[].PrivateIpAddress[]" --output text)
        echo " $NAME | $PRIV_IP | $i"
      done
      echo "Please choose one of the Instance IDs above for the session and rerun the command"
      return 1
    fi
  fi

  # Finalize connection choice and SSM connect
  INSTANCE_NAME=$(aws ec2 describe-instances --region "$REGION" --instance-id "$INSTANCE_ID" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" --output text)
  printf "Connecting to %s; %s" "$INSTANCE_NAME" "$INSTANCE_ID"
  sleep 1

  aws ssm start-session --region "$REGION" --target "$INSTANCE_ID"
}