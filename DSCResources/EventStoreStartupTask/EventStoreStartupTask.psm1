function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $TaskName,
        [Parameter(Mandatory = $true)] [string] $Directory,
        [Parameter(Mandatory = $true)] [string] $Argument
    )

    Write-Verbose 'Start Get-TargetResource'
    Write-Verbose "TaskName: $TaskName"
 
    $exists=Test-EventStoreStartupTask -taskname $TaskName -arg $Argument

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
        [Parameter(Mandatory = $true)] [string] $Directory,
        [Parameter(Mandatory = $true)] [string] $Argument
    )

    Write-Verbose 'Start Set-TargetResource'
    Write-Verbose "TaskName: $TaskName"

    Set-EventStoreStartupTask -taskname $TaskName -arg $Argument -dir $Directory
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $TaskName,
        [Parameter(Mandatory = $true)] [string] $Directory,
        [Parameter(Mandatory = $true)] [string] $Argument
    )

    return Test-EventStoreStartupTask -taskname $TaskName -arg $Argument
}

Export-ModuleMember -Function *-TargetResource
