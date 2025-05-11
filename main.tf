provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

locals {
  cluster_name = "${var.project_name}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  cidr_block   = var.vpc_cidr
  azs          = var.availability_zones

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment == "dev" ? true : false
  one_nat_gateway_per_az = var.environment == "prod" ? true : false

  tags = local.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # Security groups
  cluster_security_group_additional_rules = {
    bastion_access = {
      description              = "Bastion host access to EKS API"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      source_security_group_id = module.bastion.security_group_id
      type                     = "ingress"
    }
  }

  # Node groups
  eks_managed_node_groups = {
    system = {
      name            = "system"
      use_name_prefix = true

      subnet_ids = module.vpc.private_subnets

      min_size     = var.system_node_group_min_size
      max_size     = var.system_node_group_max_size
      desired_size = var.system_node_group_desired_size

      instance_types = var.system_node_group_instance_types
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "system"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "system"
          effect = "NO_SCHEDULE"
        }
      ]

      update_config = {
        max_unavailable_percentage = 33
      }

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      tags = local.tags
    }

    application = {
      name            = "application"
      use_name_prefix = true

      subnet_ids = module.vpc.private_subnets

      min_size     = var.app_node_group_min_size
      max_size     = var.app_node_group_max_size
      desired_size = var.app_node_group_desired_size

      instance_types = var.app_node_group_instance_types
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "application"
      }

      update_config = {
        max_unavailable_percentage = 25
      }

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      tags = local.tags
    }
  }

  # IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Encryption
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  tags = local.tags
}

module "bastion" {
  source = "./modules/bastion"

  name                = "${local.cluster_name}-bastion"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnets
  instance_type       = var.bastion_instance_type
  key_name            = var.bastion_key_name
  allowed_cidr_blocks = var.bastion_allowed_cidr_blocks
  eks_cluster_sg_id   = module.eks.cluster_security_group_id

  tags = local.tags
}

# KMS key for EKS cluster encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks.key_id
}