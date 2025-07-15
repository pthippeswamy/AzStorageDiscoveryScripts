# Get the directory of the current script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define paths
$configPath = Join-Path $scriptDir "config.txt"
$logPath = Join-Path $scriptDir "DiscoveryMigrate.log"

# Read config values
Get-Content $configPath | ForEach-Object {
    $parts = $_ -split '='
    if ($parts.Length -eq 2) {
        Set-Variable -Name $parts[0].Trim() -Value $parts[1].Trim()
    }
}

# Logging function
function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logPath -Append
}

# Log events to the log file
Log "--------------------------------------------------START----------------------------------------------------------"
Log "Starting script..."
Log "Tenant ID: $targetTenantId"
Log "Subscription ID: $subscriptionId"
Log "Resource Group: $resourceGroup"
Log "Resource name: $resourceName"

$apiVersionOld = "2025-04-01-preview"
$apiVersionNew = "2025-06-01-preview"


# Get access token using Azure CLI
$token = (az account get-access-token --query accessToken -o tsv)
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

# Step 1: Get the existing resource using 04-01
$getUrl = "https://management.azure.com/subscriptions/" +$subscriptionId+ "/resourceGroups/" + $resourceGroup+"/providers/Microsoft.StorageDiscovery/storageDiscoveryWorkspaces/" +$resourceName+ "?api-version=" + $apiVersionOld +""

Write-Host "URL called: $getUrl"

$asdw = Invoke-RestMethod -Uri $getUrl -Headers $headers -Method Get

Write-Host "Response: $asdw"

$location = $asdw.location
$properties = $asdw.properties
$tags = $asdw.tags

Write-Host "Location: $location, properties: $properties, tags: $tags"

    Log "Processing resource: $name"
    Log "Location: $location"
    Log "Original Properties: $properties"

    # Step 3 - Clean up the properties before creating new resource with same settings using 06 version
    if ($asdw.properties.PSObject.Properties.Name -contains "provisioningState") {
        $asdw.properties.PSObject.Properties.Remove("provisioningState")
    }
    
    Log "JSON after removing provisioning state::"
    Log "New Properties: $properties"

    if ($asdw.properties.PSObject.Properties.Name -contains "discoveryScopes") {
        $scopesValue = $asdw.properties.discoveryScopes
        $asdw.properties.PSObject.Properties.Remove("discoveryScopes")
        $asdw.properties | Add-Member -MemberType NoteProperty -Name "scopes" -Value $scopesValue
        Log "Adding member scopes to properties"
    }
    
    if ($asdw.properties.PSObject.Properties.Name -contains "discoveryScopeLevels") {
        $scopesLevelValue = $asdw.properties.discoveryScopeLevels
        $asdw.properties.PSObject.Properties.Remove("discoveryScopeLevels")
        $asdw.properties | Add-Member -MemberType NoteProperty -Name "workspaceRoots" -Value $scopesLevelValue
        Log "Adding member workspaceRoots to properties"
    }

    # Rename workspaceState if it exists
    if ($asdw.properties.PSObject.Properties.Name -contains "workspaceState") {
        $asdw.properties.PSObject.Properties.Remove("workspaceState")
        Log "Removed member workspaceState from properties"
    }

    # Remove exportState if it exists
    if ($asdw.properties.PSObject.Properties.Name -contains "exportState") {
        $asdw.properties.PSObject.Properties.Remove("exportState")
        Log "Removed member exportState from properties"
    }

    # Step 4: Create new ASDW resource appending 06-01 to the exisiting name
    $newName = $asdw.name + "-060125"

# Step 2: Create the new resource using 06-01
$createUrl = "https://management.azure.com/subscriptions/" +$subscriptionId + "/resourceGroups/" + $resourceGroup+"/providers/Microsoft.StorageDiscovery/storageDiscoveryWorkspaces/"+$newName + "?api-version=" + $apiVersionNew+ ""
$body = @{
    location = $location
    tags = $tags
    properties = $asdw.properties
} | ConvertTo-Json -Depth 10

Write-Host "Creating new resource with 06-01 API..."
Invoke-RestMethod -Uri $createUrl -Headers $headers -Method Put -Body $body

# Step 3: Delete the original resource using 04-01
$deleteUrl = "https://management.azure.com/subscriptions/" +$subscriptionId +"/resourceGroups/" + $resourceGroup + "/providers/Microsoft.StorageDiscovery/storageDiscoveryWorkspaces/" + $resourceName + "?api-version=" + $apiVersionOld + ""
Write-Host "Deleting original 04-01 resource..."
Invoke-RestMethod -Uri $deleteUrl -Headers $headers -Method Delete

Write-Host "Migration complete for resource: $resourceName"