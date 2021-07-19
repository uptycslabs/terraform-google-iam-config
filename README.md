# Terraform GCP IAM module

This module allows you to create GCP credential config in Google Cloud Platform projects which will be used get GCP data from AWS environment.

This terraforms module will create below resources:-
 * It creates service account, work pool identity and add cloud provider to it.
 * It will attach below policies to service account
     * roles/iam.securityReviewer
     * roles/bigquery.resourceViewer
     * roles/pubsub.subscriber
     * roles/viewer

# Compatibility

This module is meant for use with Terraform version = "~> 3.61.0".

# Usage

## 1. Install terraform


## 2. Authenticate
```
Login with ADC
  - "gcloud auth application-default login"
```


## 3. Use terraform module steps
  * Create a <filename>.tf file, paste below codes and modify as needed.
```
module "create-gcp-cred" {
  source                    = "github.com/Uptycs/terraform-google-iam-config"
  gcp_region                = "us-east1"
  gcp_project_id            = "test-project"
  gcp_project_number        = "1234567899"
  is_service_account_exists = false
  service_account_name      = "sa-for-cldquery"

  # AWS account details
  host_aws_account_id     = "< AWS account id >"
  host_aws_instance_role  = "< AWS role >"

  # Modify if required
  gcp_workload_identity = "wip-uptycs"
  gcp_wip_provider_id   = "aws-id-provider-uptycs"
}

output "service-account-email" {
  value = module.create-gcp-cred.service-account-email
}

output "command-to-generate-gcp-cred-config" {
  value = module.create-gcp-cred.command-to-generate-gcp-cred-config
}
```

## Inputs

| Name                      | Description                                                                                                        | Type          | Default          |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------- | ---------------- |
| gcp_region                | The GCP project region where planning to create resources.                                                         | `string`      | `us-east-1`      |
| gcp_project_id            | The GCP project id where you wants create resources.                                                               | `string`      | `""`             |
| gcp_project_number        | The GCP project number of above passed project id.                                                                 | `number`      | `""`             |
| is_service_account_exists | This is set true or false i.e. whether you wants to use existing/new service account .                             | `bool`        | `false`          |
| service_account_name      | The GCP service account name , if service account is already exists then pass existing service account name else pass new name| `string` | `"sa-for-uptycs"` |
| host_aws_account_id       | The deployer host aws account id.                                                                                  | `number`      | `""`             |
| host_aws_instance_role    | The attached deployer host aws role name.                                                                          | `string`      | `""`             |
| gcp_workload_identity     | Workload Identity Pool to allow Uptycs integration via AWS federation                                              | `string`      | `""`             |
| gcp_wip_provider_id       | Workload Identity Pool provider id allow to add cloud provider                                                     | `string`      | `""`             |


## Outputs

| Name                    | Description                                  |
| ----------------------- | -------------------------------------------- |
| service-account-email   | The deployed Service Account's email-id |
| command-to-generate-gcp-cred-config  | For creating again same cred config json data ,please use command return by "command-to-generate-gcp-cred-config" |


## Notes

1. service account details
     - Set `is_service_account_exists = true`, if service account already exists. Specify existing service account name using `service_account_name`.
     - Set `is_service_account_exists = false` if service account does not exist. Provide a new name via `service_account_name`.

2. Workload Identity Pool is soft-deleted and permanently deleted after approximately 30 days.
     - Soft-deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`. ID cannot be re-used until the WIP is permanently deleted.
     - After `terraform destroy`, same WIP can't be created again. Modify `gcp_workload_identity` value if required.

3. `credentials.json` is only created once. To re create the file use command returned by `command-to-generate-gcp-cred-config` output.


## 4.Execute Terraform script to get credentials JSON
```
$ terraform init
$ terraform plan
$ terraform apply # NOTE: Once terraform successfully applied, it will create "credentials.json" file.
```