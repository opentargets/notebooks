# Terraform Configuration for Notebook Testing

Infrastructure as Code for automated notebook testing on GCP Cloud Run with GitHub Actions.

## What It Creates

- **Service Account** with minimal IAM roles (4 roles, least privilege)
- **Workload Identity Federation** for secure, keyless GitHub authentication
- **Artifact Registry** repository for Docker images
- **Enabled APIs**: Cloud Run, Artifact Registry, IAM, Logging

## Quick Start

```bash
# 1. Authenticate to GCP
gcloud auth application-default login

# 2. Initialize Terraform
cd terraform
terraform init

# 3. Review changes
terraform plan

# 4. Apply configuration
terraform apply

# 5. Copy outputs to GitHub Secrets
terraform output github_secrets_summary
```

Add the two secrets to your GitHub repository settings.

## IAM Roles (Least Privilege)

| Role | Purpose | Why Not Broader |
|------|---------|----------------|
| `run.developer` | Manage Cloud Run jobs | Not `run.admin` (no IAM policy access) |
| `artifactregistry.writer` | Push Docker images | Not `admin` (no repo deletion) |
| `iam.serviceAccountUser` | Execute as service account | Required minimum for Cloud Run |
| `logging.viewer` | Read Cloud Run logs | Read-only access |

## Configuration

Default values in `variables.tf` work out-of-the-box. Override in `terraform.tfvars` if needed

## Common Commands

```bash
terraform plan              # Preview changes
terraform apply             # Apply changes
terraform output            # Show outputs
terraform destroy           # Remove all resources
```

## Outputs

After `terraform apply`:
- `service_account_email` → GitHub Secret: `GCP_SERVICE_ACCOUNT`
- `workload_identity_provider` → GitHub Secret: `GCP_WORKLOAD_IDENTITY_PROVIDER`
