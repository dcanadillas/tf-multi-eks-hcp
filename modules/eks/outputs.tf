output "cluster_arn" {
  description = "The ARNs of the EKS clusters created by this module"
  value = aws_eks_cluster.eks_clusters.arn
}

output "eks_endpoint" {
  value = aws_eks_cluster.eks_clusters.endpoint
}

output "kubeconfig-ca-data" {
  value = aws_eks_cluster.eks_clusters.certificate_authority[0].data
}

# # output "node_group_arns" {
# #   description = "The ARNs of the node groups created for each EKS cluster"
# #   value       = [for node_group in aws_eks_node_group.node_groups : node_group.arn]
# # }

# output "kubeconfig_files" {
#   description = "The contents of the kubeconfig files for each EKS cluster"
#   value       = [for cluster in aws_eks_cluster.eks_clusters : cluster.kubeconfig]
# }
