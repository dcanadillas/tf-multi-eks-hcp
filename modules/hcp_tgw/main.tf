
resource "random_id" "server" {
  # keepers = {
  #   cluster_id = var.cluster_name
  # }
  byte_length = 2
}


data "hcp_hvn" "hvn" {
  hvn_id = var.hvn_id
}

data "aws_vpc" "vpc" {
  count = length(var.vpc_ids)
  filter {
    name   = "vpc-id"
    values = [ var.vpc_ids[count.index] ]
  }
}

data "aws_subnets" "vpc_subnets" {
  count = length(var.vpc_ids)
  filter {
    name   = "vpc-id"
    values = [ var.vpc_ids[count.index] ]
  }
}


# Creating the routes and attachment to the Transit Gateway from the HCP HVN network
resource "hcp_hvn_route" "to_consul_client" {
  count = length(var.subnet_cidr_block)
  # for_each = { for k,v in var.vpc : k => v }
  hvn_link         = data.hcp_hvn.hvn.self_link
  hvn_route_id     = "${var.tgw_prefix}-${var.hvn_id}-${count.index}"
  destination_cidr = var.subnet_cidr_block[count.index]
  target_link      = hcp_aws_transit_gateway_attachment.example.self_link
}

# Creating the Transit Gateway in AWS
resource "aws_ec2_transit_gateway" "hcp" {
  description = "tgw-demo"
  tags = {
    Name = "tgw-for-hcp"
  }
  amazon_side_asn = 64512
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  # auto_accept_shared_attachments = "enable"
}


# To configure Transit Gateway Attachment, Resource Share and Principal Association, use the following code:
resource "aws_ram_resource_share" "hcp_share" {
  name                      = "dc-resource-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "example" {
  resource_share_arn = aws_ram_resource_share.hcp_share.arn
  principal          = data.hcp_hvn.hvn.provider_account_id
}

resource "aws_ram_resource_association" "example" {
  resource_share_arn = aws_ram_resource_share.hcp_share.arn
  resource_arn       = aws_ec2_transit_gateway.hcp.arn
}

resource "hcp_aws_transit_gateway_attachment" "example" {
  depends_on = [
    aws_ram_principal_association.example,
    aws_ram_resource_association.example,
  ]

  hvn_id                        = data.hcp_hvn.hvn.hvn_id
  transit_gateway_attachment_id = "dc-tgw-attachment"
  transit_gateway_id            = aws_ec2_transit_gateway.hcp.id
  resource_share_arn            = aws_ram_resource_share.hcp_share.arn
}



# Attach the VPCs to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc" {
  count = length(var.vpc_ids)
  subnet_ids         = var.private_subnets[count.index]
  transit_gateway_id = aws_ec2_transit_gateway.hcp.id
  vpc_id             = var.vpc_ids[count.index]
  dns_support        = "enable"
  ipv6_support       = "disable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}


# resource "aws_ec2_transit_gateway_route_table" "vpcs" {
#   count = length(var.vpc_ids)
#   transit_gateway_id = aws_ec2_transit_gateway.hcp.id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "vpcs" {
#   count = length(var.vpc_ids)
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc[count.index].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpcs[count.index].id
# }

# resource "aws_ec2_transit_gateway_route" "vpcs" {
#   count = length(var.vpc_ids)
#   destination_cidr_block         = data.aws_vpc.vpc[count.index].cidr_block
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc[count.index].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpcs[count.index].id
# }

# resource "aws_ec2_transit_gateway_route" "hcp" {
#   count = length(var.vpc_ids)
#   destination_cidr_block         = data.hcp_hvn.hvn.cidr_block
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc[count.index].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpcs[count.index].id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "vpcs" {
#   count = length(var.vpc_ids)
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc[count.index].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpcs[count.index].id
# }


resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "example" {
  transit_gateway_attachment_id = hcp_aws_transit_gateway_attachment.example.provider_transit_gateway_attachment_id
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "vpcs" {
#   count = length(var.vpc_ids)
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc[count.index].provider_transit_gateway_attachment_id
#   transit_gateway_default_route_table_association = true
#   transit_gateway_default_route_table_propagation = true
# }



# We need to create the  aws routes to the private subnets
resource "aws_route" "tgw" {
  count                     = length(var.private_route_table_ids)
  # for_each = local.routes_vpcs
  route_table_id            = var.private_route_table_ids[count.index]
  destination_cidr_block    = data.hcp_hvn.hvn.cidr_block
  transit_gateway_id        = aws_ec2_transit_gateway.hcp.id
}