variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "open-targets-eu-dev"
}

variable "region" {
  description = "GCP Region for resources"
  type        = string
  default     = "europe-west1"
}

variable "github_repository" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string
  default     = "opentargets/notebooks"
}

variable "service_account_name" {
  description = "Name of the service account for GitHub Actions"
  type        = string
  default     = "github-actions-notebooks"
}

variable "workload_identity_pool_id" {
  description = "ID of the Workload Identity Pool"
  type        = string
  default     = "github-pool"
}

variable "workload_identity_provider_id" {
  description = "ID of the Workload Identity Provider"
  type        = string
  default     = "github-provider"
}

variable "artifact_registry_repository" {
  description = "Name of the Artifact Registry repository for Docker images"
  type        = string
  default     = "notebooks"
}

