# EventStoreDSC

## Development

```powershell
#Link folder to Powershell Modules Directory

$originalPath =  "C:\Repos\EventStoreDSC\EventStoreDSC"
$originalPath =  "$(Get-Location)"

$moduleDir = 'C:\Program Files\WindowsPowerShell\Modules\EventStoreDSC'
if (!(Test-Path -Path $moduleDir)) {
   New-Item -Path $moduleDir -ItemType Directory
}

$versionDir = $moduleDir + '\9.9.9'
if (Test-Path -Path $versionDir) {
    Remove-item -Path $versionDir -Force -Recurse
}

New-Item -ItemType SymbolicLink -Path $moduleDir -Target $originalPath -Name 9.9.9

```


```powershell
#Start Local Shell
# powershell
# .\Prepare-Env.ps1

Get-DscResource -Module EventStoreDSC

#Analyze Module
Invoke-ScriptAnalyzer -Path .\EventStoreDSC\
Test-xDscResource .\EventStoreDSC\DSCResources\WaitForEventStore
Test-xDscSchema .\EventStoreDSC\DSCResources\WaitForEventStore\WaitForEventStore.schema.mof

Test-xDscResource .\EventStoreDSC\DSCResources\EventStoreLogin
Test-xDscSchema .\EventStoreDSC\DSCResources\EventStoreLogin\EventStoreLogin.schema.mof

Test-xDscResource .\EventStoreDSC\DSCResources\EventStoreStartupTask
Test-xDscSchema .\EventStoreDSC\DSCResources\EventStoreStartupTask\EventStoreStartupTask.schema.mof

Test-xDscResource .\EventStoreDSC\DSCResources\EventStoreSingleNode
Test-xDscSchema .\EventStoreDSC\DSCResources\EventStoreSingleNode\EventStoreStartupTask.schema.psm1
Test-xDscResource .\EventStoreDSC\DSCResources\EventStoreSingleNode\EventStoreStartupTask.schema.psm1

$error = $null
Import-Module EventStoreDSC –force
If ($error.count –ne 0) {
    Throw “Module was not imported correctly. Errors returned: $error”
}

```


## Links

* https://hodgkins.io/five-tips-for-writing-dsc-resources-in-powershell-version-5
* https://kevinmarquette.github.io/2017-05-27-Powershell-module-building-basics/?utm_source=blog&utm_medium=blog&utm_content=psrepository
* https://docs.microsoft.com/de-de/powershell/dsc/separatingenvdata
