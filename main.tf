data "google_service_account" "myaccount" {
  count      = var.is_service_account_exists ? 1 : 0
  account_id = var.service_account_name
  project    = var.gcp_project_id
}

resource "google_iam_workload_identity_pool" "create_wip" {
  provider                  = google-beta
  project                   = var.gcp_project_id
  workload_identity_pool_id = var.gcp_workload_identity
  display_name              = var.gcp_workload_identity
  description               = "Workload Identity Pool to allow Uptycs integration via AWS federation"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "add_provider" {
  provider                           = google-beta
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.create_wip.workload_identity_pool_id
  workload_identity_pool_provider_id = var.gcp_wip_provider_id
  aws {
    account_id = var.host_aws_account_id
  }
}

resource "google_service_account" "sa_for_cloudquery" {
  count        = var.is_service_account_exists ? 0 : 1
  project      = var.gcp_project_id
  account_id   = var.service_account_name
  display_name = var.service_account_name
  description  = "Service Account for Intergration"
}

resource "google_project_iam_member" "bind_security_viewer" {
  role    = "roles/iam.securityReviewer"
  project = var.gcp_project_id
  member  = var.is_service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_project_iam_member" "bind_resourceViewer" {
  role    = "roles/bigquery.resourceViewer"
  project = var.gcp_project_id
  member  = var.is_service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_project_iam_member" "bind_pubsub_subscriber" {
  role    = "roles/pubsub.subscriber"
  project = var.gcp_project_id
  member  = var.is_service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_project_iam_member" "bind_viewer" {
  role    = "roles/viewer"
  project = var.gcp_project_id
  member  = var.is_service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = var.is_service_account_exists == false ? "${google_service_account.sa_for_cloudquery[0].name}" : "${data.google_service_account.myaccount[0].name}"
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${var.host_aws_account_id}:assumed-role/${var.host_aws_instance_role}"
  ]
}

resource "null_resource" "cred_config_json" {
  provisioner "local-exec" {
    command     = "gcloud iam workload-identity-pools create-cred-config projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${var.is_service_account_exists == false ? google_service_account.sa_for_cloudquery[0].email : data.google_service_account.myaccount[0].email} --output-file=credentials.json --aws"
    interpreter = ["/bin/sh", "-c"]
  }
}
