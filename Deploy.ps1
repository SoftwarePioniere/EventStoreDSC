#script to deploy with appveyor
#$env:PSModulePath = $env:PSModulePath + ";$(Get-Location)"
Update-ModuleManifest -Path .\EventStoreDSC\EventStoreDSC.psd1 -ModuleVersion $env:APPVEYOR_BUILD_VERSION
Publish-Module -Path .\EventStoreDSC -NuGetApiKey $env:PS_GALLERY_API_KEY