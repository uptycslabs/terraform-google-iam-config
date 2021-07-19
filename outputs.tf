output "service-account-email" {
  description = "The deployed Service Account's email-id"
  value       = var.is_service_account_exists == false ? google_service_account.sa_for_cloudquery[0].email : data.google_service_account.myaccount[0].email
}

output "command-to-generate-gcp-cred-config" {
  value = "gcloud iam workload-identity-pools create-cred-config projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${var.is_service_account_exists == false ? google_service_account.sa_for_cloudquery[0].email : data.google_service_account.myaccount[0].email} --output-file=credentials.json --aws"
}
