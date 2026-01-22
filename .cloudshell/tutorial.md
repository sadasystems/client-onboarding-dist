# Migration Validator Launcher

Welcome. This tool will securely clone the SADA Migration Validator from our private repository.

## 1. Project Setup
Ensure you are authenticated to the correct project.

<walkthrough-project-setup></walkthrough-project-setup>

## 2. Review Installer (Step 1 of 2)
Before we fetch the private code, you may review the installer script below. 

It performs two actions:
1. Triggers Google Cloud authentication.
2. Fetches a secure token to clone the private repository.

**Installer Code:**
```bash
#!/bin/bash
# Fetches GitHub Token from Secret Manager & Clones Private Tools
SECRET_PROJECT_ID="550541627521" 
SECRET_NAME="workspace_migration_key"
PRIVATE_REPO_URL="[github.com/sadasystems/Client-Email-Migration-Precheck.git](https://github.com/sadasystems/Client-Email-Migration-Precheck.git)"
DEST_DIR="sada-private-tools"

echo ">> Initializing..."
gcloud config get-value project > /dev/null # Triggers Auth Popup

# Fetch Token
GIT_TOKEN=$(gcloud secrets versions access latest --secret="$SECRET_NAME" --project="$SECRET_PROJECT_ID")

# Clone Repo
git clone -q "https://$GIT_TOKEN@$PRIVATE_REPO_URL" "$DEST_DIR"