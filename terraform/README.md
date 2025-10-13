# Terraform Configuration for Notebook Testing Infrastructure

This directory contains Terraform configuration to set up the GCP infrastructure required for automated notebook testing via GitHub Actions.

## What It Creates

This Terraform configuration provisions:

1. **APIs**: Enables required GCP APIs
   - IAM, Cloud Resource Manager
   - Cloud Build, Cloud Run
   - Artifact Registry, Compute Engine, Logging

2. **Service Account**: `github-actions-notebooks@open-targets-eu-dev.iam.gserviceaccount.com`
   - With appropriate IAM roles for CI/CD operations

3. **Workload Identity Federation**:
   - Workload Identity Pool for GitHub Actions
   - OIDC Provider linked to your GitHub repository
   - Secure, keyless authentication

4. **Artifact Registry**: Docker repository for notebook test images

5. **IAM Bindings**: All necessary permissions for the service account

## Prerequisites

1. **Terraform**: Install from [terraform.io](https://www.terraform.io/downloads)
   ```bash
   # macOS
   brew install terraform
   
   # Or download from https://www.terraform.io/downloads
   ```

2. **GCP Authentication**: Authenticate with sufficient permissions
   ```bash
   gcloud auth application-default login
   ```

3. **GCP Permissions**: You need these roles in the project:
   - `roles/owner` or
   - `roles/editor` + `roles/iam.securityAdmin`

## Quick Start

### 1. Navigate to Terraform Directory
```bash
cd terraform
```

### 2. (Optional) Customize Variables
If you need to change default values:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Initialize Terraform
```bash
terraform init
```

This downloads the required providers and sets up the backend.

### 4. Review the Plan
```bash
terraform plan
```

Review what will be created. You should see:
- APIs to be enabled
- Service account to be created
- IAM bindings to be added
- Workload Identity Pool and Provider
- Artifact Registry repository

### 5. Apply the Configuration
```bash
terraform apply
```

Type `yes` when prompted. This will:
- Create all resources
- Output the GitHub secrets you need to add

### 6. Save the Outputs
After applying, Terraform will display:
```
Outputs:

github_secrets_summary = <<EOT
  ========================================
  GitHub Secrets Configuration
  ========================================
  
  Add these secrets to your GitHub repository:
  ...
EOT
```

Copy these values and add them to your GitHub repository secrets.

## Configuration Files

- `versions.tf` - Terraform and provider versions
- `variables.tf` - Input variables with defaults
- `main.tf` - Main infrastructure resources
- `outputs.tf` - Output values (GitHub secrets)
- `terraform.tfvars.example` - Example variables file
- `.gitignore` - Terraform-specific gitignore

## Variables

All variables have sensible defaults. Override them in `terraform.tfvars` if needed:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | `open-targets-eu-dev` |
| `region` | GCP Region | `europe-west1` |
| `github_repository` | GitHub repo (owner/repo) | `opentargets/notebooks` |
| `service_account_name` | Service account name | `github-actions-notebooks` |
| `workload_identity_pool_id` | Pool ID | `github-pool` |
| `workload_identity_provider_id` | Provider ID | `github-provider` |
| `artifact_registry_repository` | Registry name | `notebooks` |

## Outputs

After applying, you'll get these outputs:

- `service_account_email` - Add to GitHub as `GCP_SERVICE_ACCOUNT`
- `workload_identity_provider` - Add to GitHub as `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `artifact_registry_repository` - Docker registry URL
- `github_secrets_summary` - Formatted instructions for GitHub

## Common Commands

```bash
# Initialize (first time or after adding providers)
terraform init

# Format configuration files
terraform fmt

# Validate configuration
terraform validate

# Plan changes (dry run)
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Get specific output
terraform output service_account_email

# Destroy all resources (careful!)
terraform destroy
```

## Updating the Infrastructure

To update the infrastructure:

1. Modify the `.tf` files as needed
2. Run `terraform plan` to see what will change
3. Run `terraform apply` to apply changes
4. Commit the updated `.tf` files to git

## State Management

Terraform stores state in `terraform.tfstate` (local backend by default).

**For production**, consider using a remote backend:
```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "terraform/state"
  }
}
```

## Troubleshooting

### "Permission denied" errors
Ensure you have sufficient GCP permissions:
```bash
gcloud auth application-default login
gcloud config set project open-targets-eu-dev
```

### API not enabled
If you see "API not enabled" errors, wait a few minutes after `terraform apply` as API activation can take time.

### Already exists errors
If resources already exist from the bash script:
```bash
# Import existing resources
terraform import google_service_account.github_actions projects/open-targets-eu-dev/serviceAccounts/github-actions-notebooks@open-targets-eu-dev.iam.gserviceaccount.com

# Or destroy and recreate
./scripts/cleanup_gcp.sh  # If you create a cleanup script
terraform apply
```

## Migration from Bash Script

If you previously used `scripts/setup_gcp.sh`:

1. The Terraform configuration creates the same resources
2. You can either:
   - **Option A**: Import existing resources into Terraform state
   - **Option B**: Destroy old resources and let Terraform create new ones
3. The GitHub secrets remain the same

To import existing resources (advanced):
```bash
terraform import google_service_account.github_actions projects/open-targets-eu-dev/serviceAccounts/github-actions-notebooks@open-targets-eu-dev.iam.gserviceaccount.com
# ... import other resources as needed
```

## Security Best Practices

1. ✅ Never commit `.tfvars` files with sensitive data
2. ✅ Use Workload Identity Federation (no long-lived keys)
3. ✅ Review IAM permissions regularly
4. ✅ Use remote state with encryption for production
5. ✅ Enable state locking with remote backends

## Resources Created

After running `terraform apply`, check the GCP Console:

- **IAM & Admin** → Service Accounts → `github-actions-notebooks`
- **IAM & Admin** → Workload Identity Federation → `github-pool`
- **Artifact Registry** → `notebooks` repository
- **IAM & Admin** → IAM → Service account permissions

## Support

- Terraform Documentation: https://www.terraform.io/docs
- Google Provider Docs: https://registry.terraform.io/providers/hashicorp/google/latest/docs
- Workload Identity Federation: https://cloud.google.com/iam/docs/workload-identity-federation

## Next Steps

After applying Terraform:

1. ✅ Copy the output secrets to GitHub
2. ✅ Test the GitHub Actions workflow
3. ✅ Monitor first test run
4. ✅ Commit Terraform files to git (but not `.tfvars` or state!)

