locals {
  namespace = read_terragrunt_config(find_in_parent_folders("namespace.hcl")).locals
  layer  = read_terragrunt_config(find_in_parent_folders("layer.hcl")).locals
  stage  = read_terragrunt_config(find_in_parent_folders("stage.hcl")).locals
  region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "h8n-${local.namespace.name}-${local.layer.name}-${local.stage.name}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region.id}"
    dynamodb_table = "h8n-${local.namespace.name}-${local.layer.name}-${local.stage.name}-tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region.id}"
}
EOF
}

inputs = {
  namespace = local.namespace.name
  layer     = local.layer.name
  stage     = local.stage.name
  region    = local.region.name
  managed_by_ref = "h8n-${local.namespace.name}-${local.layer.name}-${local.stage.name}/${path_relative_to_include()}"
}

