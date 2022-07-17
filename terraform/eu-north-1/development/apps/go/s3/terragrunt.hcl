
locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

}
# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path = "${get_repo_root()}/terraform/_envcommon/apps/app-go/s3/terragrunt.hcl"
}

inputs = {

}