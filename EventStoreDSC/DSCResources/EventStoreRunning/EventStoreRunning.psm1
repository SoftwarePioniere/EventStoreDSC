function Test-EventStoreRunning {

    [OutputType('System.Boolean')]
    [cmdletbinding()]
    Param(
        [String]    $url = "http://localhost:2113" ,
        [Int]       $repeats = 3,
        [Int]       $secondsToWait = 1
    )

    Write-Information ":: Testing EventStore on URL: $url"

    $i = 1;
    while ($i -ne $repeats) {
        Write-Verbose -Message (":: Attemp: $i")
        try {
            Write-Verbose -Message (":: Try to Invoke Invoke-RestMethod: $url")
            $response = Invoke-RestMethod  $url -Method Get
            Write-Verbose -Message (":: Response: $response")

            return $true
        }
        catch {

            Write-Verbose -Message (":: $_")
            #return $false
            Write-Verbose -Message (":: Waiting $secondsToWait seconds")
            Start-Sleep -s $secondsToWait
        }

        $i = $i + 1;
    }

    return $false
}


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
