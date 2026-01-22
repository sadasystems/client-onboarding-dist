#!/bin/bash

# ==============================================================================
# SADA MIGRATION LAUNCHER (SSH VERSION)
# Purpose: Uses an SSH Key from Secret Manager to clone the Private Repo
# ==============================================================================

# --- Configuration ---
# 1. Secret Location
SECRET_PROJECT_ID="550541627521" 
SECRET_NAME="workspace_migration_key"

# 2. Private Repository (SSH Format)
#    Note: Must use git@github.com:ORG/REPO.git
PRIVATE_REPO_URL="git@github.com:sadasystems/Client-Email-Migration-Precheck.git"
DEST_DIR="sada-private-tools"

# --- Main Logic ---
echo -e "\033[0;34m>> Initializing SADA Migration Tooling...\033[0m"

# 1. Trigger Cloud Shell Authorization
#    We run a simple read command. If the session isn't authorized, 
#    Cloud Shell intercepts this and shows the "Authorize" popup.
echo ">> Verifying session permissions..."
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$CURRENT_PROJECT" ]]; then
    # Fallback: If the popup didn't work or was declined, force a login prompt.
    echo ">> Authorization required. Please click 'Authorize' in the popup..."
    gcloud auth login --quiet
fi

echo ">> Authenticating with Project ${SECRET_PROJECT_ID}..."

# 2. Setup SSH Key from Secret
#    We try to use shared memory (/dev/shm) so the key never hits the physical disk.
KEY_FILE="/dev/shm/migration_key"
[[ ! -d /dev/shm ]] && KEY_FILE="$HOME/.ssh/migration_key_temp"

#    Fetch the SSH Key content
gcloud secrets versions access latest \
    --secret="$SECRET_NAME" \
    --project="$SECRET_PROJECT_ID" > "$KEY_FILE"

#    Verify we got data
if [[ ! -s "$KEY_FILE" ]]; then
    echo -e "\033[0;31m[ERROR] Secret Access Failed.\033[0m"
    echo "Could not retrieve the SSH Key from Secret Manager."
    echo "Please ensure your email has 'Secret Manager Secret Accessor' permission."
    rm -f "$KEY_FILE"
    exit 1
fi

# 3. Secure the Key (Critical step for SSH)
#    SSH will reject the key if permissions are too open.
mkdir -p "$HOME/.ssh"
chmod 600 "$KEY_FILE"

# 4. Trust GitHub 
#    Adds GitHub's public fingerprint to known_hosts to prevent the "Are you sure?" prompt.
ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null

# 5. Clone the Private Repo
echo ">> Cloning Secure Repository..."
rm -rf "$DEST_DIR"

#    We use the GIT_SSH_COMMAND environment variable to force git to use 
#    our temporary key file instead of the default user keys.
export GIT_SSH_COMMAND="ssh -i $KEY_FILE -o IdentitiesOnly=yes"

if git clone -q "$PRIVATE_REPO_URL" "$DEST_DIR"; then
    echo -e "\033[0;32m>> Download Complete.\033[0m"
    echo -e "\033[0;32m>> Ready for Review.\033[0m"
else
    echo -e "\033[0;31m[ERROR] Clone failed.\033[0m"
    echo "Please verify the SSH Key in Secret Manager is valid and has access to the repo."
fi

# 6. Cleanup
#    Delete the private key immediately after the clone finishes.
rm -f "$KEY_FILE"