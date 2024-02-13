# Deploy Multiple EKS clusters for HCP Consul

This repository contians the Terraform configuration to deploy multiple EKS clusters, that can be configured to connect to the specific HCP Consul network or create the HCP Consul datacenter.

## WIP

... This repository is still in progress and not tested ...

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

### Creating an HCP Consul cluster
Also, you can create the HCP Consul Cluster, just by putting the `create_hcp` variable to `true`. In that case the value you are using in the `hcp_cluster_name` will be used as the `HCP Consul ID`. 