# Terraform GCP IAM module

This module would help create access credentials to be used with GCP Project integration with Uptycs.
Access is setup with Workload Identity Pool (WIP) where AWS is the identity provider.
This avoids sharing sensitive keys.

This terraform module will create following resources:-

* Service account
* Workload Identity Pool
* Identity Provider AWS
* It will attach below policies to service account
  * roles/iam.securityReviewer
  * roles/bigquery.resourceViewer
  * roles/pubsub.subscriber
  * roles/viewer

# Requirements

These sections describe requirements for using this module.
The following dependencies must be available:

## 1. User & IAM

* The principal executing the TF should have following permissions

  * Service Account Admin
  * IAM Workload Identity Pool Admin
  * Project IAM Admin

## 2. Install terraform

## 3. Install Google Cloud SDK

## 4. Authenticate

```
Login with ADC
  - (Optional) "gcloud config configurations create < config name>" 
  - "gcloud auth application-default login"
  - "gcloud config set project < project Id >" # If user has multiple projects 
```

## 5. Use terraform module steps

* Create a <filename>.tf file, paste below codes and modify as needed.

```
module "create-gcp-cred" {
  source                    = "github.com/uptycslabs/terraform-google-iam-config"

  # Modify Project details reequired
  gcp_project_id            = "<GCP-project-id>"

  is_service_account_exists = false
  service_account_name      = "sa-for-uptycs"

  # AWS account details
  # Copy Uptycs's AWS Account ID and Role from Uptycs' UI.
  # Uptycs' UI: "Cloud"->"GCP"->"Integrations"->"PROJECT INTEGRATION"
  host_aws_account_id     = "<AWS account id>"
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
```

## Inputs


| Name                      | Description                                                                    | Type           | Required | Default                 |
| --------------------------- | -------------------------------------------------------------------------------- | ---------------- | ---------- | ------------------------- |
| gcp_project_id            | The GCP project id where you want to create resources.                         | `string`       | Yes      |                         |
| is_service_account_exists | Set this to true if you want to use existing service account.Else set to false | `bool`         |          | `false`                 |
| service_account_name      | The GCP service account name                                                   | `string`       |          | `"sa-for-uptycs"`       |
| host_aws_account_id       | Uptycs's AWS Account ID. Copy from Uptycs's GCP Integration Screen UI          | `string`       | Yes      |                         |
| host_aws_instance_role    | AWS role names of Uptycs - for identity binding                                | `list(string)` | Yes      |                         |
| integration_name          | Unique phrase used to name the resources                                       | `string`       |          | `"uptycs-int-20220101"` |

## Outputs


| Name                                | Description                                                                                                       |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| service-account-email               | The deployed Service Account's email-id                                                                           |
| command-to-generate-gcp-cred-config | For creating again same cred config json data ,please use command return by "command-to-generate-gcp-cred-config" |

## Notes

1. service account details

   - Set `is_service_account_exists = true`, if service account already exists. Specify existing service account name using `service_account_name`.
   - Set `is_service_account_exists = false` if service account does not exist. Provide a new name via `service_account_name`.
2. Workload Identity Pool is soft-deleted and permanently deleted after approximately 30 days.

   - Soft-deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`.  `integration_name` cannot be re-used until the WIP is permanently deleted.
   - After `terraform destroy`, same WIP can't be created again. Modify `integration_name` value if required.
3. `credentials.json` is created once. Use the command returned by `command-to-generate-gcp-cred-config` output to recreate.

## 6.Execute Terraform script to get credentials JSON

```
$ terraform init -upgrade
$ terraform plan
$ terraform apply # NOTE: Once terraform is successfully applied, it will create "credentials.json" file.
```
