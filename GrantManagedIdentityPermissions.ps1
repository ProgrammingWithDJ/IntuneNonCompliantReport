# Variables
$TenantID = "xxx"
$GraphAppId = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph App ID
$DisplayNameOfMSI = "IntuneNonCompliantReport"
$PermissionName = "DeviceManagementManagedDevices.Read.All"
$PermissionName1 = "Mail.Send"

# Install Microsoft Graph module if not already installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Connect to Microsoft Graph with required permissions
Connect-MgGraph -TenantId $TenantID -Scopes "Application.ReadWrite.All"

# Get the service principal for the Logic App's Managed Identity
$MSI = Get-MgServicePrincipal -Filter "displayName eq '$DisplayNameOfMSI'"

# Get the Microsoft Graph service principal
$GraphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$GraphAppId'"

# Get the App Role ID for the desired permission
$AppRole = $GraphServicePrincipal.AppRoles |
    Where-Object { $_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application" }



# Check that all required objects exist
if (-not $MSI) { throw "❌ MSI service principal not found" }
if (-not $GraphServicePrincipal) { throw "❌ Microsoft Graph service principal not found" }
if (-not $AppRole) { throw "❌ App role '$PermissionName' not found" }

# Assign the app role to the Logic App's MSI
New-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $MSI.Id `
    -PrincipalId $MSI.Id `
    -ResourceId $GraphServicePrincipal.Id `
    -AppRoleId $AppRole.Id

Write-Host "✅ App role '$PermissionName' assigned to MSI '$DisplayNameOfMSI'."

$AppRole = $GraphServicePrincipal.AppRoles |
    Where-Object { $_.Value -eq $PermissionName1 -and $_.AllowedMemberTypes -contains "Application" }

# Check that all required objects exist
if (-not $MSI) { throw "❌ MSI service principal not found" }
if (-not $GraphServicePrincipal) { throw "❌ Microsoft Graph service principal not found" }
if (-not $AppRole) { throw "❌ App role '$PermissionName' not found" }

# Assign the app role to the Logic App's MSI
New-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $MSI.Id `
    -PrincipalId $MSI.Id `
    -ResourceId $GraphServicePrincipal.Id `
    -AppRoleId $AppRole.Id

Write-Host "✅ App role '$PermissionName' assigned to MSI '$DisplayNameOfMSI'."
