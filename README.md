# FileDownloadDsc

File Downloader for PowerShellDSC

Usage
```
Configuration Sample1
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreProject EventStoreTestInstance
        {
            DataDrive = "c:\"
            ExtIp = "127.0.0.1"
            ESName = "test"
            IntHttpPort = "2912"
            ExtHttpPort = "2913"
            IntTcpPort = "1912"
            ExtTcpPort = "1913"
            IntSecureTcpPort = "3912"
            ExtSecureTcpPort = "3913"
            OldAdminPassword = "changeit"
            OldOpsPassword = "changeit"
            NewAdminPassword = "changedit"
            NewOpsPassword = "changedit"
        }
    }
}

```

## Development

```
#adding Gallery API Key to Environment
$env:PS_GALLERY_API_KEY = "XXX"

#list module path
$env:PSModulePath -split ';'

#adding local folder to PSModulePath
$env:PSModulePath = $env:PSModulePath + ";$(Get-Location)"

Publish-Module -Name EventStoreDSC -NuGetApiKey $env:PS_GALLERY_API_KEY 


#Link folder to Powershell Modules Directory

$originalPath =  "$(Get-Location)"
$pathInModuleDir = 'C:\Program Files\WindowsPowerShell\Modules\EventStoreDSC'

New-Item -ItemType SymbolicLink -Path $pathInModuleDir -Target $originalPath

```

## Links

https://hodgkins.io/five-tips-for-writing-dsc-resources-in-powershell-version-5
https://kevinmarquette.github.io/2017-05-27-Powershell-module-building-basics/?utm_source=blog&utm_medium=blog&utm_content=psrepository