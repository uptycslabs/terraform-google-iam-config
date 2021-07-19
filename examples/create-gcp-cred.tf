module "create-gcp-cred" {
  source                    = "github.com/uptycslabs/terraform-google-iam-config"
  gcp_region                = "us-east1"
  gcp_project_id            = "test-project"
  gcp_project_number        = "11111111111"
  is_service_account_exists = false
  service_account_name      = "sa-for-testing"

  # AWS account details
  host_aws_account_id     = "1234567890"
  host_aws_instance_role  = "Test_Role_Allinone"

  # Modify if required
  gcp_workload_identity = "wip-testing12"
  gcp_wip_provider_id   = "aws-id-provider-test"
}

output "service-account-email" {
  value = module.create-gcp-cred.service-account-email
}

output "command-to-generate-gcp-cred-config" {
  value = module.create-gcp-cred.command-to-generate-gcp-cred-config
}
