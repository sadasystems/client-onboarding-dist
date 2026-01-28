# SADA Client Onboarding Launcher

This repository is the public entry point for the **SADA Migration Pre-Flight Validator**.

## Overview
This tool facilitates a secure, "Zero-Trust" deployment of migration tools. It uses your Google Cloud Identity to fetch a temporary access token, allowing you to clone and run our private validator without managing SSH keys or GitHub accounts.

## Quick Start

### 1. Launch Cloud Shell
Click the button below to launch the interactive validator in Google Cloud Shell.

### 2. Important: Trust the Repo
When the Cloud Shell window opens, a security dialog will appear. You **must** check the box for **"Trust repo"** and click **Confirm**. 

If this box is not checked, the interactive tutorial and the installer script will fail to load.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ide.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/sadasystems/client-onboarding-dist)
