locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.environment_vars.locals.environment
}
# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path = "${get_repo_root()}/terraform/_envcommon/apps/app-go/iam/terragrunt.hcl"
}

inputs = {
  principals = {
    Federated = ["arn:aws:iam::019496914213:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/EA58E0A74DBF5F6B5B535564AFDD6EDE"]
  }
  
  policy_documents = [ <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SidToOverwrite",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::app-go-${local.env}/*",
        "arn:aws:s3:::app-go-${local.env}"
      ]
    }
  ]
}
EOF
  ]

}