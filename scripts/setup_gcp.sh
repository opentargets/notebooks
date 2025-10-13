#!/bin/bash
# Script to set up GCP for GitHub Actions notebook testing
# This script configures:
# - Workload Identity for authentication
# - Cloud Run, Artifact Registry, and other compute permissions
# - Service account with necessary roles
#
# Run this script once to configure your GCP project

set -e

# Configuration
PROJECT_ID="open-targets-eu-dev"
SERVICE_ACCOUNT_NAME="github-actions-notebooks"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
WORKLOAD_IDENTITY_POOL="github-pool"
WORKLOAD_IDENTITY_PROVIDER="github-provider"
GITHUB_REPO="opentargets/notebooks"  # Update with your actual repo
REGION="europe-west1"

echo "=========================================="
echo "GCP Setup for Notebook Testing"
echo "=========================================="
echo ""
echo "Project: $PROJECT_ID"
echo "GitHub Repo: $GITHUB_REPO"
echo "Service Account: $SERVICE_ACCOUNT_EMAIL"
echo "Region: $REGION"
echo ""

# Check if user is authenticated
echo "→ Checking authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "✗ Error: Not authenticated with gcloud."
    echo "  Please run 'gcloud auth login' first."
    exit 1
fi
echo "✓ Authenticated"
echo ""

# Set project
echo "→ Setting project..."
gcloud config set project $PROJECT_ID
echo "✓ Project set"
echo ""

# Enable required APIs
echo "→ Enabling required APIs..."
echo "  - IAM Credentials API"
gcloud services enable iamcredentials.googleapis.com
echo "  - IAM API"
gcloud services enable iam.googleapis.com
echo "  - Cloud Resource Manager API"
gcloud services enable cloudresourcemanager.googleapis.com
echo "  - Cloud Build API"
gcloud services enable cloudbuild.googleapis.com
echo "  - Cloud Run API"
gcloud services enable run.googleapis.com
echo "  - Artifact Registry API"
gcloud services enable artifactregistry.googleapis.com
echo "  - Compute Engine API"
gcloud services enable compute.googleapis.com
echo "  - Cloud Logging API"
gcloud services enable logging.googleapis.com
echo "✓ APIs enabled"
echo ""

# Create service account if it doesn't exist
echo "→ Creating service account..."
if ! gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL &> /dev/null; then
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="GitHub Actions - Notebook Tests"
    echo "✓ Service account created"
else
    echo "✓ Service account already exists"
fi
echo ""

# Grant permissions to the service account
echo "→ Granting IAM permissions to service account..."
echo "  - Storage Object Viewer (for data access)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/storage.objectViewer" \
    --condition=None

echo "  - Cloud Run Admin (for job management)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/run.admin" \
    --condition=None

echo "  - Artifact Registry Admin (for Docker images)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/artifactregistry.admin" \
    --condition=None

echo "  - Cloud Build Editor (for building images)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/cloudbuild.builds.editor" \
    --condition=None

echo "  - Service Account User (for Cloud Run execution)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/iam.serviceAccountUser" \
    --condition=None

echo "  - Logging Viewer (for log access)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/logging.viewer" \
    --condition=None

echo "✓ IAM permissions granted"
echo ""

# Create Workload Identity Pool if it doesn't exist
echo "→ Creating Workload Identity Pool..."
if ! gcloud iam workload-identity-pools describe $WORKLOAD_IDENTITY_POOL \
    --location=global &> /dev/null; then
    gcloud iam workload-identity-pools create $WORKLOAD_IDENTITY_POOL \
        --location=global \
        --display-name="GitHub Actions Pool"
    echo "✓ Workload Identity Pool created"
else
    echo "✓ Workload Identity Pool already exists"
fi
echo ""

# Create Workload Identity Provider if it doesn't exist
echo "→ Creating Workload Identity Provider..."
if ! gcloud iam workload-identity-pools providers describe $WORKLOAD_IDENTITY_PROVIDER \
    --location=global \
    --workload-identity-pool=$WORKLOAD_IDENTITY_POOL &> /dev/null; then
    gcloud iam workload-identity-pools providers create-oidc $WORKLOAD_IDENTITY_PROVIDER \
        --location=global \
        --workload-identity-pool=$WORKLOAD_IDENTITY_POOL \
        --issuer-uri="https://token.actions.githubusercontent.com" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
        --attribute-condition="assertion.repository=='${GITHUB_REPO}'"
    echo "✓ Workload Identity Provider created"
else
    echo "✓ Workload Identity Provider already exists"
fi
echo ""

# Allow the GitHub Actions to impersonate the service account
echo "→ Binding service account to Workload Identity..."
gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL}/attribute.repository/${GITHUB_REPO}"
echo "✓ Service account bound to Workload Identity"
echo ""

# Create Artifact Registry repository
echo "→ Creating Artifact Registry repository..."
if gcloud artifacts repositories create notebooks \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker images for notebook testing" 2>/dev/null; then
    echo "✓ Artifact Registry repository created"
else
    echo "✓ Artifact Registry repository already exists"
fi
echo ""

# Get the Workload Identity Provider resource name
WORKLOAD_IDENTITY_PROVIDER_FULL=$(gcloud iam workload-identity-pools providers describe $WORKLOAD_IDENTITY_PROVIDER \
    --location=global \
    --workload-identity-pool=$WORKLOAD_IDENTITY_POOL \
    --format="value(name)")

echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "The service account has been configured with permissions for:"
echo "  ✓ Workload Identity authentication from GitHub Actions"
echo "  ✓ Building and pushing Docker images to Artifact Registry"
echo "  ✓ Creating and executing Cloud Run jobs"
echo "  ✓ Reading logs from Cloud Logging"
echo "  ✓ Accessing GCS data (if needed)"
echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "Add the following secrets to your GitHub repository:"
echo "  → https://github.com/${GITHUB_REPO}/settings/secrets/actions"
echo ""
echo "Secret 1: GCP_WORKLOAD_IDENTITY_PROVIDER"
echo "Value:"
echo "  $WORKLOAD_IDENTITY_PROVIDER_FULL"
echo ""
echo "Secret 2: GCP_SERVICE_ACCOUNT"
echo "Value:"
echo "  $SERVICE_ACCOUNT_EMAIL"
echo ""
echo "After adding these secrets, you can trigger the workflow:"
echo "  → https://github.com/${GITHUB_REPO}/actions"
echo ""

