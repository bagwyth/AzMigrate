Set-StrictMode -Version latest
<#
    © 2020 Microsoft Corporation. All rights reserved. This sample code is not supported under any Microsoft standard support program or service. 
    This sample code is provided AS IS without warranty of any kind. Microsoft disclaims all implied warranties including, without limitation, 
    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance 
    of the sample code and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, 
    production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business 
    profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the 
    sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
#>

<#
.SYNOPSIS
Returns all Azure Migrate projects within a specified Azure subscription.
.DESCRIPTION
The Get-AzMigrateProject cmdlet returns all Azure Migrate projects from a specified subscription.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
Specifies the Azure subscription to query.
.EXAMPLE
Get all Azure Migrate projects within a specific Azure subscription.
PS C:\>Get-AzureMigrateProject -Token $token -SubscriptionID 45916f92-e9c3-4ed2-b8c2-d87aa129905f

.NOTES
TBD:
1. Consider returning 1 or multiple projects.
2. Return more meaningful object by extracting values from properties of a project.
3. Discern and return the displayname or a project as well as the internal name/ID.
#>
function Get-AzureMigrateProject {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/providers/Microsoft.Migrate/assessmentProjects?api-version=2019-10-01" -f $SubscriptionID

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response.value

}

<#
.SYNOPSIS
Returns all discovered machines within a specified Azure Migrate project.
.DESCRIPTION
The Get-AzMigrateDiscoveredMachins cmdlet returns all machines discovered within a specified Azure Migrate project.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
Specifies the Azure subscription to query.
.PARAMETER ResourceGroup
Specifies the resoruce group containing the Azure Migrate project.
.PARAMETER Project
Specifies the Azure Migrate project to query.
.EXAMPLE
Get all machines discovered within a specified Azure Migrate project.
PS C:\>Get-AzureMigrateDiscoveredMachine -Token $token -SubscriptionID 45916f92-e9c3-4ed2-b8c2-d87aa129905f -ResourceGroup xx -Project xx

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of 1 discovered machine.
#>
function Get-AzureMigrateDiscoveredMachine {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentProjects/{2}/machines?api-version=2019-10-01&pageSize=1000" -f $SubscriptionID, $ResourceGroup, $Project
    #$url = "https://management.azure.com{0}/machines?api-version=2019-10-01&pageSize=1000" -f $Project
    #/subscriptions/4d2e8de2-eea6-4697-8be1-e7338bb3f867/resourceGroups/RG-AzMigVMware01-EUWest/providers/Microsoft.Migrate/assessmentprojects/AzMig-VMware01-EUWesta731project/machines?api-version=2019-10-01&pageSize=1000"

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" -Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response.value

}


<#
.SYNOPSIS
Returns all on-premises VMware sites associated with Azure Migrate.
.DESCRIPTION
The Get-AzureMigrateVMWareSite cmdlet returns all on-premises VMware sites associated with Azure Migrate.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
Specifies the Azure subscription to query.
.PARAMETER ResourceGroup
Specifies the resoruce group containing the Azure Migrate project.
.EXAMPLE
Get all machines discovered within a specified Azure Migrate project.
PS C:\>Get-AzureMigrateVMWareSite -Token $token -SubscriptionID 45916f92-e9c3-4ed2-b8c2-d87aa129905f -ResourceGroup xx

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of 1 discovered machine.
#>
function Get-AzureMigrateVMWareSite {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OffAzure/VMwareSites?api-version=2020-01-01-preview" -f $SubscriptionID, $ResourceGroup

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response.value

}

<#
.SYNOPSIS
Returns all on-premises VMware VMs associated with the specified site.
.DESCRIPTION
The Get-AzureMigrateVMWareSiteVMs cmdlet returns all on-premises VMware VMs associated with the specified site.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER VMWareSite
The on-premises VMWare site.
.EXAMPLE
Get all machines discovered within a specified Azure Migrate project.
PS C:\>Get-AzureMigrateVMWareSiteVMs -Token $token -VMWareSite xx

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of 1 discovered machine.
#>
function Get-AzureMigrateVMWareSiteVMs {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$VMWareSite
    )

    #$obj = @()
    $url = "https://management.azure.com{0}/machines?api-version=2020-01-01-preview&pageSize=1000" -f $VMWareSite

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response.value

}


<#
.SYNOPSIS
Sets state of agentless dependency mapping feature to enabled or disabled for one or more VMs.
.DESCRIPTION
The Set-AzureMigrateAgentlessDependencyMapping cmdlet enables or disables the dependency mapping feature for the specified set of VMs.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER VMWareSite
The on-premises VMWare site.
.PARAMETER VM
An array of on-premises VM(s) for which to enable or disable the dependency mapping feature.
.PARAMETER DependencyMapping
Whether the feature should be Disabled or Enabled for the list of VMs provided
.EXAMPLE
Enables the agentless dependency mapping feature for the listed VMs.
PS C:\>Set-AzureMigrateAgentlessDependencyMapping -Token $token -VMWareSite xx -VM "VM1,VM2,VM3" -DependencyMapping Disabled

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of 1 discovered machine.
#>
function Set-AzureMigrateAgentlessDependencyMapping {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$VMWareSite,
        [Parameter(Mandatory = $true)][string[]]$VM,
        [Parameter(Mandatory = $true)][string][ValidateSet('Enabled','Disabled')]$DependencyMapping
    )

    #$obj = @()
    $url = "https://management.azure.com{0}/UpdateProperties?api-version=2020-01-01-preview" -f $VMWareSite

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

$jsonPayload = @"
{
    "machines": [
    ]
    }
"@

    $jsonPayload = $jsonPayload | ConvertFrom-Json

    $VM | ForEach-Object {
        $obj = [PSCustomObject]@{
            machineArmId = $_
            dependencyMapping = $DependencyMapping
        }
        $jsonPayload.machines += $obj
    }

    $jsonPayload = $jsonPayload | ConvertTo-Json

    Write-Debug $jsonPayload

    #$jsonPayload = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "POST" -Body $jsonPayload -Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response

}


<#
.SYNOPSIS
Create a new empty group in Azure Migrate.
.DESCRIPTION
The New-AzureMigrateGroup cmdlet creates a new empty group in Azure Migrate. Add servers to the group then create assessments for the group.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
The subscription the project resources are contained in.
.PARAMETER ResourceGroup
The resource group containing the Azure Migrate project.
.PARAMETER Project
The Azure Migrate project to create the group in.
.PARAMETER GroupName
The name of the group to create
.EXAMPLE
Create a new group named "HRApplication01"
PS C:\>New-AzureMigrateGroup -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ -GroupName "HRApplication01"

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of group name already in use.
#>
function New-AzureMigrateGroup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$GroupName
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentProjects/{2}/groups/{3}?api-version=2019-05-01" -f $SubscriptionID, $ResourceGroup, $Project, $GroupName

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "PUT" -Body "{'groupType': 'Default'}" #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response

}


<#
.SYNOPSIS
Get all machine groups from a specific Azure Migrate project.
.DESCRIPTION
The Get-AzureMigrateGroups cmdlet creates a new empty group in Azure Migrate. Add servers to the group then create assessments for the group.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
The subscription the project resources are contained in.
.PARAMETER ResourceGroup
The resource group containing the Azure Migrate project.
.PARAMETER Project
The Azure Migrate project to create the group in.
.EXAMPLE
Get all groups for a specific project
PS C:\>New-AzureMigrateGroup -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of group name already in use.
#>
function Get-AzureMigrateGroups {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentProjects/{2}/groups?api-version=2019-05-01" -f $SubscriptionID, $ResourceGroup, $Project

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response.value

}


<#
.SYNOPSIS
Add machines to an existing Azure Migrate group.
.DESCRIPTION
The Update-AzureMigrateGroup cmdlet adds machines to an existing Azure Migrate group.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
The subscription the project resources are contained in.
.PARAMETER ResourceGroup
The resource group containing the Azure Migrate project.
.PARAMETER Project
The Azure Migrate project the group is in.
.PARAMETER Group
The ID of the group to add machines to.
.PARAMETER MachinesToAdd
A list of machines to add to the group.
.EXAMPLE
Create a new group named "HRApplication01"
PS C:\>New-AzureMigrateGroup -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ -GroupName "HRApplication01"

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of group name already in use.
#>
function Update-AzureMigrateGroup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$Group,
        [Parameter(Mandatory = $true)][string[]]$MachinesToAdd
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentProjects/{2}/groups/{3}/updateMachines?api-version=2019-05-01" -f $SubscriptionID, $ResourceGroup, $Project, $Group

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $jsonPayload = @"
{
    "properties": {
      "machines": [
      ],
      "operationType": "Add"
    }
  }
"@

    $jsonPayload = $jsonPayload | ConvertFrom-Json

    $MachinesToAdd | ForEach-Object {
        $jsonPayload.properties.machines += $_
    }

    $jsonPayload = $jsonPayload | ConvertTo-Json

    Write-Debug $jsonPayload


    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "POST" -Body $jsonPayload #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response

}


<#
.SYNOPSIS
Create a new assessment for an existing Azure Migrate group.
.DESCRIPTION
The New-AzureMigrateAssessment cmdlet creates a new assessment of an existing Azure Migrate group using the parameters supplied.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
The subscription the project resources are contained in.
.PARAMETER ResourceGroup
The resource group containing the Azure Migrate project.
.PARAMETER Project
The Azure Migrate project the group is in.
.PARAMETER Group
The ID of the group to add machines to.
.PARAMETER AssessmentName
What to name the assessment being created
.PARAMETER AssessmentProperties
json file containing properties for the assessment being created.
.EXAMPLE
Create a new assessment named "Assessment01"
PS C:\>New-AzureMigrateAssessment -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ -AssessmentName "Assessment01" -AssessmentProperties .\SampleAssessmentProperties01.json

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of group name already in use.
#>
function New-AzureMigrateAssessment {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$Group,
        [Parameter(Mandatory = $true)][string]$AssessmentName,
        [Parameter(Mandatory = $true)][string]$AssessmentProperties
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentprojects/{2}/groups/{3}/assessments/{4}?api-version=2019-05-01" -f $SubscriptionID, $ResourceGroup, $Project, $Group, $AssessmentName

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $jsonPayload = Get-Content $AssessmentProperties

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "PUT" -Body $jsonPayload -Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response

}

<#
.SYNOPSIS
Returns a bearer token for the currently logged in Azure user's context.
.DESCRIPTION
The Get-AzCachedAccessToken cmdlet returns a bearer token for the currently logged in Azure user's context for use when calling Azure REST APIs.
.EXAMPLE
Get a bearer token for the current user's context

Get-AzCachedAccessToken

.NOTES
#>
function Get-AzCachedAccessToken()
{
    $ErrorActionPreference = 'Stop'

    if(-not (Get-Module Az.Accounts)) {
        Import-Module Az.Accounts
    }
    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile

    $currentAzureContext = Get-AzContext

    if(!$currentAzureContext) {
        Write-Error "Ensure you have logged in before calling this function."
    }

    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Tenant.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
    $token.AccessToken
}