# Deploy Multiple EKS clusters for HCP Consul

This repository contians the Terraform configuration to deploy multiple EKS clusters that can be configured to connect to the specific [HCP Consul](https://developer.hashicorp.com/hcp/docs/consul) network or create the HCP Consul datacenter.

## WIP

... This repository is still in progress and not fully tested ...

## Requirements

You will need some AWS and HCP permissions to run this Terraform config. The summary requirements are:
* AWS account with full permissions to EKS and VPCs
  * You will need to [configure your credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables) to execute Terraform from Terminal (or setting variables in Terraform Cloud)
* HCP Account and set credentials
  * You need to set your `HCP_CLIENT_ID` and `HCP_CLIENT_SECRET` environment variables (or setting them for Terraform Cloud). You can check how to create HCP credentials [here](https://developer.hashicorp.com/hcp/docs/hcp/admin/iam/service-principals)
* Terraform CLI installed
* Some Unix/Linux terminal skills

> NOTE: Most of the tests for this Terraform configuration have been done in Linux and MacOS. If you want to execute it in Windows I highly recommend to use [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)

## Deploy only EKS clusters (without configuring HCP)

If you want to create only the specific EKS clusters, you can do it by configuring the specific variables in the `terraform.auto.tfvars` file and doing the `terraform apply`:
```
$ tee terraform.auto.rtfvars <<EOF
region = "eu-west-1"
cluster_names = [ "<cluster_name_1>","<cluster_name_2>", ... ]
k8s_version = <kubernetes_version_1.xx>
EOF

$ terraform apply
```

By default it won't create any connection to HCP. With that configuration you will create the number of EKS clusters that you configure in the variable `cluster_names` by specifying the names of the clusters to be created.

## Deploy EKS clusters and connect to an existing HCP Consul

You can create a number of EKS clusters and configure the HCP platform to be able to connect to your existing HCP Consul Control Plane, creating the specific Peering connections or Transit Gateways to connect the HVN network to the private subnets in the EKS clusters. 

### Using HCP Peering

If you want to peer every VPC of the EKS clusters to HCP platform:
```
$ tee terraform.auto.rtfvars <<EOF
region = "eu-west-1"
cluster_names = [ "<cluster_name_1>","<cluster_name_2>", ... ]
hcp_cluster_name = "<hcp_consul_id>"
connect_hcp = true
k8s_version = "1.27"
hcp_connection_type = "peering"
EOF

$ terraform apply
```

### Using HCP Transit Gateway

Probably you can use an AWS Transit Gateway to connect all your VPCs to the HVN network. In this case you just need to put `hcp_connection_type` variable to `tgw`:

```
$ tee terraform.auto.rtfvars <<EOF
region = "eu-west-1"
cluster_names = [ "<cluster_name_1>","<cluster_name_2>", ... ]
hcp_cluster_name = "<hcp_consul_id>"
connect_hcp = true
k8s_version = "1.27"
hcp_connection_type = "tgw"
EOF

$ terraform apply
```

## Creating an HCP Consul cluster
Also, you can create the HCP Consul Cluster, just by putting the `create_hcp` variable to `true`. In that case the value you are using in the `hcp_cluster_name` will be used as the `HCP Consul ID`. 

> NOTE: Need more testing to check all functionality when creating a new HCP cluster

```
$ tee terraform.auto.rtfvars <<EOF
region = "eu-west-1"
cluster_names = [ "<cluster_name_1>","<cluster_name_2>", ... ]
hcp_cluster_name = "<hcp_consul_id>"
connect_hcp = true
k8s_version = "1.27"
hcp_connection_type = "tgw"
create_hcp = true
EOF

$ terraform apply
```

## Get outputs to connect to HCP Consul and EKS clusters

The Terraform configuration has some outputs that help on finding the required data to connect to your HCP Consul cluster or EKS clusters.

To configure your Consul CLI credentials you can do the following:
```
# If your HCP cluster has a public endpoint
export CONSUL_HTTP_ADDR=$(terraform output -json consul_endpoints | jq -r .public)

export CONSUL_HTTP_TOKEN=$(terraform output -raw consul_root_tokens)
```

To connect to your EKS clusters you can use the AWS CLI using the data from the Terraform output:
```
aws eks update-kubeconfig --name $(terraform output -json eks_clusters | jq -r .[0].id) --region $(terraform output -raw region)
```
> NOTE: change the index number `.[0]` in the previous command to connect to other EKS clusters created by the Terraform. That will depend on the number of EKS clusters you have created from the config input.