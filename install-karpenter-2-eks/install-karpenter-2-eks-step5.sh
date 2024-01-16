#!/bin/bash

set -x
helm upgrade --install karpenter-crd oci://public.ecr.aws/karpenter/karpenter-crd \
  --version v0.33.0 --namespace karpenter --create-namespace

kubectl apply -f karpenter.yaml 

set +x
