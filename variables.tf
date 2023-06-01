variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID where planning to create resources"
}


variable "service_account_exists" {
  type        = bool
  description = "Set true if service account is already exists . "
  default     = false
}

variable "windows_interpreter" {
  type        = bool
  description = "Set to true if using Windows PowerShell set to false if using cmd. Ignore if on Linux or Mac"
  default     = false
}

variable "service_account_name" {
  type        = string
  description = "The GCP service account name, if service account is already exists then pass existing service account name else pass new name."
  default     = "sa-for-test"
}

variable "integration_name" {
  type        = string
  description = "Unique phrase used to name the resources"
  default     = "uptycs-int-20220101"
}


variable "host_aws_account_id" {
  type        = string
  description = "AWS account ID of Uptycs - for federated identity"
}

variable "host_aws_instance_roles" {
  type        = list 
  description = "AWS role names of Uptycs - for identity binding"
}
