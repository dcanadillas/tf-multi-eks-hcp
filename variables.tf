# Input variables
variable "region" {
  description = "The AWS region where the EKS cluster will be created"
  default = "eu-west-1"
}

variable "cluster_names" {
  description = "A list of names for the EKS clusters to be created"
  type        = list(string)
  default = ["cluster-test-0"]
}

variable "node_group_desired_capacity" {
  description = "The desired number of worker nodes in each node group"
  default     = 3
}

variable "node_group_instance_type" {
  description = "The instance type to use for the worker nodes in each node group"
  default     = "t3.small"
}

# variable "private_subnets" {
#   description = "The private subnets used for the EKS clusters"
#   type = list(string)
# }

variable "use_fargate" {
  default = false
}

variable "connect_hcp" {
  default =false
}

variable "create_hcp" {
  description = "Set it to true if you to create the HCP Consul cluster. Only one HCP Consul datacenter is supported by now"
  default = false
}

variable "hcp_cluster_name" {
  description = "The name/ID of your HCP Consul cluster. If \"create_hcp\" variable is true, this variable will be the name of the cluster to create."
}

