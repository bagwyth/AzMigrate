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
The Get-AzureMigrateDiscoveredMachine cmdlet returns all machines discovered within a specified Azure Migrate project.
Adding the -GroupName parameter returns only machines associated with the specified Azure Migrate group.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
Specifies the Azure subscription to query.
.PARAMETER ResourceGroup
Specifies the resoruce group containing the Azure Migrate project.
.PARAMETER Project
Specifies the Azure Migrate project to query.
.PARAMETER GroupName
Name of an Azure Migrate group from which to return a list of machines
.EXAMPLE
Get all machines discovered within a specified Azure Migrate project.
PS C:\>Get-AzureMigrateDiscoveredMachine -Token $token -SubscriptionID SSID -ResourceGroup xx -Project xx
.EXAMPLE
Get machines discovered within a specified Azure Migrate project and associated with a specific group.
PS C:\>Get-AzureMigrateDiscoveredMachine -Token $token -SubscriptionID SSID -ResourceGroup xx -Project xx -GroupName MyGroup01

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
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $false)][string]$GroupName
    )

    $obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentProjects/{2}/machines?api-version=2019-05-01&pageSize=2000" -f $SubscriptionID, $ResourceGroup, $Project
    if($GroupName) {
        $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentprojects/{2}/machines?api-version=2019-05-01&pageSize=2000&%24filter=Properties/GroupName%20eq%20'{3}'"  -f $SubscriptionID, $ResourceGroup, $Project, $GroupName
    }
    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")
    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET"# -Debug -Verbose
    $obj = $obj + $response.value
    while ($response.nextlink) {
        $newresponse = Invoke-RestMethod -Uri $response.nextLink -Headers $headers -ContentType "application/json" -Method "GET" #-Debug -Verbose
        $response = $newresponse
        $obj = $obj + $response.value
        clear-variable newresponse
    }
    return $obj
}


<#
.SYNOPSIS
Returns details of machines assessed within a group by a specific assessment.
.DESCRIPTION
The Get-AzureMigrateAssessedMachine cmdlet returns details of machines assessed against a specific assessment within a specified Azure Migrate group.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
Specifies the Azure subscription to query.
.PARAMETER ResourceGroup
Specifies the resoruce group containing the Azure Migrate project.
.PARAMETER Project
Specifies the Azure Migrate project to query.
.PARAMETER GroupName
Name of an Azure Migrate group from which to return a list of machines.
.PARAMETER AssessmentName
The name of the specific assessment for which to retrieve results from.
.EXAMPLE
Get all machines assessed against the assessment "assessment01" within the group "group01".
PS C:\>Get-AzureMigrateAssessedMachine -Token $token -SubscriptionID SSID -ResourceGroup xx -Project xx -GroupName group01 -AssessmentName assessment01

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of 1 discovered machine.
#>
function Get-AzureMigrateAssessedMachine {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$GroupName,
        [Parameter(Mandatory = $true)][string]$AssessmentName
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentProjects/{2}/groups/{3}/assessments/{4}/assessedMachines/?api-version=2019-05-01&pageSize=2000" -f $SubscriptionID, $ResourceGroup, $Project, $GroupName, $AssessmentName

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" # -Debug -Verbose
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
    $url = "https://management.azure.com{0}/machines?api-version=2019-05-01-preview&pageSize=2000" -f $VMWareSite

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response.value

}


<#
.SYNOPSIS
Returns high-level details of assessments from the specified Azure Migrate project.
.DESCRIPTION
The Get-AzureMigrateAssessments cmdlet returns high-level details of assessments from the specified Azure Migrate project.
.PARAMETER SubscriptionID
Specifies the Azure subscription to query.
.PARAMETER ResourceGroup
Specifies the resoruce group containing the Azure Migrate project.
.PARAMETER Project
Specifies the Azure Migrate project to query.
.EXAMPLE
Get all assessments for the specified Azure Migrate project.
PS C:\>Get-AzureMigrateAssessments -Token $token -Project xx

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of 1 discovered machine.
#>
function Get-AzureMigrateAssessments {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentprojects/{2}/assessmentsSummary/default?api-version=2020-05-01-preview" -f $SubscriptionID, $ResourceGroup, $Project

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "GET" #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response.properties.assessments

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

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "POST" -Body $jsonPayload #-Debug -Verbose
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
PS C:\>Get-AzureMigrateGroup -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ

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
Add or remove machines associated with an existing Azure Migrate group.
.DESCRIPTION
The Set-AzureMigrateGroup cmdlet adds or removes machines associated with an existing Azure Migrate group.
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
.PARAMETER Machines
A list of machines to add or remove from the group.
.PARAMETER Add
Causes the function to add machines to the group.
.PARAMETER Remove
Causes the function to remove machines from the group.
.EXAMPLE
Add the machines VM01 and VM02 to the group named "HRApplication01"
PS C:\>Set-AzureMigrateGroup -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ -GroupName "HRApplication01" -Machines VM01,VM02 -Add
.EXAMPLE
Remove the machine VM01 from the group named "HRApplication01"
PS C:\>Set-AzureMigrateGroup -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ -GroupName "HRApplication01" -Machines VM01 -Remove

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of group name already in use.
#>
function Set-AzureMigrateGroup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$Group,
        [Parameter(Mandatory = $true)][string[]]$Machines,
        [Parameter(Mandatory = $true, ParameterSetName = "Add")][switch]$Add,
        [Parameter(Mandatory = $true, ParameterSetName = "Remove")][switch]$Remove
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
          "operationType": "Undefined"
        }
      }
"@

    $jsonPayload = $jsonPayload | ConvertFrom-Json

    if($Add) {
        $jsonPayload.properties.operationType = "Add"
    }
    if($Remove) {
        $jsonPayload.properties.operationType = "Remove"
    }

    $Machines | ForEach-Object {
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
The ID of the group containing machines to assess.
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

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "PUT" -Body $jsonPayload #-Debug -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response

}


<#
.SYNOPSIS
Remove an Azure Migrate assessment.
.DESCRIPTION
The Remove-AzureMigrateAssessment cmdlet removes an Azure Migrate assessment.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
The subscription the project resources are contained in.
.PARAMETER ResourceGroup
The resource group containing the Azure Migrate project.
.PARAMETER Project
The Azure Migrate project the group is in.
.PARAMETER Group
The ID of the group to the assessment is associated with.
.PARAMETER AssessmentName
Name of the Azure Migrate assessment to be removed.
.EXAMPLE
Remove the assessment "Assessment01"
PS C:\>Remove-AzureMigrateAssessment -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ -Group GG -Assessment WW

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of group name already in use.
#>
function Remove-AzureMigrateAssessment {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$Group,
        [Parameter(Mandatory = $true)][string]$AssessmentName
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentprojects/{2}/groups/{3}/assessments/{4}?api-version=2019-05-01" -f $SubscriptionID, $ResourceGroup, $Project, $Group, $AssessmentName

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "DELETE" -Verbose
    #$obj += $response.Substring(1) | ConvertFrom-Json
    #return (_formatResult -obj $obj -type "AzureMigrateProject")
    return $response

}


<#
.SYNOPSIS
Remove an empty Azure Migrate group.
.DESCRIPTION
The Remove-AzureMigrateGroup cmdlet removes an Azure Migrate group.
Note that any assessments or machines associated with the group will prevent this command from completing successfully.
.PARAMETER Token
Specifies an authentication token to use when retrieving information from Azure.
.PARAMETER SubscriptionID
The subscription the project resources are contained in.
.PARAMETER ResourceGroup
The resource group containing the Azure Migrate project.
.PARAMETER Project
The Azure Migrate project the group is in.
.PARAMETER Group
The ID of the group to remove.
.EXAMPLE
Remove the group "Group01"
PS C:\>Remove-AzureMigrateGroup -Token $token -SubscriptionID XX -ResourceGroup YY -Project ZZ -Group "Group01"

.NOTES
TBD:
1. Return object with more meaningful properties (i.e. extract info from .properties and populate top-level object as appropriate).
2. Handle case of empty project.
3. Handle caes of group name already in use.
#>
function Remove-AzureMigrateGroup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$SubscriptionID,
        [Parameter(Mandatory = $true)][string]$ResourceGroup,
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$Group
    )

    #$obj = @()
    $url = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Migrate/assessmentprojects/{2}/groups/{3}?api-version=2019-05-01" -f $SubscriptionID, $ResourceGroup, $Project, $Group

    $headers = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
    $headers.Add("Authorization", "Bearer $Token")

    $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType "application/json" -Method "DELETE" -Verbose
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
