
resource "random_id" "server" {
  # keepers = {
  #   cluster_id = var.cluster_name
  # }
  byte_length = 2
}

# locals {
#   vpc_region = var.aws_region
#   hvn_region = var.hvn_region
#   cluster_id = var.create_hcp ? "${var.cluster_name}-${random_id.server.dec}" : var.cluster_name
#   hvn_id     = "consul-hvn-${random_id.server.dec}"
# }


# # The HVN created in HCP
# resource "hcp_hvn" "main" {
#   count = var.create_hcp ? 1 : 0
#   hvn_id         = local.hvn_id
#   cloud_provider = "aws"
#   region         = local.hvn_region
#   cidr_block     = "172.25.32.0/20"
# }

# data "hcp_hvn" "example" {
#   count = var.create_hcp ? 0 : 1
#   hvn_id = data.hcp_consul_cluster.main[0].hvn_id
# }

# resource "hcp_consul_cluster" "main" {
#   count = var.create_hcp ? 1 : 0
#   cluster_id      = local.cluster_id
#   hvn_id          = hcp_hvn.main[0].hvn_id
#   public_endpoint = true
#   tier            = var.hcp_tier
#   min_consul_version = var.min_consul_version
# }

# data "hcp_consul_cluster" "main" {
#   count = var.create_hcp ? 0 : 1
#   cluster_id      = local.cluster_id
# }

# resource "hcp_consul_cluster_root_token" "token" {
#   depends_on = [
#     hcp_consul_cluster.main,
#     data.hcp_consul_cluster.main
#   ]
#   cluster_id = local.cluster_id
# }

data "aws_arn" "peer" {
  # count = length(var.vpc)
  # for_each = { for k,v in var.vpc : k => v }
  # arn = var.vpc[count.index].vpc_arn
  arn = var.vpc.vpc_arn
}

resource "hcp_aws_network_peering" "consul_client" {
  # count = length(var.vpc)
  # hvn_id          = var.create_hcp ? hcp_hvn.main[0].hvn_id : data.hcp_consul_cluster.main[0].hvn_id
  hvn_id = var.hvn_id
  peering_id      = "${var.peering_prefix}-${var.hvn_id}"
  peer_vpc_id     = var.vpc.vpc_id
  peer_account_id = var.vpc.vpc_owner_id
  peer_vpc_region = data.aws_arn.peer.region
  # peer_vpc_id     = var.vpc[count.index].vpc_id
  # peer_account_id = var.vpc[count.index].vpc_owner_id
  # peer_vpc_region = data.aws_arn.peer[count.index].region
}

resource "hcp_hvn_route" "to_consul_client" {
  count = length(var.subnet_cidr_block)
  # for_each = { for k,v in var.vpc : k => v }
  hvn_link         = var.hvn_self_link
  hvn_route_id     = "${var.peering_prefix}-${var.hvn_id}-${count.index}"
  destination_cidr = var.subnet_cidr_block[count.index]
  target_link      = hcp_aws_network_peering.consul_client.self_link
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  # count = length(var.vpc)
  # for_each = { for k,v in var.vpc : k => v }
  vpc_peering_connection_id = hcp_aws_network_peering.consul_client.provider_peering_id
  auto_accept               = true
}


# data "hcp_consul_agent_helm_config" "consul_helm" {
#   cdepends_on = [
#     hcp_consul_cluster.main
#   ]
#   cluster_id = local.cluster_id
#   kubernetes_endpoint = data.aws_eks_cluster.eks_cluster.endpoint
# }

# data "hcp_consul_agent_kubernetes_secret" "consul_secrets" {
#   cluster_id = hcp_consul_cluster.main.cluster_id
# }

# Creating route for the peering connection

resource "aws_route" "peering" {
  count                     = length(var.vpc.private_route_table_ids)
  # for_each = local.routes_vpcs
  route_table_id            = var.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.hvn_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}