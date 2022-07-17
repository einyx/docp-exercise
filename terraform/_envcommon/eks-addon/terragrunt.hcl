

terraform {
  source = "git::https://github.com/einyx/terraform-kubernetes-addons.git//modules/aws?ref=main"
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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "<= 0.15"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
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

dependency "eks" {
  config_path = "../eks"
}

dependency "vpc" {
    config_path = "../vpc"
}



inputs = {

  aws-ebs-csi-driver = {
    enabled = true
  }

  cluster-name = dependency.eks.outputs.cluster_id

  eks = {
    "cluster_oidc_issuer_url" = dependency.eks.outputs.cluster_oidc_issuer_url
  }

  cluster-autoscaler = {
    enabled      = true
    version      = "v1.21.2"
    extra_values = <<-EXTRA_VALUES
      extraArgs:
        scale-down-utilization-threshold: 0.9
        cordon-node-before-terminating: true
      EXTRA_VALUES
  }

  aws-ebs-csi-driver = {
    enabled          = true
    is_default_class = true
    wait             = false
    use_encryption   = true
    use_kms          = true
  }

  aws-load-balancer-controller = {
    enabled = false
  }

  metrics-server = {
    enabled = true
  }

  vault = {
    enabled     = true
    generate_ca = true
    extra_values = <<-EXTRA_VALUES
      extraArgs:
        standalone:
          enabled: false
        ha:
          enabled: true
        dataStorage:
          storageClass: ebs-sc
    EXTRA_VALUES
  }

  ingress-nginx = {
    enabled       = true
    use_nlb       = true
    wait          = true
    extra_values  = <<-EXTRA_VALUES
      controller:
        ingressClassResource:
          enabled: true
          default: true
        replicaCount: 2
        minAvailable: 1
        kind: "Deployment"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
      EXTRA_VALUES
  }
}
