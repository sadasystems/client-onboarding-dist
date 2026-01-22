# Migration Validator Launcher

Welcome. This tool will securely clone the SADA Migration Validator from our private repository.

## 1. Project Setup
Ensure you are authenticated to the correct project.

<walkthrough-project-setup></walkthrough-project-setup>

## 2. Review Installer (Step 1 of 2)
Before we fetch the private code, review the installer script (`bootstrap.sh`).
It will access a secured secret to authenticate the download.

<walkthrough-editor-open-file filePath="bootstrap.sh">
  Open bootstrap.sh
</walkthrough-editor-open-file>

*Click "Next" once you have verified the script.*

## 3. Run Installer
Execute the installer to fetch the private repository.

```bash
chmod +x bootstrap.sh && ./bootstrap.sh