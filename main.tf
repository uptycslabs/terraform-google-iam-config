data "google_service_account" "myaccount" {
  count      = var.service_account_exists ? 1 : 0
  account_id = var.service_account_name
  project    = var.gcp_project_id
}

data "google_project" "my_host_project" {
  project_id = var.gcp_project_id
}

resource "google_iam_workload_identity_pool" "create_wip" {
  provider                  = google-beta
  project                   = var.gcp_project_id
  workload_identity_pool_id = "wip-${var.integration_name}"
  display_name              = "wip-${var.integration_name}"
  description               = "Workload Identity Pool to allow Uptycs integration via AWS federation"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "add_provider" {
  provider                           = google-beta
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.create_wip.workload_identity_pool_id
  workload_identity_pool_provider_id = "idp-${var.integration_name}"
  aws {
    account_id = var.host_aws_account_id
  }
}

resource "google_service_account" "sa_for_cloudquery" {
  count        = var.service_account_exists ? 0 : 1
  project      = var.gcp_project_id
  account_id   = var.service_account_name
  display_name = var.service_account_name
  description  = "Service Account for Intergration"
}

resource "google_project_iam_member" "bind_security_viewer" {
  role    = "roles/iam.securityReviewer"
  project = var.gcp_project_id
  member  = var.service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_project_iam_member" "bind_resourceViewer" {
  role    = "roles/bigquery.resourceViewer"
  project = var.gcp_project_id
  member  = var.service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_project_iam_member" "bind_pubsub_subscriber" {
  role    = "roles/pubsub.subscriber"
  project = var.gcp_project_id
  member  = var.service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_project_iam_member" "bind_viewer" {
  role    = "roles/viewer"
  project = var.gcp_project_id
  member  = var.service_account_exists == false ? "serviceAccount:${google_service_account.sa_for_cloudquery[0].email}" : "serviceAccount:${data.google_service_account.myaccount[0].email}"
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = var.service_account_exists == false ? "${google_service_account.sa_for_cloudquery[0].name}" : "${data.google_service_account.myaccount[0].name}"
  role               = "roles/iam.workloadIdentityUser"
  members            = [for each in var.host_aws_instance_roles : format("principalSet://iam.googleapis.com/projects/%s/locations/global/workloadIdentityPools/%s/attribute.aws_role/arn:aws:sts::%s:assumed-role/%s", data.google_project.my_host_project.number, google_iam_workload_identity_pool.create_wip.workload_identity_pool_id, var.host_aws_account_id, each)]
}

resource "null_resource" "cred_config_json" {
  provisioner "local-exec" {
    command     = "gcloud iam workload-identity-pools create-cred-config projects/${data.google_project.my_host_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.add_provider.workload_identity_pool_provider_id} --service-account=${var.service_account_exists == false ? google_service_account.sa_for_cloudquery[0].email : data.google_service_account.myaccount[0].email} --output-file=credentials.json --aws"
  }
}