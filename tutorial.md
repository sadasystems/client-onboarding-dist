# Insight Migration Validator

## 1. Welcome & Overview
**Welcome to the Insight Migration Pre-Flight Check.**

You are about to run an interactive security validator to establish a **secure baseline** for your Workspace Migration project.

**What this tool does:**
1.  **Audits** your selected project for security risks (e.g., Open Firewalls).
2.  **Configures** missing secure infrastructure (e.g., Cloud NATs, IAP Tunnels) upon your approval.
3.  **Reports** the final compliance status for the migration.

**How to run commands:**
 throughout this tutorial, you will see code blocks with two buttons in the top-right corner:
* **Copy to Cloud Shell (>_):** This types the command into your terminal window automatically. **You must still press `Enter` on your keyboard to execute it.**
* **Copy to Clipboard:** Copies the text so you can paste it manually.

**Click "Next" to begin.**

## 2. Project Selection
**Select your Migration Project.**

We need to identify which Google Cloud Project will host the migration infrastructure. **You should have already created this project.**

**Action Required:**
1.  Click the dropdown menu below.
2.  Select the **existing project** you intend to use for the Workspace Migration.
3.  **Do not create a new project.** If you have not created a project yet, please do so in the Console before proceeding.

* **Tip:** If you don't see your specific project listed, ensure you are signed in with the correct account or check the main project selector in the top-blue header of the window, if it is showing. You can also ignore the 'create a new project' link as that is a default tutorial snippet.

<walkthrough-project-setup></walkthrough-project-setup>

## 3. Review Installer (Step 1 of 2)
**Transparency Check & Troubleshooting**

Before we download the private tools, you should know exactly what is running. The generic installer script (`bootstrap.sh`) is visible below.

**It performs just two actions:**
1.  **Authenticates:** It asks Google "Who is running this?" (You).
2.  **Downloads:** It uses your identity to open an Insight Secret and fetch the secure tools.

**⚠️ Important Permission Note:**
If you encounter errors (e.g., `Permission Denied` or `Secret Access Failed`) when running this script:
* **Verify Identity:** Ensure you are running this session as the correct Principal/Email that was authorized to perform this script.
* **Contact Support:** If you are using the correct identity but still face issues, **please talk to Insight for help** before attempting to run the script again.

**Review the code:**
```bash
#!/bin/bash
# Insight Bootstrap Loader
# 1. Triggers Google Cloud Auth Popup
gcloud config get-value project > /dev/null

# 2. Fetches Secure Key from Secret Manager
KEY_FILE="/dev/shm/migration_key"
gcloud secrets versions access latest \
    --secret="workspace_migration_key" \
    --project="550541627521" > "$KEY_FILE"

# 3. Clones Private Repo using that Key
export GIT_SSH_COMMAND="ssh -i $KEY_FILE -o IdentitiesOnly=yes"
git clone -q "git@github.com:sadasystems/Client-Email-Migration-Precheck.git" "sada-private-tools"
```

*Click "Next" if you are ready to run this installer.*

## 4. Run Installer
**Let's fetch the tools.**

Click the button below to execute the installer.

**Important:**
* A popup may appear asking **"Authorize this session?"**
* Please click **Authorize**. This grants the Cloud Shell permission to read the secret on your behalf.

```bash
chmod +x bootstrap.sh && ./bootstrap.sh
```

**Wait until you see:**
> `>> Download Complete.`
> `>> Ready for Review.`

## 5. Review Validator (Step 2 of 2)
**Success! The private tools have been downloaded.**

You now have a new folder called `sada-private-tools`. Inside is the actual logic script: `WorkspaceMigrationPrecheck.sh`.

**Code Review:**
Before executing the script on your project, you may review it to see exactly what commands it runs (e.g., `gcloud compute firewall-rules list`).

**Click to print the code to your terminal:**
```bash
cat sada-private-tools/WorkspaceMigrationPrecheck.sh | less
```
*(Press `q` on your keyboard to exit the review viewer)*

## 6. Execute Validator
**It is time to audit your environment.**

We will now run the interactive tool against your selected project.

**What to expect:**
1.  **Select Persona:** Choose option **"2" (Client Lead)** to enable remediation features.
2.  **Interactive Prompts:** The script will ask you questions like *"Do you want to delete this open firewall rule?"*. Type `y` (Yes) or `n` (No).

**Run the command:**
```bash
cd sada-private-tools
chmod +x WorkspaceMigrationPrecheck.sh
./WorkspaceMigrationPrecheck.sh
```

## 7. Finish & Report
**Validation Complete.**

The script has generated a JSON report file (e.g., `my-project-Preflight-Checklist.json`). You should download this file and send it to your Insight Engagement Manager.

**Click to download:**
```bash
cloudshell download *-Preflight-Checklist.json
```

**Next Steps:**
* If you applied fixes (e.g., created a NAT), you can re-run the script to verify everything passes.
* Otherwise, you may close this window.
