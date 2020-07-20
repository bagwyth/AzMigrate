
# AzMigrate

A prototype PowerShell module used for automating various Azure Migrate: Server Assessment activities.

## Overview

[Azure Migrate: Server Assessment](https://docs.microsoft.com/en-us/azure/migrate/migrate-services-overview#azure-migrate-server-assessment-tool) is a Microsoft solution used for discovering and assessing on-premises VMware VMs, Hyper-V VMs, and physical servers in preparation for migration to Azure.

Currently, many of the activities undertaken when conducting an assessment of the on-premises environment are only possible through the Azure Portal. These include [creating groups of machines](https://docs.microsoft.com/en-us/azure/migrate/how-to-create-a-group#create-a-group-manually), and [creating assessments for groups](https://docs.microsoft.com/en-us/azure/migrate/how-to-create-assessment). This PowerShell module provides functionality to complete those activities programmatically.

## How to Use

### Requirements

To use this module the following are required:

1. **Azure Migrate Project:** An Azure Migrate project must already have been created and the appliance should be deployed and successfully collecting data.
2. **Azure User Account:** This module acts as a wrapper around the underlying Azure Migrate REST APIs. As such, it requires that you run it whilst connected to Azure with a user account with access to your Azure Migrate project.
3. **PowerShell Version:** It's strongly recommended you install the [latest version of PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) available for your operating system.
4. **Azure PowerShell Module:** The module relies on basic [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-4.3.0) functionality to connect to your subscription. It checks for the presence of an up-to-date install of the standard Azure PowerShell module to do this.

> Azure [Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) is a convenient alternative to installing and maintaining the required software on a local machine.

### Download the Module

- Go to: <https://github.com/bagwyth/AzMigrate>
- Click **Code** and then click **Download ZIP.**
- Extract the contents of the ZIP file to the directory you will work in.

### Import the Module

Start a PowerShell terminal, navigate to the folder where you extracted the ZIP file and import the module:

```powershell
Import-Module ./AzMigrate.psm1
```

Verify the module loaded correctly and review a list of available commands:

```powershell
Get-Command -Module AzMigrate
```

### Use the Module

We'll refer to the Azure subscription and resource group that contain the Azure Migrate project regularly so to save having to re-type them we'll configure some variables to store them:

```powershell
$subscriptionid = "<your subscription ID>"
$rg = "<your resource group name>"
```

> If you're unsure what the subscription ID and resource group values should be, navigate to the Azure portal, browse to your Azure Migrate project, click through to server assessment and expand the "essentials" section. You'll see both listed there.

Connect to Azure using the credentials of your user account with access to the Azure Migrate project. Once successfully connected, ensure we're working in the context of the subscription which contains the Azure Migrate project:

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId $subscriptionid

# Retrieve a bearer token for use when interacting with the underlying REST API:
$token = Get-AzCachedAccessToken

#Get a list of all available Azure Migrate projects in the subscription
$projects = Get-AzureMigrateProject -Token $token -SubscriptionID $subscriptionid
#Get a list of discovered machines from the first project returned above
$discoveredmachines = Get-AzureMigrateDiscoveredMachine -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name
# Review the output of the above command
$discoveredmachines | Select-Object {$_.properties.displayname}, {$_.properties.megabytesofmemory}, {$_.properties.numberofcores}, {$_.properties.operatingsystemname}
# Get a list of groups associated with a project
$AzMigGroups = Get-AzureMigrateGroups -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name
# Review the list of groups returned
$AzMigGroups | Select-Object name, {$_.properties.machinecount}
# Get a list of machines associated with a specific group
$group1discoveredmachines = Get-AzureMigrateDiscoveredMachine -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -GroupName $AzMigGroups[0].name
# Review the output of the above command
$group1discoveredmachines | Select-Object {$_.properties.displayname}, {$_.properties.megabytesofmemory}, {$_.properties.numberofcores}, {$_.properties.operatingsystemname}
# Create a new, empty group
$newgroup = New-AzureMigrateGroup -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -GroupName "TestGroup02"
# Add machines to the new group
$updatedGroup = Set-AzureMigrateGroup -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -Group $newgroup.name -Machines $discoveredmachines[4].id,$discoveredmachines[5].id -Debug -Add
# Re-run the Get-AzMigrateGroups command to get the updated list of groups and verify the new group was created and has machines added to it
$AzMigGroups = Get-AzureMigrateGroups -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name
$AzMigGroups | Select-Object name, {$_.properties.machinecount}
# Create assessments for the new group using our assessment templates
$assessment01 = New-AzureMigrateAssessment -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -AssessmentName "Assessment01" -Group $updatedGroup.name -AssessmentProperties .\SampleAssessmentProperties01.json
$assessment02 = New-AzureMigrateAssessment -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -AssessmentName "Assessment02" -Group $updatedGroup.name -AssessmentProperties .\SampleAssessmentProperties02.json

# Get assessments for the project
$assessments = Get-AzureMigrateAssessments -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name
# Review details of assessments returned
$assessments |Select-Object name, @{Name='Type';Expression={$_.properties.sizingcriterion}}, @{Name='Suitability';Expression={$_.properties.suitabilitysummary}}, @{Name='Monthly Cost';Expression={$_.properties.monthlycomputecost + $_.properties.monthlystoragecost + $_.properties.monthlyPremiumStorageCost + $_properties.monthlyStandardSSDStorageCost}}
```

Steps to enable or disable the agentless dependency mapping feature for multiple machines programatically:

```powershell
# Get all VMware Azure Migrate appliances from the resource group
$AzureVMwaresite = Get-AzureMigrateVMWareSite -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg
# Get all VMware VMs discovered by the first appliance returned above
$AzureVMwareSiteVMs = Get-AzureMigrateVMWareSiteVMs -Token $token -VMWareSite $AzureVMwaresite[0].id
# Review the status of those VMware VMs returned
$AzureVMwareSiteVMs | select {$_.properties.displayname},{$_.properties.dependencymapping}
# Enable the dependency mapping feature for the 2nd VM returned - this can also accept a list of VMs to make enabling the feature at scale easier
Set-AzureMigrateAgentlessDependencyMapping -Token $token -VMWareSite $AzureVMwaresite[0].id -VM $azureVMwareSiteVMs[1].id -DependencyMapping Enabled
```

Steps to remove an assessment, remove machines from a group, and remove a group

```powershell
# Remove an assessment
Remove-AzureMigrateAssessment -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -AssessmentName "Assessment02" -Group $updatedGroup.name
Remove-AzureMigrateAssessment -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -AssessmentName "Assessment02" -Group $updatedGroup.name

# Remove machines from a group
$updatedGroup = Set-AzureMigrateGroup -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -Group $newgroup.name -Machines $discoveredmachines[3].id,$discoveredmachines[5].id -Remove

# Remove an empty group
Remove-AzureMigrateGroup -Token $token -SubscriptionID $subscriptionid -ResourceGroup $rg -Project $projects[0].name -Group $updatedGroup.name
```

## Known Issues / Troubleshooting

- **Token lifetime is limited:** If you receive authentication issues re-run the Get-AzCachedAccessToken command to get a fresh token.
- **Returned objects:** The objects returned by the various functions aren't very friendly. You typically have to explore the properties manually to determine which are useful.
- **The number of results returned may be limited:** For example, the Get-AzureMigrateDiscoveredMachine may only return 50 machines at a time. We're working on enabling that to return more results.
- **Assessment properties are opaque:**

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit <https://cla.microsoft.com>.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Legal Notices

Microsoft and any contributors grant you a license to the Microsoft documentation and other content in this repository under the [Creative Commons Attribution 4.0 International Public License](https://creativecommons.org/licenses/by/4.0/legalcode), see the [LICENSE](LICENSE) file, and grant you a license to any code in the repository under the [MIT License](https://opensource.org/licenses/MIT), see the [LICENSE-CODE](LICENSE-CODE) file.

Microsoft, Windows, Microsoft Azure and/or other Microsoft products and services referenced in the documentation may be either trademarks or registered trademarks of Microsoft in the United States and/or other countries. The licenses for this project do not grant you rights to use any Microsoft names, logos, or trademarks. Microsoft's general trademark guidelines can be found at <http://go.microsoft.com/fwlink/?LinkID=254653>.

Privacy information can be found at <https://privacy.microsoft.com/en-us/>

Microsoft and any contributors reserve all others rights, whether under their respective copyrights, patents, or trademarks, whether by implication, estoppel or otherwise.

## Disclaimer

The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
