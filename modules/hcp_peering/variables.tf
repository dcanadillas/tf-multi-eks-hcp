variable "cluster_name" {
  description = "The HCP Consul cluster id"
}
variable "create_hcp" {
  description = "Set it to true if want to create the HCP cluster"
  default = false
}

variable "aws_region" {
  description = "The AWS region used for HVN and VPC"
}

variable "hvn_region" {
  description = "The HVN region for the HCP Consul cluster"
}

variable "peering_prefix" {
  description = "A prefix to be used on some resources names like route ids"
}

variable "vpc" {
  description = "The VPC values"
  type = object({
    vpc_arn = string,
    vpc_owner_id = string,
    vpc_id = string,
    cidr_block = string,
    private_route_table_ids = list(string)
  })
}

variable "hvn_id" {
  
}
variable "hvn_self_link" {
  
}

variable "hvn_cidr_block" {
}

variable "subnet_cidr_block" {
  type = list(string)
}