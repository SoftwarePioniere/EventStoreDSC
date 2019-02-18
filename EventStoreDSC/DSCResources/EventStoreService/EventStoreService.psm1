$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'EventStoreUtil' `
            -ChildPath 'EventStoreUtil.psm1'))

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $ServiceName,
        [Parameter(Mandatory = $true)] [string] $App,
        [Parameter(Mandatory = $true)] [string] $AppArgs
    )

    Write-Warning 'Start Get-TargetResource'
    Write-Verbose "TaskName: $TaskName"

    $returnValue = @{
        TaskName = $TaskName
        App = $App
        AppArgs = $AppArgs
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)] [String] $ServiceName,
        [Parameter(Mandatory = $true)] [string] $App,
        [Parameter(Mandatory = $true)] [string] $AppArgs
    )

    Write-Verbose 'Start Set-TargetResource'
    Write-Verbose "ServiceName: $ServiceName"
    Write-Verbose "App: $App"
    Write-Verbose "AppArgs: $AppArgs"

    $cmd = 'nssm.exe'
    $arg1 = 'install'

    Write-Host "running: $cmd $arg1 $ServiceName $App $AppArgs"
    & $cmd $arg1 $ServiceName $App $AppArgs
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $ServiceName,
        [Parameter(Mandatory = $true)] [string] $App,
        [Parameter(Mandatory = $true)] [string] $AppArgs
    )

    Write-Verbose 'Start Test-TargetResource'
    Write-Verbose "ServiceName: $ServiceName"

    $ret = $false;

    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue -ErrorVariable WindowsServiceExistsError)
    {
        Write-Verbose "$ServiceName Exists"
        $ret = $true;
    }

    if ($WindowsServiceExistsError)
    {
        Write-Verbose $WindowsServiceExistsError[0].exception.message
    }

    if ($ret -eq "False") {
        return $true;
    }

    return $false;
}

Export-ModuleMember -Function *-TargetResource
