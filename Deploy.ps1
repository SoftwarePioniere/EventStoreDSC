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

$env:PSModulePath = "$env:PSModulePath;$moduleDir";
Write-Host  $env:PSModulePath

Update-ModuleManifest -Path .\EventStoreDSC\EventStoreDSC.psd1 -ModuleVersion $env:APPVEYOR_BUILD_VERSION
Publish-Module -Path .\EventStoreDSC -NuGetApiKey $env:PS_GALLERY_API_KEY