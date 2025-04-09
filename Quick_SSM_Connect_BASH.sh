#!/bin/bash

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

	# If blank, no instance found, grab new arg
	while [ -z "$INSTANCE_ID" ]
	do
		read -p "No Instance found with that name, try another: " -r NEW
		# Check again for blank entry
		if [ -n "$1" ]
		then
			INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Name,Values=*$NEW*" --query "Reservations[].Instances[].InstanceId[]" --output text)
		fi
	done

	# Check if multiple responses, if so offer them to choose one of the instance IDs. Allows for partial name entry.
	while [ ${#INSTANCE_ID}  -gt 20 ]
	do
		echo "---Multiple instances found with this name---"
		for i in $INSTANCE_ID
		do
			NAME=$(aws ec2 describe-instances --region "$REGION" --instance-id "$i" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" --output text)
			PRIV_IP=$(aws ec2 describe-instances --region "$REGION" --instance-id "$i" --query "Reservations[].Instances[].PrivateIpAddress[]" --output text)
			echo " $NAME | $PRIV_IP | $i"
		done
		read -p "Please choose one of the Instance IDs above for the session: " -r INSTANCE_ID
	done
fi

# Finalize connection choice and SSM connect
INSTANCE_NAME=$(aws ec2 describe-instances --region "$REGION" --instance-id "$INSTANCE_ID" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" --output text)
printf "Connecting to %s; %s" "$INSTANCE_NAME" "$INSTANCE_ID"
sleep 1

aws ssm start-session --region "$REGION" --target "$INSTANCE_ID"