output "cluster_arns" {
  description = "The ARNs of the EKS clusters created by this module"
  value = [ for cluster in module.eks_clusters : cluster.cluster_arn]
}

output "eks_endpoint" {
  value = [ for cluster in module.eks_clusters : cluster.eks_endpoint ]
}

output "kubeconfig-ca-data" {
  value = [ for cluster in module.eks_clusters : cluster.kubeconfig-ca-data ]
}

output "eks_token" {
  value = [ for cluster in data.aws_eks_cluster_auth.eks_clusters : cluster.token ]
  sensitive = true
}