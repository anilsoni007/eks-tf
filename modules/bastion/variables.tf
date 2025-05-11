variable "name" {
  description = "Name to be used for the bastion instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where bastion host will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where bastion host can be deployed"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name for bastion host"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_cluster_sg_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}