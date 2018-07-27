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
        [Parameter(Mandatory = $true)] [String] $TaskName,
        [Parameter(Mandatory = $true)] [string] $Directory
    )

    Write-Verbose 'Start Get-TargetResource'
    Write-Verbose "TaskName: $TaskName"

    $exists=Test-EventStoreStartupTask -taskname $TaskName

    $returnValue = @{
        TaskName = $TaskName
        Exists = $exists
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)] [String] $TaskName,
        [Parameter(Mandatory = $true)] [string] $Directory
    )

    Write-Verbose 'Start Set-TargetResource'
    Write-Verbose "TaskName: $TaskName"

    New-EventStoreStartupTask -taskname $TaskName -dir $Directory
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $TaskName,
        [Parameter(Mandatory = $true)] [string] $Directory
    )

    $ret = (Test-EventStoreStartupTask -taskname $TaskName)

    Write-Host "EventStoreStartupTask: $TaskName Exists: $ret"

    if ($ret -eq "False") {
        return $true;
    }

    return $false;
}

Export-ModuleMember -Function *-TargetResource
