#!/bin/bash

export KARPENTER_VERSION=v0.33.0
export K8S_VERSION=1.28

export AWS_PARTITION="aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
export CLUSTER_NAME="jark-stack"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"


# ref: https://gallery.ecr.aws/karpenter/karpenter

docker logout public.ecr.aws
# Generate Karpenter Helm Template
set -x
helm template karpenter oci://public.ecr.aws/karpenter/karpenter --version ${KARPENTER_VERSION} --namespace karpenter \
    --set settings.clusterName=${CLUSTER_NAME} \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
    --set controller.resources.requests.cpu=1 \
    --set controller.resources.requests.memory=1Gi \
    --set controller.resources.limits.cpu=1 \
    --set controller.resources.limits.memory=1Gi > karpenter.yaml
set +x
