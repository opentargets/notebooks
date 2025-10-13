output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "project_number" {
  description = "GCP Project Number"
  value       = data.google_project.project.number
}

output "service_account_email" {
  description = "Email of the GitHub Actions service account - Add this to GitHub Secrets as GCP_SERVICE_ACCOUNT"
  value       = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  description = "Full resource name of the Workload Identity Provider - Add this to GitHub Secrets as GCP_WORKLOAD_IDENTITY_PROVIDER"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.notebooks.repository_id}"
}

output "github_secrets_summary" {
  description = "Summary of GitHub Secrets to add"
  value = <<-EOT
  
  ========================================
  GitHub Secrets Configuration
  ========================================
  
  Add these secrets to your GitHub repository:
  Repository: https://github.com/${var.github_repository}/settings/secrets/actions
  
  Secret 1: GCP_WORKLOAD_IDENTITY_PROVIDER
  Value:
    ${google_iam_workload_identity_pool_provider.github.name}
  
  Secret 2: GCP_SERVICE_ACCOUNT
  Value:
    ${google_service_account.github_actions.email}
  
  ========================================
  
  EOT
}

