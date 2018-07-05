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

    $userpwd = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    $usercred = New-Object System.Management.Automation.PSCredential($User, $userpwd)

    $adminpwd = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
    $admincred = New-Object System.Management.Automation.PSCredential($AdminUser, $adminpwd)

    Set-EventStoreUserPassword -url $Url -user $usercred -credential $admincred
    # Set-EventStoreUserPassword -url $Url -user $User -newpassword $NewPassword -adminuser $AdminUser -adminpassword $AdminPassword
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

    $pwd = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($User, $pwd)
    $ret = (Test-EventStoreUserHasPassword -url $Url -credential $cred)

    # $ret = (Test-EventStoreUserHasPassword -url $Url -user $User -password $NewPassword)

    Write-Host "EventStoreUserHasPassword $url $ret"

    if ($ret -eq "False") {
        return $true;
    }

    return $false;
}

Export-ModuleMember -Function *-TargetResource
