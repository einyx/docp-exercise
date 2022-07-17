terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

}

inputs = {

  bucket = "app-go-development"
  acl    = "private"

  versioning = {
    enabled = false
  }
}