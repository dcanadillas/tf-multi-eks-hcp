# provider "aws" {
#   region = "us-west-2"
# }

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name                 = "eks-cluster-vpc"
#   cidr                 = "10.0.0.0/16"
#   azs                  = ["us-west-2a", "us-west-2b", "us-west-2c"]
#   private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
#   enable_nat_gateway   = true
#   enable_vpn_gateway   = false
#   single_nat_gateway   = true
#   create_database_subnet = false
# }

# resource "aws_security_group" "eks_cluster_sg" {
#   name_prefix = "eks-cluster-sg-"

#   ingress {
#     from_port = 0
#     to_port   = 65535
#     protocol  = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_iam_role" "eks_service_role" {
#   name = "eks-service-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_service_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_service_role.name
# }

# module "eks_cluster" {
#   source = "terraform-aws-modules/eks/aws"

#   cluster_name = "eks-cluster"

#   subnets             = module.vpc.private_subnets
#   vpc_id              = module.vpc.vpc_id
#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }

#   # Enable Fargate
#   fargate_profile = {
#     name = "fargate"
#     subnet_ids = module.vpc.private_subnets
#     selectors = [
#       {
#         namespace = "default"
#       }
#     ]
#   }

#   # Enable Managed Node Group
#   # Uncomment the following lines if you want to add Managed Node Group to the EKS cluster
#   # enable_managed_node_group = true
#   # subnet_ids = module.vpc.private_subnets
 
# }