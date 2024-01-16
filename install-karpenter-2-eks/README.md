# Install Karpenter 0.33.0 on an Existing EKS-1.27

Following https://medium.com/@shadracktanui47/setup-karpenter-on-your-existing-eks-cluster-98bf6e959863

1. Run script `./install-karpenter-2-eks-step1.sh` to prepare
2. Update `aws-auth` config map to have
```yaml
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: <Paste the KarpenterNodeRole full ARN here>
  username: system:node:{{EC2PrivateDNSName}}
```
4. Geneatte Karpenter Helm template: `./install-karpenter-2-eks-step3.sh`: it will generate `karpenter.yaml`
5. Modify helm chart genearated manifest file `karpenter.yaml` to have
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: karpenter.sh/provisioner-name
          operator: DoesNotExist
      - matchExpressions:
        - key: eks.amazonaws.com/nodegroup
          operator: In
          values:
          - ${NODEGROUP}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"
```
6. Install Karpenter CRDs

https://gallery.ecr.aws/karpenter/karpenter-crd

```
╭─   ~/s/j/personal-repo/Cloud Computing/aws/Karpenter/install-karpenter-2-eks   master !1 ?20 ················································ ⎈ jark-stack  14:39:03
╰─❯ helm upgrade --install karpenter-crd oci://public.ecr.aws/karpenter/karpenter-crd --version v0.33.0 --namespace karpenter --create-namespace

Release "karpenter-crd" does not exist. Installing it now.
Pulled: public.ecr.aws/karpenter/karpenter-crd:v0.33.0
Digest: sha256:7d33c9d8175df7c2faabc6c5a50e211f8a90c9efdf0a8e92cc60eb221363368f
NAME: karpenter-crd
LAST DEPLOYED: Fri Dec  8 14:39:45 2023
NAMESPACE: karpenter
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

7. Install Helm Chart
   
```
╭─   ~/s/j/personal-repo/Cloud Computing/aws/Karpenter/install-karpenter-2-eks   master !1 ?20 ················································ ⎈ jark-stack  14:41:05
╰─❯ kubectl apply -f karpenter.yaml 
poddisruptionbudget.policy/karpenter created
serviceaccount/karpenter created
clusterrole.rbac.authorization.k8s.io/karpenter-admin created
clusterrole.rbac.authorization.k8s.io/karpenter-core created
clusterrole.rbac.authorization.k8s.io/karpenter created
clusterrolebinding.rbac.authorization.k8s.io/karpenter-core created
clusterrolebinding.rbac.authorization.k8s.io/karpenter created
role.rbac.authorization.k8s.io/karpenter created
role.rbac.authorization.k8s.io/karpenter-dns created
role.rbac.authorization.k8s.io/karpenter-lease created
rolebinding.rbac.authorization.k8s.io/karpenter created
rolebinding.rbac.authorization.k8s.io/karpenter-dns created
rolebinding.rbac.authorization.k8s.io/karpenter-lease created
service/karpenter created
deployment.apps/karpenter created

```

8. Note that starting from v0.32, `v1beta1` API is introduced, there are major changes
-  [Provisioner -> NodePool](https://karpenter.sh/preview/upgrading/v1beta1-migration/#provisioner---nodepool)
-  [AWSNodeTemplate -> EC2NodeClass](https://karpenter.sh/preview/upgrading/v1beta1-migration/#awsnodetemplate---ec2nodeclass)

# Using Karpenter

## Define the Default NodePool and EC2NodeClass

https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/#5-create-nodepool

```
╰─❯ ./install-node-pool-default.sh 
nodepool.karpenter.sh/default created
ec2nodeclass.karpenter.k8s.aws/default created
```
