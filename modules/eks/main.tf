# Terraform module for deploying multiple EKS clusters and node groups

# Resources
resource "aws_eks_cluster" "eks_clusters" {
  # count = length(var.cluster_names)

  # name     = var.cluster_names[count.index]
  name = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version = var.k8s_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
  ]
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# resource "aws_eks_node_group" "node_groups" {
#   count = length(var.cluster_names)

#   cluster_name    = aws_eks_cluster.eks_clusters[count.index].name
#   node_group_name = "${aws_eks_cluster.eks_clusters[count.index].name}-workers"

#   scaling_config {
#     desired_size = var.node_group_desired_capacity
#     max_size     = var.node_group_desired_capacity + 1
#     min_size     = var.node_group_desired_capacity - 1
#   }

#   instance_types = [var.node_group_instance_type]

#   remote_access {
#     ec2_ssh_key = var.ssh_key_name
#     source_security_group_id = var.worker_security_group_id
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_cluster,
#   ]
# }

# # Outputs
# output "cluster_arns" {
#   value = [for cluster in aws_eks_cluster.eks_clusters : cluster.arn]
# }




# module "eks_node_group" {
#   # count = length(var.cluster_names)
#   source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
#   version = "19.11.0"

#   # cluster_name = var.cluster_names[count.index]
#   cluster_name = var.cluster_name
#   # cluster_primary_security_group_id = aws_eks_cluster.eks_clusters[count.index].vpc_config.cluster_primary_security_group_id
#   cluster_primary_security_group_id = aws_eks_cluster.eks_clusters.vpc_config[0].cluster_security_group_id
#   # name          = "node-group-${var.cluster_names[count.index]}"
#   name          = "${var.cluster_name}"
#   desired_size  = 3
#   max_size = 3
#   min_size = 1
#   subnet_ids = var.subnet_ids
#   # additional_security_groups = [var.worker_security_group_id]

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }

#   # Use Fargate if the use_fargate variable is true
#   launch_template_version = var.use_fargate ? "$Latest" : null
#   instance_types          = var.use_fargate ? null : [var.node_group_instance_type]
#   # capacity_type           = var.use_fargate ? "FARGATE" : "ON_DEMAND"
# }
