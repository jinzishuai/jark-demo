# Install Karpenter 0.33.0 on an Existing EKS-1.28

Following https://medium.com/@shadracktanui47/setup-karpenter-on-your-existing-eks-cluster-98bf6e959863

1. Run script `./install-karpenter-2-eks-step1.sh` to prepare
2. Update `aws-auth` config map to insert the following to the `data.mapRoles` field:
```yaml
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: <Paste the KarpenterNodeRole full ARN here>
      username: system:node:{{EC2PrivateDNSName}}
```
3. Geneatte Karpenter Helm template: `./install-karpenter-2-eks-step3.sh`: it will generate `karpenter.yaml`
4. Modify helm chart genearated manifest file `karpenter.yaml` to have the affinity for the `karpenter` deployment. Modify the `spec.template.spec.affinity` section to be:
```yaml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: karpenter.sh/nodepool
                operator: DoesNotExist
            # Begin of Insert
            - matchExpressions:
              - key: eks.amazonaws.com/nodegroup
                operator: In
                values:
                - core-node-group-2024011516012728040000000f
            # End of Insert
        podAntiAffinity:
```
Note that the value of `core-node-group-2024011516012728040000000f` comes from the existing core node groups of the EKS cluster. The we only need to insert the section between comments.

5. Run the last script: `./install-karpenter-2-eks-step5.sh`: this finishes the installation.

# Using Karpenter

## Define the Default NodePool and EC2NodeClass for CPU instances

https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/#5-create-nodepool

```
╰─❯ ./install-node-pool-default.sh 
nodepool.karpenter.sh/default created
ec2nodeclass.karpenter.k8s.aws/default created
```

## Define the Default NodePool and EC2NodeClass for GPU instances

```
╰─❯ ./install-node-pool-gpu.sh    
nodepool.karpenter.sh/gpu created
ec2nodeclass.karpenter.k8s.aws/gpu created
```
