variable "gcp_region" {
  type        = string
  description = "The GCP project region where planning to create resources "
  default     = "us-east1"
}

variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID where planning to create resources"
  default     = "test-project"
}

variable "gcp_project_number" {
  type        = string
  description = "The GCP project number"
}

variable "is_service_account_exists" {
  type        = bool
  description = "Set true if service account is already exists . "
  default     = false
}

variable "service_account_name" {
  type        = string
  description = "The GCP service account name, if service account is already exists then pass existing service account name else pass new name."
  default     = "sa-for-test"
}

variable "gcp_workload_identity" {
  type        = string
  description = "Workload Identity Pool to allow Uptycs integration via AWS federation."
  default     = "wip-test"
}

variable "gcp_wip_provider_id" {
  type        = string
  description = "Workload Identity Pool provider ID allow to add cloud provider."
  default     = "aws-id-provider-test"
}

variable "host_aws_account_id" {
  type        = string
  description = "The deployer host AWS account ID."
  default     = "11111111111111"
}

variable "host_aws_instance_role" {
  type        = list 
  description = "AWS role names of Uptycs - for identity binding"
}
