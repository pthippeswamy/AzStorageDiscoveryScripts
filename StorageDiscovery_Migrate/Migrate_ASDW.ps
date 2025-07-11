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
Log "ASDW name: $resourceName"

$apiVersionOld = "2025-04-01-preview"
$apiVersionNew = "2025-06-01-preview"

# Step 1: Download and extract ARMClient
$armClientZip = "$env:TEMP\ARMClient.zip"
$armClientPath = "$env:TEMP\ARMClient"
$armClientExe = Join-Path $armClientPath "ARMClient.exe"

Write-Host "Downloading ARMClient..."
Log "Downloading ARMClient..."
Invoke-WebRequest -Uri "https://github.com/projectkudu/ARMClient/releases/latest/download/ARMClient.zip" -OutFile $armClientZip

Write-Host "Extracting ARMClient..."
Log "Extracting ARMClient..."
Expand-Archive -Path $armClientZip -DestinationPath $armClientPath -Force

Write-Host "Downloaded ARM client to $armClientPath"
Log "Downloaded ARM client to $armClientPath"
 
az login --tenant $targetTenantId
az account set --subscription $subscriptionId

# Step 2: Get the ASDW resource whose name, SubID, RG are all porovided in config file
$fetchURI = "https://management.azure.com/subscriptions/"+  $subscriptionId +"/resourceGroups/" + $resourceGroup+ "/providers/Microsoft.StorageDiscovery/storageDiscoveryWorkspaces/" + $resourceName + "?api-version=" + $apiVersionOld + ""

Log "Fetching ASDW resource : $resourceName using URI: $fetchURI"

$asdw = & $armClientExe GET $fetchURI | ConvertFrom-Json 
Write-Host "Resource is: $asdw and type: $asdw.GetType()"


if ($asdw -and $asdw.PSObject.Properties.Name -notcontains "error") {

    $name = $asdw.name
    $location = $asdw.location
    $properties = $asdw.properties

    Write-Host "Processing resource: $name"
    Write-Host "Location: $location"
    Write-Host "Original Properties: $properties"

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
    $newName = $asdw.name + "-0601"

    $jsonObject = @{
        name = $newName
        location = $location
        properties = $asdw.properties
    }
    Log ($jsonObject | ConvertTo-Json -Depth 10)

    $newResourceUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.StorageDiscovery/storageDiscoveryWorkspaces/" + $newName + "?api-version=" + $apiVersionNew +""

    # Convert to JSON and save to a temp file
    $tempJsonPath = "$env:TEMP\$newName.json"
    $jsonObject | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempJsonPath -Encoding utf8

    Log "Creating new asdw: $newName with URI: $newResourceUri"

    # Use the file in the PUT request
    & $armClientExe  put $newResourceUri @$tempJsonPath

    Remove-Item $tempJsonPath -Force

    # Step 5: Delete old ASDW resource
    $oldResourceUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.StorageDiscovery/storageDiscoveryWorkspaces/" + $name + "?api-version=" + $apiVersionNew +""
    
    Write-Host "Deleting old resource: $name"
    Log "Delete URI: $oldResourceUri"
    Log "Deleting old resource: $name"

    & $armClientExe  delete $oldResourceUri

} elseif ($asdw.error -ne $null -and $asdw.error.ToString().Trim() -ne "") {
    Write-Host "ASDW error returned for provided values - Tenant - $targetTenantId, Subscription - $subscriptionId, Resource Group - $resourceGroup, Resource Name - $resourceName error - $($asdw.error)"
    Log "ASDW returned an error: $($asdw.error)"
    exit
} else {
    Write-Host "ASDW resource is empty or invalid for provided values - Tenant - $targetTenantId, Subscription - $subscriptionId, Resource Group - $resourceGroup, Resource Name - $resourceName"
    Log "ASDW resource is empty or invalid. for provided values - Tenant - $targetTenantId, Subscription - $subscriptionId, Resource Group - $resourceGroup, Resource Name - $resourceName"
    exit
}

Write-Host "Script ended"
Log "--------------------------------------------------END----------------------------------------------------------"