


data "aws_availability_zones" "available" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

module "vpc" {
  count = length(var.cluster_names)
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name                 = "eks-clusters-vpc-${count.index}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.${6*count.index+1}.0/24", "10.0.${6*count.index+2}.0/24", "10.0.${6*count.index+3}.0/24"]
  private_subnets      = ["10.0.${6*count.index+4}.0/24", "10.0.${6*count.index+5}.0/24", "10.0.${6*count.index+6}.0/24"]
  # public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # private_subnets      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}


module "eks_clusters" {
  count = length(var.cluster_names)
  source = "./modules/eks"

  region                    = var.region
  cluster_name             = var.cluster_names[count.index]
  node_group_desired_capacity = var.node_group_desired_capacity
  node_group_instance_type  = var.node_group_instance_type
  subnet_ids                = module.vpc[count.index].private_subnets
  use_fargate = var.use_fargate
}

module "hcp_consul" {
  depends_on = [
    module.vpc,
    module.eks_clusters
  ]
  count = var.connect_hcp ? 1 : 0
  source = "./modules/hcp_consul"
  region = var.region
  create_hcp = var.create_hcp
  hcp_cluster_name = var.hcp_cluster_name
}

module "hcp" {
  depends_on = [
    module.vpc,
    module.eks_clusters,
    module.hcp_consul
  ]
  count = var.connect_hcp ? length(module.vpc) : 0
  source = "./modules/hcp_peering"
  cluster_name = var.hcp_cluster_name
  peering_prefix = var.cluster_names[count.index]
  aws_region = var.region
  hvn_region = var.region
  hvn_id = module.hcp_consul[0].hvn_id
  hvn_self_link = module.hcp_consul[0].hvn_self_link
  hvn_cidr_block = module.hcp_consul[0].hvn_cidr_block
  subnet_cidr_block = module.vpc[count.index].private_subnets_cidr_blocks
  vpc = {
    vpc_arn = module.vpc[count.index].vpc_arn,
    vpc_id = module.vpc[count.index].vpc_id,
    vpc_owner_id = module.vpc[count.index].vpc_owner_id,
    cidr_block = module.vpc[count.index].default_vpc_cidr_block
    private_route_table_ids = module.vpc[count.index].private_route_table_ids
  }
}

data "aws_eks_cluster_auth" "eks_clusters" {
  depends_on = [
    module.eks_clusters
  ]
  count = length(var.cluster_names)
  name = var.cluster_names[count.index]
}

