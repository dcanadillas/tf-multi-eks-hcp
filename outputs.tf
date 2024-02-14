output "cluster_arns" {
  description = "The ARNs of the EKS clusters created by this module"
  value = { for cluster in module.eks_clusters : cluster.cluster_name => cluster.cluster_arn }
}

output "eks_endpoint" {
  description = "The endpoint for the EKS clusters created by this module"
  value = {for cluster in module.eks_clusters : cluster.cluster_name => cluster.eks_endpoint }
}

output "kubeconfig-ca-data" {
  description = "The PEM certificate-authority-data for the EKS clusters created by this module"
  value = { 
    for cluster in module.eks_clusters : cluster.cluster_name => base64decode(cluster.kubeconfig-ca-data)
  }
  sensitive = true
}

output "eks_token" {
  description = "The token for the EKS clusters created by this module"
  value = { for cluster in data.aws_eks_cluster_auth.eks_clusters : cluster.name => cluster.token }
  sensitive = true
}

output "eks_clusters" {
  description = "The EKS clusters created by this module"
  value = data.aws_eks_cluster_auth.eks_clusters[*]
  sensitive = true
}

output "consul_endpoints" {
  description = "The Consul endpoints for the EKS clusters created by this module"
  value = module.hcp_consul[0].consul_urls
}