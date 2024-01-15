#!/bin/bash

# Modify to specific environments
security_group_id=sg-01b28c264239d0c4b
file_system_id=fs-0a5a7ce050d7a9113

export AWS_REGION="us-east-1"
export AWS_PAGER=""
SUBNET1=subnet-0dc5e021305ce88a0
SUBNET2=subnet-046b7d42820bc51bc
# repeat for each subnet

aws efs create-mount-target \
    --file-system-id $file_system_id \
    --subnet-id $SUBNET1 \
    --security-groups $security_group_id

aws efs create-mount-target \
    --file-system-id $file_system_id \
    --subnet-id $SUBNET2 \
    --security-groups $security_group_id
