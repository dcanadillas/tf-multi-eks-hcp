resource "random_id" "server" {
  # keepers = {
  #   cluster_id = var.cluster_name
  # }
  byte_length = 2
}

locals {
  cluster_id = var.create_hcp ? "${var.hcp_cluster_name}-${random_id.server.dec}" : var.hcp_cluster_name
  hvn_id     = var.create_hcp ? "consul-hvn-${random_id.server.dec}" : data.hcp_consul_cluster.main[0].hvn_id
}

# The HVN created in HCP
resource "hcp_hvn" "main" {
  count = var.create_hcp ? 1 : 0
  hvn_id         = local.hvn_id
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = "172.25.32.0/20"
}

data "hcp_hvn" "example" {
  count = var.create_hcp ? 0 : 1
  hvn_id = local.hvn_id
}

resource "hcp_consul_cluster" "main" {
  count = var.create_hcp ? 1 : 0
  cluster_id      = local.cluster_id
  hvn_id          = hcp_hvn.main[0].hvn_id
  public_endpoint = true
  tier            = var.hcp_tier
  min_consul_version = var.min_consul_version
}

data "hcp_consul_cluster" "main" {
  count = var.create_hcp ? 0 : 1
  cluster_id      = local.cluster_id
}

resource "hcp_consul_cluster_root_token" "token" {
  depends_on = [
    hcp_consul_cluster.main,
    data.hcp_consul_cluster.main
  ]
  cluster_id = local.cluster_id
}