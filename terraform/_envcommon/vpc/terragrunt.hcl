terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

}

inputs = {

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "kubernetes.io/cluster/eks-app" = "shared" 
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
      "kubernetes.io/cluster/eks-app" = "shared" 
      "kubernetes.io/role/elb" = 1
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    }

}