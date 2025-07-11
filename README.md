---
page_type: sample
name: AzStorageDiscoveryScripts
topic: sample
description: |
  AzStorageDiscoveryScripts has a simple script to migrate Storage Discovery resource created with API verison 2025-04-01-preview to Discovery resource of version 2025-06-01-preview.
languages:
  - powershell
products:
  - azure
  - azure-storage
  - azure-blob-storage
urlFragment: update-this-to-unique-url-stub
---

# AzStorageDiscoveryScripts

This PowerShell script automates the migration of Azure Storage Discovery Workspace (ASDW) resources from an older API version (`2025-04-01-preview`) to a newer version (`2025-06-01-preview`). It fetches the existing resource, modifies its properties to match the new schema, creates a new resource with the updated API version, and deletes the old one.

## Overview

The script performs the following steps:

1. Reads configuration values from a `config.txt` file.
2. Logs all actions to a `DiscoveryMigrate.log` file.
3. Downloads and extracts the latest ARMClient tool.
4. Authenticates with Azure using `az login`.
5. Fetches the existing ASDW resource.
6. Modifies the resource properties to match the new API schema.
7. Creates a new ASDW resource with the updated API version.
8. Deletes the old ASDW resource.

## Prerequisites

- PowerShell 7.5 or later
- Azure CLI installed and authenticated
- Internet access to download ARMClient
- Permissions to read/write ASDW resources in the specified subscription

## Configuration

Create a `config.txt` file in the same directory as the script with the following key-value pairs:
- targetTenantId 
- subscriptionId
- resourceGroup
- resourceName

Note: Do nto add any quotes around the values.

## Usage

1. Place the script and `config.txt` in the same directory.
2. Open PowerShell and navigate to the script directory.
3. Run the script:
   ```powershell
   .\Migrate-ASDW.ps1
   ```

## Logging
All actions and key events are logged to DiscoveryMigrate.log in the same directory as the script. This includes:

Start and end of the script
Resource fetch and transformation steps
Creation and deletion of resources
Any errors encountered

The script uses ARMClient.exe to interact with Azure Resource Manager APIs directly.
It replaces deprecated properties like discoveryScopes and discoveryScopeLevels with scopes and workspaceRoots.
Ensure the original ASDW resource is not in use before deletion.
Always review the log file for any issues or validation errors.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
