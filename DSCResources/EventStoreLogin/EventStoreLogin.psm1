function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $Url,
        [Parameter(Mandatory = $true)] [String] $User,
        [Parameter()] [String] $Password,
        [Parameter()] [String] $NewPassword,
        [Parameter()] [String] $AdminUser,
        [Parameter()] [String] $AdminPassword
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
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)] [String] $Url,
        [Parameter(Mandatory = $true)] [String] $User,
        [Parameter()] [String] $Password,
        [Parameter()] [String] $NewPassword,
        [Parameter()] [String] $AdminUser,
        [Parameter()] [String] $AdminPassword
    )

        Set-EventStoreUserPassword -url $Url -user $User -newpassword $NewPassword -adminuser $AdminUser -adminpassword $AdminPassword
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)] [String] $Url,
        [Parameter(Mandatory = $true)] [String] $User,
        [Parameter()] [String] $Password,
        [Parameter()] [String] $NewPassword,
        [Parameter()] [String] $AdminUser,
        [Parameter()] [String] $AdminPassword
    )

    $ret = (Test-EventStoreUserHasPassword -url $Url -user $User -password $NewPassword)
  
    Write-Host "EventStoreUserHasPassword $url $ret"

    if ($ret -eq "False") {
        return $true;
    }

    return $false;
}

Export-ModuleMember -Function *-TargetResource
