#!/bin/bash -x
#to be run on my laptop


KEY_ID=sst-aws
# Select an Amazon Linux AMI ID from https://aws.amazon.com/amazon-linux-ami/
# As of 2015-09-16, the current Amazon Linux AMI 2015.03.1
# The install script assumes an instance type of 't2.micro', so you should select an HVM AMI

AMI_ID=ami-d44b4286 #must be adapted to your region
SEC_ID=VPN
BOOTSTRAP_SCRIPT=vpn-ec2-install.sh 

echo "Starting Instance..."
INSTANCE_DETAILS=`aws ec2 run-instances --image-id $AMI_ID --key-name $KEY_ID --security-groups $SEC_ID --instance-type t2.micro --user-data file://./$BOOTSTRAP_SCRIPT --output text | grep INSTANCES`

INSTANCE_ID=`echo $INSTANCE_DETAILS | awk '{print $7}'`
echo $INSTANCE_ID > $HOME/vpn-ec2.id 

# wait for instance to be started
STATUS=`aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --output text | grep INSTANCESTATUS | grep -v INSTANCESTATUSES | awk '{print $2}'`

while [ "$STATUS" != "ok" ]
do
    echo "Waiting for instance to start...."
    sleep 5
    STATUS=`aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --output text | grep INSTANCESTATUS | grep -v INSTANCESTATUSES | awk '{print $2}'`
done

echo "Instance started"

echo "Instance ID = " $INSTANCE_ID
DNS_NAME=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text | grep INSTANCES | awk '{print $13}'`
AVAILABILITY_ZONE=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text | grep PLACEMENT | awk '{print $2}'`
echo "DNS = " $DNS_NAME " in availability zone " $AVAILABILITY_ZONE


