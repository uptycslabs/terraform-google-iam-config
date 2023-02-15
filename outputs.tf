output "service-account-email" {
  description = "The deployed Service Account's email-id"
  value       = var.service_account_exists == false ? google_service_account.sa_for_cloudquery[0].email : data.google_service_account.myaccount[0].email
}

output "command-to-generate-gcp-cred-config" {
  value = "gcloud iam workload-identity-pools create-cred-config projects/${data.google_project.my_host_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.add_provider.workload_identity_pool_provider_id} --service-account=${var.service_account_exists == false ? google_service_account.sa_for_cloudquery[0].email : data.google_service_account.myaccount[0].email} --output-file=credentials.json --aws"
}
