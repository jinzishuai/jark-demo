#!/bin/bash

export AWS_REGION=us-east-1
export AWS_DEFAULT_OUTPUT="table"

echo "list of EKS ..."
aws eks list-clusters

echo
echo "list of EFS ..."
aws efs describe-file-systems

echo
echo "list of jark* VPC ..."
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=jark*"

echo
echo "list of Karpenter IAM roles ..."
aws iam list-roles --query "Roles[?starts_with(RoleName,'Karpenter')]"


echo 
echo "list of jark alias KMS keys ..."
aws kms list-aliases --query 'Aliases[?contains(AliasName, `jark`)]'
# to delete the kms key: delete the alias and then set it for deletion pending at least 7 days.

echo 
echo "list of jark CloudWatch Logs log group ..."
aws logs describe-log-groups --query "logGroups[?contains(logGroupName, 'jark')]"

echo
echo "list of jark EBS volumes ..."
aws ec2 describe-volumes --filters "Name=tag:Name,Values=jark*"

echo
echo "list of all EC2 instances ..."
aws ec2 describe-instances --query "Reservations[].Instances[?State.Name!='terminated']"

echo
echo "list of all Elastic IPs ..."
aws ec2 describe-addresses

echo
echo "list of all Launch Templates ..."
aws ec2 describe-launch-templates
