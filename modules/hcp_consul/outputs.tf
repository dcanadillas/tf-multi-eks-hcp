output "hvn_id" {
  value = var.create_hcp ? hcp_consul_cluster.main[0].hvn_id : data.hcp_consul_cluster.main[0].hvn_id
}

output "hvn_self_link" {
  value = var.create_hcp ? hcp_hvn.main[0].self_link  : data.hcp_hvn.example[0].self_link
}

output "hvn_cidr_block" {
  value = var.create_hcp ? hcp_hvn.main[0].cidr_block  : data.hcp_hvn.example[0].cidr_block
}

output "consul_urls" {
  value = var.create_hcp ? {
    public = hcp_consul_cluster.main[0].consul_public_endpoint_url,
    private = hcp_consul_cluster.main[0].consul_private_endpoint_url
  } : {
    private = data.hcp_consul_cluster.main[0].consul_private_endpoint_url,
    public = data.hcp_consul_cluster.main[0].consul_public_endpoint_url
  
  } 
}