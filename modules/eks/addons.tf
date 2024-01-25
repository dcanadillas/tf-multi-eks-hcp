data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_clusters.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "example" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_clusters.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "addon_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.example.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.example.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.example.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "addon_ebs_csi" {
  assume_role_policy = data.aws_iam_policy_document.addon_assume_role_policy.json
  name               = "eks-ebs-csi-role"
}

resource "aws_iam_role_policy_attachment" "addon_ebs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.addon_ebs_csi.name
}


data "aws_eks_addon_version" "latest" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.eks_clusters.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name                = aws_eks_cluster.eks_clusters.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.latest.version
  service_account_role_arn = aws_iam_role.addon_ebs_csi.arn

}