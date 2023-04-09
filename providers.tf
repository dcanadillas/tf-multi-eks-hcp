terraform {
  required_version = ">= 1.3.0"
  # cloud {
  #   organization = "<my_tfc_org>"
  #   hostname = "app.terraform.io"
  #   workspaces {
  #     name = "tf-multi-eks-hcp"
  #   }
  # }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.61.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.56.0"
    }
  }
}
# Required providers
provider "aws" {
  region = var.region
}
