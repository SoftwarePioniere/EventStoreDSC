[CmdletBinding()]
Param(
    [string]$version = "9.9.9",
    [string]$apiKey
)

#script to deploy with appveyor
$moduleDir = "$(Get-Location)\xxModules"

if (!(Test-Path -Path $moduleDir)) {
    New-Item -Path $moduleDir -ItemType Directory
 }

if (!(Test-Path -Path "$moduleDir\xNetworking\5.7.0.0")) {
    Save-Module -Name xNetworking -RequiredVersion '5.7.0.0' -Path $moduleDir
}

if (!(Test-Path -Path "$moduleDir\FileDownloadDSC\1.0.10")) {
    Save-Module -Name FileDownloadDSC -RequiredVersion '1.0.10' -Path $moduleDir
}

if (!(Test-Path -Path "$moduleDir\cChoco\2.4.0.0")) {
    Save-Module -Name cChoco -RequiredVersion '2.4.0.0' -Path $moduleDir
}

$env:PSModulePath = "$env:PSModulePath;$moduleDir";
Write-Host  $env:PSModulePath

Write-Host "Updating Module Manifest... with Version: $version"
Update-ModuleManifest -Path .\EventStoreDSC\EventStoreDSC.psd1 -ModuleVersion $version

if ($apiKey) {
    Write-Host "Publishing Module... "
    Publish-Module -Path .\EventStoreDSC -NuGetApiKey $apiKey
}
