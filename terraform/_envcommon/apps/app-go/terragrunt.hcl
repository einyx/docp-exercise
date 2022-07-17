terraform {
  source  = "git::https://github.com/terraform-module/terraform-helm-release.git"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  name = "eks-app"
  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

}

generate "providers" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 0.13"
  required_providers {
    helm       = "2.4.1"
    kubernetes = "~> 2.0, != 2.12"
  }
}
EOF
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
  provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token

  }
  provider "helm" {
    experiments {
      manifest = true
    }
    kubernetes {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      exec {
        api_version = "client.authentication.k8s.io/v1alpha1"
        args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
        command     = "aws"
      }
    }
  }

  data "aws_eks_cluster" "cluster" {
    name = "${local.name}"
  }

  data "aws_eks_cluster_auth" "cluster" {
    name = "${local.name}" 
  }
EOT

}



inputs = {

  namespace  = "app-go"
  repository =  ""

  app = {
    name              = "app-go"
    version           = "1.0.0"
    chart             = "${get_repo_root()}/app/golang/app-go"
    force_update      = true
    wait              = false
    recreate_pods     = true
    deploy            = 1
    create_namespace  = true
  }

}