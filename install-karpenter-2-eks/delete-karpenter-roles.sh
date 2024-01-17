#!/bin/bash

export KARPENTER_VERSION=v0.33.0
export K8S_VERSION=1.28

export AWS_PARTITION="aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
export CLUSTER_NAME="jark-stack"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_REGION="$(aws configure list | grep region | tr -s " " | cut -d" " -f3)"
# might need to set AWS_PROFILE
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"


# step 0: delete the two IAM roles so that they can be created cleanly in following steps
# Need to first
# - detach managed policies
# - delete inline policies
# - delete instance profile
echo "step 0: delete IAM roles KarpenterNodeRole-${CLUSTER_NAME} and KarpenterControllerRole-${CLUSTER_NAME}"

set -x
aws iam remove-role-from-instance-profile \
    --instance-profile-name KarpenterNodeInstanceProfile-${CLUSTER_NAME} \
    --role-name KarpenterNodeRole-${CLUSTER_NAME}
aws iam delete-instance-profile --instance-profile-name KarpenterNodeInstanceProfile-${CLUSTER_NAME}
aws iam delete-role --role-name KarpenterNodeRole-${CLUSTER_NAME}

aws iam delete-role --role-name KarpenterControllerRole-${CLUSTER_NAME}
set +x
