terraform {
  source = "git::https://github.com/einyx/terraform-aws-iam-role.git"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

}

inputs = {

  enabled   = true
  namespace = "eks"
  stage     = "app"
  name      = "go"

  policy_description = "Allow S3 FullAccess"
  role_description   = "IAM role with permissions to perform actions on S3 resources"

  principals = {
    AWS = ["arn:aws:iam::019496914213:role/self-managed-node-group"]
  }

  assume_role_actions = ["sts:AssumeRoleWithWebIdentity"]

  assume_role_conditions = [
    {
    test = "StringEquals"
    variable = "oidc.eks.eu-north-1.amazonaws.com/id/EA58E0A74DBF5F6B5B535564AFDD6EDE:aud" 
    values = ["sts.amazonaws.com"]
    },
    {
    test = "StringEquals"
    variable = "oidc.eks.eu-north-1.amazonaws.com/id/EA58E0A74DBF5F6B5B535564AFDD6EDE:sub"
    values = ["system:serviceaccount:app-go:app-go"]
    }
  ]
  policy_documents = [ <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SidToOverwrite",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::app-go/*",
        "arn:aws:s3:::app-go"
      ]
    }
  ]
}
EOF
  ]

}


