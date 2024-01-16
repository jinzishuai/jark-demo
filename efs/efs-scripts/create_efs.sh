#!/bin/bash

# Change to your specific values
export AWS_REGION="us-east-1"
export AWS_PAGER=""
VPC_ID=vpc-0f654efe5f673ff9c
CIDR_RANGE="100.64.0.0/16" # second VPC block used used by EKS nodes


security_group_id=$(aws ec2 create-security-group \
    --group-name JarkDemo-EfsSecurityGroup \
    --description "EFS security group" \
    --vpc-id $VPC_ID \
    --output text)

aws ec2 authorize-security-group-ingress \
    --group-id $security_group_id \
    --protocol tcp \
    --port 2049 \
    --cidr $CIDR_RANGE >/dev/null

file_system_id=$(aws efs create-file-system \
    --region $AWS_REGION \
    --performance-mode generalPurpose \
    --query 'FileSystemId' \
    --output text)

echo "security_group_id=$security_group_id"
echo "file_system_id=$file_system_id"
