# jark-demo

JARK means: 
- [JupyterHub](https://jupyter.org/hub)
- [Argo Workflows](https://argo-workflows.readthedocs.io/en/latest/)
- [Ray](https://www.ray.io/)
- [Kubernetes](https://kubernetes.io/)

This is the code repo for my blog post series on "JARK Stack for Generative AI": 

- [Part 1: Introduction](https://medium.com/@shijin_35411/jark-stack-for-generative-ai-part-1-db5c5be82543)
- [Part 2: Build the JARK Stack with Terraform](https://medium.com/@shijin_35411/jark-stack-for-generative-ai-part-2-7270e2cf886e)
- [Part 3: Autoscaling with Karpenter](https://medium.com/@shijin_35411/jark-stack-for-generative-ai-part-3-255f1d441c18)
- [Part 4: Parallel Computing with KubeRay](https://medium.com/@shijin_35411/jark-stack-for-generative-ai-part-4-d2343eb9ed77)
- [Part 5: Generative AI on JARK](https://medium.com/@shijin_35411/jark-stack-for-generative-ai-part-5-684250e1560b)
- [Part 6: Scalable Model Inference](https://medium.com/@shijin_35411/jark-stack-for-generative-ai-part-6-cf9683b88869)

## code structure

- [jark-stack](./jark-stack/): the original code comes from the [AWS Data-On-EKS project/ai-ml/jark-stack](https://github.com/awslabs/data-on-eks/tree/main/ai-ml/jark-stack). Commit SHA [161339ed31810c315b5d7e5bf4c0aee883ef78cf](https://github.com/awslabs/data-on-eks/commit/161339ed31810c315b5d7e5bf4c0aee883ef78cf)
- [05_dreambooth_finetuning](./05_dreambooth_finetuning/): the original code comes from the [Ray project/doc/source/templates/05_dreambooth_finetuning](https://github.com/ray-project/ray/tree/master/doc/source/templates/05_dreambooth_finetuning). Commit SHA [aa396f904cc3c12de0f2a83a1d70381169f47a57](https://github.com/ray-project/ray/commit/aa396f904cc3c12de0f2a83a1d70381169f47a57).
