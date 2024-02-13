# Input variables
variable "region" {
  description = "The AWS region where the EKS cluster will be created"
}

# variable "cluster_names" {
#   description = "A list of names for the EKS clusters to be created"
#   type        = list(string)
# }

variable "cluster_name" {
  description = "Name for the EKS cluster to be created"
  type        = string
}

variable "node_group_desired_capacity" {
  description = "The desired number of worker nodes in each node group"
  default     = 3
}

variable "node_group_instance_type" {
  description = "The instance type to use for the worker nodes in each node group"
  default     = "t3.small"
}

variable "subnet_ids" {
  description = "The private subnets used for the EKS clusters"
  type = list(string)
}

variable "use_fargate" {
  default = false
}

variable "k8s_version" {
  description = "The Kubernetes version to use for the EKS clusters"
  default     = "1.26"
}
variable "suffix" {
  description = "A suffix to be used on some resources names like roles or policies"
  type = string
}