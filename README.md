# Production-Grade EKS Terraform Module

This Terraform module creates a production-grade Amazon EKS cluster with secure access via a bastion host.

## Architecture

The module creates the following resources:

- VPC with public, private, and intra subnets across multiple availability zones
- EKS cluster with private endpoint access
- Managed node groups for system and application workloads
- Bastion host for secure access to the EKS cluster
- Security groups with least privilege access
- KMS encryption for EKS secrets
- IAM roles with proper permissions

## Security Features

- Private EKS API endpoint (no public access)
- Access to EKS API only from bastion host
- Encrypted EBS volumes for all nodes
- IMDSv2 required on all instances
- Encrypted secrets using KMS
- VPC flow logs enabled
- Least privilege security groups
- IAM roles for service accounts (IRSA)
- Node-to-node traffic allowed but controlled

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform v1.0.0+
- SSH key pair for bastion host access

## Usage

```hcl
module "eks" {
  source = "./path/to/module"

  region       = "us-west-2"
  project_name = "my-project"
  environment  = "prod"
  
  # Customize other variables as needed
}
```

## Accessing the Cluster

1. SSH into the bastion host:
   ```
   ssh -i your-key.pem ec2-user@<bastion-public-ip>
   ```

2. Configure kubectl:
   ```
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

3. Verify access:
   ```
   kubectl get nodes
   ```

## Customization

You can customize the deployment by modifying the variables in `variables.tf`. Key variables include:

- `cluster_version`: Kubernetes version
- `node_group_*`: Node group configurations
- `bastion_allowed_cidr_blocks`: IP ranges allowed to access the bastion host

## Best Practices

- Replace the default `bastion_allowed_cidr_blocks` with your specific IP ranges
- Rotate SSH keys regularly
- Consider implementing AWS Systems Manager Session Manager for bastion-less access
- Enable AWS GuardDuty for threat detection
- Implement regular security scanning of your cluster

