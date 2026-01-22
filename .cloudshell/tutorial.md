# SADA Migration Validator

## 1. Welcome & Overview
**Welcome to the SADA Migration Pre-Flight Check.**

You are about to run an interactive security validator that checks your Google Cloud project against SADA's migration standards.

**What this tool does:**
1.  **Audits** your environment for security risks (Open Firewalls, Public IPs).
2.  **Builds** missing infrastructure (Cloud NATs, IAP Tunnels) if you approve.
3.  **Reports** compliance status in a JSON file.

**How it works:**
* You are currently in a **Public Launcher**.
* We will use a secure script to download the **Private SADA Tools** into this temporary session.
* You will review the code, run it, and download the results.

**Click "Next" to begin.**

## 2. Project Selection
**First, we need to know where to run these checks.**

In Google Cloud, all resources live inside a "Project". Please ensure the correct Project ID is selected in the dropdown below.

<walkthrough-project-setup></walkthrough-project-setup>

* **Tip:** If you don't see your project, check the dropdown in the top-blue bar of the console window.

## 3. Review Installer (Step 1 of 2)
**Transparency Check**

Before we download the private tools, you should know exactly what is running. The generic installer script (`bootstrap.sh`) is visible below.

**It performs just two actions:**
1.  **Authenticates:** It asks Google "Who is running this?" (You).
2.  **Downloads:** It uses your identity to open a SADA Secret and fetch the secure tools.

**Review the code:**
```bash
#!/bin/bash
# SADA Bootstrap Loader
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

We will now run the interactive tool.

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

The script has generated a JSON report file (e.g., `my-project-Preflight-Checklist.json`). You should download this file and send it to your SADA Engagement Manager.

**Click to download:**
```bash
cloudshell download *-Preflight-Checklist.json
```

**Next Steps:**
* If you applied fixes (e.g., created a NAT), you can re-run the script to verify everything passes.
* Otherwise, you may close this window.