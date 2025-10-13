# Data source to get project number
data "google_project" "project" {
  project_id = var.project_id
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
  ])

  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Create service account for GitHub Actions
resource "google_service_account" "github_actions" {
  account_id   = var.service_account_name
  display_name = "GitHub Actions - Notebook Tests"
  description  = "Service account for GitHub Actions to run notebook tests on GCP"
  project      = var.project_id

  depends_on = [google_project_service.required_apis]
}

# Grant IAM roles to the service account
resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset([
    "roles/storage.objectViewer",       # Access to GCS data
    "roles/run.admin",                  # Manage Cloud Run jobs
    "roles/artifactregistry.admin",     # Push/pull Docker images
    "roles/cloudbuild.builds.editor",   # Build Docker images
    "roles/iam.serviceAccountUser",     # Execute as service account
    "roles/logging.viewer",             # Read logs
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"

  depends_on = [google_service_account.github_actions]
}

# Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
  project                   = var.project_id

  depends_on = [google_project_service.required_apis]
}

# Create Workload Identity Provider for GitHub OIDC
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "GitHub Provider"
  description                        = "OIDC provider for GitHub Actions"
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == '${var.github_repository}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_iam_workload_identity_pool.github]
}

# Allow GitHub Actions to impersonate the service account
resource "google_service_account_iam_member" "github_workload_identity" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"

  depends_on = [
    google_iam_workload_identity_pool_provider.github,
    google_service_account.github_actions,
  ]
}

# Create Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "notebooks" {
  location      = var.region
  repository_id = var.artifact_registry_repository
  description   = "Docker images for notebook testing"
  format        = "DOCKER"
  project       = var.project_id

  depends_on = [google_project_service.required_apis]
}

