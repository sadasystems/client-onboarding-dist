#!/bin/bash

# ==============================================================================
# SADA MIGRATION LAUNCHER
# Purpose: Fetches GitHub Token from Secret Manager & Clones Private Tools
# ==============================================================================

# --- Configuration ---
# The Project ID where the Secret is stored (Hardcoded)
SECRET_PROJECT_ID="550541627521" 
SECRET_NAME="workspace_migration_key"

# The Private Repository to clone
PRIVATE_REPO_URL="github.com/sadasystems/Client-Email-Migration-Precheck.git"
DEST_DIR="sada-private-tools"

# --- Main Logic ---
echo -e "\033[0;34m>> Initializing SADA Migration Tooling...\033[0m"

# 1. Trigger Cloud Shell Authorization
# We run a harmless command to force the 'Authorize' popup if needed.
echo ">> Verifying session permissions..."
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$CURRENT_PROJECT" ]]; then
    # If the harmless command failed, we assume they declined auth or need login
    echo -e "\033[0;31m[ERROR] Unable to authenticate.\033[0m"
    echo "Please ensure you clicked 'Authorize' in the Cloud Shell popup."
    # We attempt one explicit login prompt as a fallback.
    gcloud auth login --quiet
fi

echo ">> Authenticating with Project ${SECRET_PROJECT_ID}..."

# 2. Fetch the GitHub Token
# This uses the user's active session to access the Secret
GIT_TOKEN=$(gcloud secrets versions access latest \
    --secret="$SECRET_NAME" \
    --project="$SECRET_PROJECT_ID")

if [[ -z "$GIT_TOKEN" ]]; then
    echo -e "\033[0;31m[ERROR] Secret Access Failed.\033[0m"
    echo "Could not retrieve the GitHub token."
    echo "Ensure your email has 'Secret Manager Secret Accessor' permission on project ${SECRET_PROJECT_ID}."
    exit 1
fi

# 3. Clone the Private Repo
echo ">> Cloning Secure Repository..."
# Remove any existing directory to ensure a clean clone
rm -rf "$DEST_DIR"

# Clone using the token (Quietly, to protect the token from logs)
if git clone -q "https://$GIT_TOKEN@$PRIVATE_REPO_URL" "$DEST_DIR"; then
    echo -e "\033[0;32m>> Download Complete.\033[0m"
    echo -e "\033[0;32m>> Ready for Review.\033[0m"
else
    echo -e "\033[0;31m[ERROR] Clone failed.\033[0m"
    echo "Please verify you have access to the repository."
    exit 1
fi