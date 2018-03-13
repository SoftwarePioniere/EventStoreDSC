Import-Module -Name ..\DSCResources\FileDownload\FileDownload.psm1

$FileName = 'c:\temp\README.md'
$Url = "https://raw.githubusercontent.com/SoftwarePioniere/FileDownloadDSC/master/README.md"

Test-TargetResource -FileName $FileName -Url $Url
Get-TargetResource -FileName $FileName -Url $Url
Set-TargetResource -FileName $FileName -Url $Url
Test-TargetResource -FileName $FileName -Url $Url

