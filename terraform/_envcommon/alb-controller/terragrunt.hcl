terraform {
  source = "git::https://github.com/v-bus/terraform-kubernetes-alb-ingress-controller.git"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

}


data "aws_region" "current" {}

data "aws_eks_cluster" "target" {
  name = ${local.name}
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = ${local.name}
}

inputs = {

  version = "3.4.0"

  providers = {
    kubernetes = "kubernetes.eks"
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = "eu-north-1"
  k8s_cluster_name = ${local.name}

}