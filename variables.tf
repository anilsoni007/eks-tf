variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "eks-prod"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "system_node_group_min_size" {
  description = "Minimum size of the system node group"
  type        = number
  default     = 2
}

variable "system_node_group_max_size" {
  description = "Maximum size of the system node group"
  type        = number
  default     = 4
}

variable "system_node_group_desired_size" {
  description = "Desired size of the system node group"
  type        = number
  default     = 2
}

variable "system_node_group_instance_types" {
  description = "Instance types for the system node group"
  type        = list(string)
  default     = ["m5.large"]
}

variable "app_node_group_min_size" {
  description = "Minimum size of the application node group"
  type        = number
  default     = 2
}

variable "app_node_group_max_size" {
  description = "Maximum size of the application node group"
  type        = number
  default     = 10
}

variable "app_node_group_desired_size" {
  description = "Desired size of the application node group"
  type        = number
  default     = 3
}

variable "app_node_group_instance_types" {
  description = "Instance types for the application node group"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.medium"
}

variable "bastion_key_name" {
  description = "SSH key name for the bastion host"
  type        = string
  default     = "eks-bastion-key"
}

variable "bastion_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with your specific IP ranges for production
}