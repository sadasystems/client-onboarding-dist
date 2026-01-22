#!/bin/bash

# ==============================================================================
# SADA MIGRATION LAUNCHER
# Purpose: Fetches GitHub Token from Secret Manager & Clones Private Tools
# ==============================================================================

# --- Configuration (Hardcoded) ---
# Project ID extracted from resource name: projects/550541627521/...
SECRET_PROJECT_ID="550541627521" 

# Secret Name provided
SECRET_NAME="workspace_migration_key"

# Your Private Repo URL
PRIVATE_REPO_URL="github.com/sadasystems/Client-Email-Migration-Precheck.git"

# Directory to clone into (Keeps the workspace clean)
DEST_DIR="sada-private-tools"

# --- Main Logic ---
echo -e "\033[0;34m>> Initializing SADA Migration Tooling...\033[0m"

# 1. Verify Authentication
# We check if the user has an active gcloud session
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "Error: No active Google Cloud session."
    echo "Please run 'gcloud auth login' and try again."
    exit 1
fi

echo ">> Authenticating with Project ${SECRET_PROJECT_ID}..."

# 2. Fetch the GitHub Token
# User needs 'Secret Manager Secret Accessor' role on the secret
GIT_TOKEN=$(gcloud secrets versions access latest \
    --secret="$SECRET_NAME" \
    --project="$SECRET_PROJECT_ID")

if [[ -z "$GIT_TOKEN" ]]; then
    echo -e "\033[0;31m[ERROR] Authentication failed.\033[0m"
    echo "Could not retrieve the GitHub token from Secret Manager."
    echo "Please ensure your email has 'Secret Manager Secret Accessor' permission."
    exit 1
fi

# 3. Clone the Private Repo
echo ">> Cloning Secure Repository..."

# Clean up any previous runs to ensure fresh code
rm -rf "$DEST_DIR"

# Clone using the token
# We use -q (quiet) to prevent the token from being printed in logs
if git clone -q "https://$GIT_TOKEN@$PRIVATE_REPO_URL" "$DEST_DIR"; then
    echo -e "\033[0;32m>> Download Complete.\033[0m"
    echo -e "\033[0;32m>> Ready for Review.\033[0m"
else
    echo -e "\033[0;31m[ERROR] Clone failed.\033[0m"
    echo "Please verify the GitHub Token has 'repo' scope and the repo URL is correct."
    exit 1
fi