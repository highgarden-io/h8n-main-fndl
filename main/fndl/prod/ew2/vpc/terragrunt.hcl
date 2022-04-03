# Include the root `namespace.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders("common.hcl")
}

# Load Common Locals from Below
locals {
  namespace = read_terragrunt_config(find_in_parent_folders("namespace.hcl")).locals
  layer  = read_terragrunt_config(find_in_parent_folders("layer.hcl")).locals
  stage  = read_terragrunt_config(find_in_parent_folders("stage.hcl")).locals
  region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  # --
}

terraform {
  source = "github.com/highgarden-io/terraform-aws-vpc?ref=v0.2.1"
}

inputs = {
  name   = "vpc"

  # --
  cidr               = "10.0.0.0/16"
  secondary_cidr_blocks = ["10.1.0.0/16"]
  azs                = ["${local.region.id}a", "${local.region.id}b", "${local.region.id}c"]
  private_subnets    = [
    "10.0.0.0/18",
    "10.0.64.0/18",
    "10.0.128.0/18",
    "10.1.0.0/18",
    "10.1.64.0/18",
    "10.1.128.0/18",
  ]
  public_subnets     = [
    "10.0.192.0/21",
    "10.0.200.0/21",
    "10.0.208.0/21",
    "10.1.192.0/21",
    "10.1.200.0/21",
    "10.1.208.0/21",
  ]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_flow_log = false
  enable_ipv6 = true

  manage_default_security_group = true
  manage_default_network_acl = true
  manage_default_route_table = true
  create_s3_gateway_endpoint = true
  create_dynamodb_gateway_endpoint = true

}