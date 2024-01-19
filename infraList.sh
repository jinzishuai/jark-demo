#!/bin/bash

export AWS_REGION=us-east-1
export AWS_DEFAULT_OUTPUT="table"

echo "list of EKS ..."
aws eks list-clusters

echo
echo "list of EFS ..."
aws efs describe-file-systems

echo
echo "list of VPC ..."
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=jark*"

echo
echo "list of Karpenter IAM roles ..."
aws iam list-roles --query "Roles[?starts_with(RoleName,'Karpenter')]"
