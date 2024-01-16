#!/bin/bash

export CLUSTER_NAME="jark-stack"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_REGION="$(aws configure list | grep region | tr -s " " | cut -d" " -f3)"

# 6. tag subnets 

for NODEGROUP in $(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} \
    --query 'nodegroups' --output text); 
do 
    SUBNETS=$(aws eks describe-nodegroup --cluster-name ${CLUSTER_NAME} \
        --nodegroup-name $NODEGROUP --query 'nodegroup.subnets' --output text )
    aws ec2 create-tags \
        --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
        --resources ${SUBNETS}
    echo ${SUBNETS} are tagged.
done

# 7. tag NSGs (first nodegroup only)

NODEGROUP=$(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} \
    --query 'nodegroups[0]' --output text)

LAUNCH_TEMPLATE=$(aws eks describe-nodegroup --cluster-name ${CLUSTER_NAME} \
    --nodegroup-name ${NODEGROUP} --query 'nodegroup.launchTemplate.{id:id,version:version}' \
    --output text | tr -s "\t" ",")

# # If your EKS setup is configured to use only Cluster security group, then please execute -

# SECURITY_GROUPS=$(aws eks describe-cluster \
#     --name ${CLUSTER_NAME} --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

# If your setup uses the security groups in the Launch template of a managed node group, then :

SECURITY_GROUPS=$(aws ec2 describe-launch-template-versions \
    --launch-template-id ${LAUNCH_TEMPLATE%,*} --versions ${LAUNCH_TEMPLATE#*,} \
    --query 'LaunchTemplateVersions[0].LaunchTemplateData.[NetworkInterfaces[0].Groups||SecurityGroupIds]' \
    --output text)

aws ec2 create-tags \
    --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
    --resources ${SECURITY_GROUPS}

echo ${SECURITY_GROUPS} are tagged.
