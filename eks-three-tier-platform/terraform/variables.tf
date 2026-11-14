variable "aws_region" {
  description = "AWS region for the EKS cluster"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "three-tier-platform"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version supported in your region"
  type        = string
  default     = "1.35"
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_types" {
  description = "Managed node group EC2 instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}
