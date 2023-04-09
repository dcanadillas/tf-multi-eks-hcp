variable "hcp_cluster_name" {
  description = "The cluster name for HCP Consul"
  default = "consul-cluster"
}

variable "create_hcp" {
  description = "Set it to true if want to create the HCP cluster"
  default = false
}

variable "hcp_tier" {
  description = "The HCP Consul cluster tier. Development by default."
  default = "dev"
}

variable "min_consul_version" {
  description = "Minimum version to use for Consul"
  default = "1.14.4"
}

variable "region" {
  description = "The AWS region where the EKS cluster will be created"
  default = "eu-west-1"
}