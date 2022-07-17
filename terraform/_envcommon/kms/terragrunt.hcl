terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

}

inputs = {

  description = "EKS key usage"
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  key_administrators = ["arn:aws:iam::019496914213:root"]
  key_users          = ["arn:aws:iam::019496914213:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
  key_service_users  = ["arn:aws:iam::019496914213:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]

  # Aliases
  aliases = ["alias/eks"]

  tags = {
    Terraform   = "true"
    Environment = "development"
  }

}