module "create-gcp-cred" {
  source                    = "github.com/uptycslabs/terraform-google-iam-config"
  gcp_project_id            = "test-project"
  service_account_exists    = false
  service_account_name      = "sa-for-testing"

  # AWS account details
  host_aws_account_id     = "1234567890"
  host_aws_instance_roles  = ["Role_Allinone","Role_PNode", "Role_Cloudquery"]

  # Modify if required
  integration_name = "uptycs-int-20220101"
}

output "service-account-email" {
  value = module.create-gcp-cred.service-account-email
}

output "command-to-generate-gcp-cred-config" {
  value = module.create-gcp-cred.command-to-generate-gcp-cred-config
}
