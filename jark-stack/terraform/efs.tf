locals {
  secondar_pravate_subnet_ids = slice(module.vpc.private_subnets, length(local.private_subnets), length(module.vpc.private_subnets))

  #   // Alternative method
  #   // Assuming the subnets in `private_subnets` are created in the order they're defined and the
  #   // VPC module lists the subnet IDs in the same order, you can use the following calculation
  #   // based on the length of the `private_subnets` local which is your primary subnets.
  #   secondary_private_subnet_ids = tolist([
  #     for index in range(length(local.private_subnets), length(module.vpc.private_subnets)) : 
  #       module.vpc.private_subnets[index]
  #   ])
}
module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.4.0"

  name      = local.name
  encrypted = false

  # Mount targets
  # Use `for_each` to create a mount target for each private subnet ID
  mount_targets = { for idx, subnet_id in local.secondar_pravate_subnet_ids : idx => {
    subnet_id = subnet_id
  } }

  # Create security group
  create_security_group      = true
  security_group_description = "EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    egress_all = {
      description = "Allow all egress"
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_efs = {
      description = "NFS ingress from VPC private subnets"
      type        = "ingress"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = var.secondary_cidr_blocks
    }
  }
}
