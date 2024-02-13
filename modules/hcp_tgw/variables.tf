variable "region" {
  description = "The region to deploy the resources"
  type = string  
}


variable "tgw_prefix" {
  description = "A prefix to be used on some resources names like route ids"
}

# variable "vpc" {
#   description = "The VPC values"
#   type = object({
#     vpc_arn = string,
#     vpc_owner_id = string,
#     vpc_id = string,
#     cidr_block = string,
#     private_route_table_ids = list(string)
#   })
# }
# variable "private_subnets" {
#   description = "The private subnets used for the EKS clusters"
#   type = list(string)
# }


variable "vpc_ids" {
  description = "The VPN ids to be used on the peering connection"
  type = list(string)
}

variable "hvn_id" {
}
# variable "hvn_self_link" {
# }

# variable "hvn_cidr_block" {
# }

variable "subnet_cidr_block" {
  type = list(string)
}

variable "private_subnets" {
  description = "The private subnets used for the EKS clusters"
  type = list(list(string))
}

variable "private_route_table_ids" {
  description = "The private route table ids"
  type = list(string)
} 

# variable "vpc_data" {
#   description = "The VPC data"
#   type = list(object({
#     vpc_id = string,
#     cidr_block = string,
#     private_route_table_ids = list(string)
#   }))
# }

