#!/bin/bash

# ==============================================================================
# SADA MIGRATION LAUNCHER (SSH VERSION)
# Purpose: Uses an SSH Key from Secret Manager to clone the Private Repo
# ==============================================================================

# --- Configuration ---
SECRET_PROJECT_ID="550541627521" 
SECRET_NAME="workspace_migration_key"
# NOTE: We switched the URL to the SSH format (git@github.com:...)
PRIVATE_REPO_URL="git@github.com:sadasystems/Client-Email-Migration-Precheck.git"
DEST_DIR="sada-private-tools"

# --- Main Logic ---
echo -e "\033[0;34m>> Initializing SADA Migration Tooling...\033[0m"

# 1. Trigger Cloud Shell Authorization
echo ">> Verifying session permissions..."
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$CURRENT_PROJECT" ]]; then
    echo "Please click 'Authorize' in the popup..."
    gcloud auth login --quiet
fi

echo ">> Authenticating with Project ${SECRET_PROJECT_ID}..."

# 2. Setup SSH Key from Secret
# We use /dev/shm (shared memory) if available so the key never touches the physical disk
KEY_FILE="/dev/shm/migration_key"
[[ ! -d /dev/shm ]] && KEY_FILE="$HOME/.ssh/migration_key_temp"

# Fetch the SSH Key
gcloud secrets versions access latest \
    --secret="$SECRET_NAME" \
    --project="$SECRET_PROJECT_ID" > "$KEY_FILE"

# Check if we actually got a key (file size > 0)
if [[ ! -s "$KEY_FILE" ]]; then
    echo -e "\033[0;31m[ERROR] Secret Access Failed.\033[0m"
    echo "Could not retrieve the SSH Key from Secret Manager."
    rm -f "$KEY_FILE"
    exit 1
fi

# 3. Secure the Key (Critical for SSH)
mkdir -p "$HOME/.ssh"
chmod 600 "$KEY_FILE"

# 4. Trust GitHub (Prevents "Are you sure?" prompt)
ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null

# 5. Clone the Private Repo
echo ">> Cloning Secure Repository..."
rm -rf "$DEST_DIR"

# We use GIT_SSH_COMMAND to force git to use our specific temp key
export GIT_SSH_COMMAND="ssh -i $KEY_FILE -o IdentitiesOnly=yes"

if git clone -q "$PRIVATE_REPO_URL" "$DEST_DIR"; then
    echo -e "\033[0;32m>> Download Complete.\033[0m"
    echo -e "\033[0;32m>> Ready for Review.\033[0m"
else
    echo -e "\033[0;31m[ERROR] Clone failed.\033[0m"
    echo "Please verify the SSH Key in Secret Manager matches the Deploy Key in GitHub."
fi

# 6. Cleanup (Security)
# Delete the key immediately after use
rm -f "$KEY_FILE"