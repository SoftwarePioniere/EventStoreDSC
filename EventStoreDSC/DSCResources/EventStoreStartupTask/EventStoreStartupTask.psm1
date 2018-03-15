function Test-EventStoreStartupTask()
{
    [OutputType('System.Boolean')]
    [Cmdletbinding()]
    Param(
        [String] $taskname
    )

    $task= Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskname }
    If ( $task )
    {

        Write-Verbose ":: task with name found"
        return $true;
    }

    return $false
}

function New-EventStoreStartupTask()
{
    [Cmdletbinding()]
    Param(
        [String] $taskname,
        [String] $dir
    )

    $ex = "start.cmd"

    If ( Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskname } )
    {
        Write-Verbose ":: Unregister existing Task"
        Unregister-ScheduledTask $taskname -Confirm:$false
    }

    $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30

    Write-Verbose ":: New-ScheduledTaskAction -Execute $ex -WorkingDirectory $dir"
    $action =  New-ScheduledTaskAction -Execute $ex -WorkingDirectory $dir

    $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Write-Verbose ":: Register Scheduled Task"
    Register-ScheduledTask -TaskName $taskname -Trigger $trigger -Action $action -Principal $principal -ThrottleLimit 0

    Write-Information "!"

}


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
