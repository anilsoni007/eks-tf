# EKS Terraform Infrastructure

This repository contains Terraform code to deploy an Amazon EKS cluster with the following components:

## Architecture

- VPC with public and private subnets across multiple availability zones
- EKS cluster with private API endpoint
- Two node groups:
  - System node group for system components (with taints)
  - Application node group for workloads
- Bastion host for secure access to the cluster
- KMS encryption for EKS secrets

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v1.0.0+
- kubectl

## Usage

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Review the plan:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

4. Configure kubectl:
   ```
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

5. Access the cluster via the bastion host:
   ```
   ssh -i <key-pair> ec2-user@<bastion-public-ip>
   ```

## Important Notes

- The EKS API endpoint is private by default and can only be accessed from within the VPC
- Use the bastion host to access the cluster
- System workloads should be scheduled on the system node group
- Application workloads should be scheduled on the application node group



## Clean Up

To destroy all resources:
```
terraform destroy
```