function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $Url,
        [Parameter()] [String] $Repeats,
        [Parameter()] [String] $SecondsToWait
    )

    Write-Verbose 'Start Get-TargetResource'
    Write-Verbose "Url: $Url"
 
     $returnValue = @{
        Url = $Url        
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)] [String] $Url,
        [Parameter()] [String] $Repeats,
        [Parameter()] [String] $SecondsToWait
    )

    throw 'EventStore is not running'
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $Url,
        [Parameter()] [String] $Repeats,
        [Parameter()] [String] $SecondsToWait
    )

    $ret = (Test-EventStoreRunning -url $Url -repeats $Repeats -secondsToWait $SecondsToWait)
  
    Write-Host "EventStoreRunning $url $ret"

    if ($ret -eq "False") {
        return $true;
    }

    return $false;
}

Export-ModuleMember -Function *-TargetResource
