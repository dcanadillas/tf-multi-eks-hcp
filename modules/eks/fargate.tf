resource "aws_eks_fargate_profile" "main" {
  count = var.use_fargate ? 1 : 0
  # count = length(var.cluster_names)
  # cluster_name           = aws_eks_cluster.eks_clusters[count.index].name
  cluster_name = aws_eks_cluster.eks_clusters.name
  # fargate_profile_name   = "consul-${aws_eks_cluster.eks_clusters[count.index].name}"
  fargate_profile_name   = "consul-${aws_eks_cluster.eks_clusters.name}"
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  # subnet_ids             = aws_eks_cluster.eks_clusters[count.index].vpc_config.subnet_ids
  subnet_ids = aws_eks_cluster.eks_clusters.vpc_config[0].subnet_ids

  selector {
    namespace = "*"
  }
}


resource "aws_iam_role" "fargate" {
  count = var.use_fargate ? 1 : 0
  name = "fargate-${aws_eks_cluster.eks_clusters.name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate-AmazonEKSFargatePodExecutionRolePolicy" {
  count = var.use_fargate ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}