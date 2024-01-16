#!/bin/bash
# ref: https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/#5-create-nodepool

export CLUSTER_NAME="jark-stack"

cat <<EOF | envsubst | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: gpu
spec:
  template:
    spec:
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["g5.xlarge", "g5.2xlarge", "g5.4xlarge", "g5.8xlarge", "g5.12xlarge"]
      nodeClassRef:
        name: gpu
      # Provisioned nodes will have these taints
      # Taints may prevent pods from scheduling if they are not tolerated by the pod.
      taints:
        - key: nvidia.com/gpu
          effect: NoSchedule
  limits:
    cpu: 1000
    nvidia.com/gpu: 16
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h # 30 * 24h = 720h
---
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: gpu
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: "KarpenterNodeRole-${CLUSTER_NAME}" # replace with your cluster name
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}" # replace with your cluster name
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}" # replace with your cluster name
  tags:                  
    "karpenter.sh/noodpool": gpu
  # Optional, configures storage devices for the instance
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 100Gi
        volumeType: gp3
EOF
