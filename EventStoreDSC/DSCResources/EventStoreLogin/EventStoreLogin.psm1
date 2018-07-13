function Test-EventStoreUserHasPassword{

    [OutputType('System.Boolean')]
    [Cmdletbinding()]
    Param(
        [String]    $url = "http://localhost:2113",
        [System.Management.Automation.PSCredential] $credential
    )

    Write-Verbose ":: Check if User: $user Has Password on URL:$url"

    $unsecureCreds = $credential.GetNetworkCredential()
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $unsecureCreds.UserName,$unsecureCreds.Password)))
    Remove-Variable unsecureCreds

    $url = $url + '/users/' + $user
    Write-Verbose ":: Rest URL: $url"

    try {
        Write-Verbose ":: Try Invoke with Credentials $url"
        $response = Invoke-RestMethod  $url -Credential $credential -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
        Write-Verbose ":: Response StatusCode: $response.StatusCode"
        Write-Verbose ":: Response: $response"
        Write-Verbose ":: Benutzer $user kann sich mit dem Kennwort anmelden"
        return $true # benutzer kann
    }
    catch {

        Write-Verbose ":: $_"
        if( $_.Exception.Response.StatusCode.Value__ -ne 401 )
        {
                Write-Verbose ":: Not a 401 Status - fehler"
                throw $_.Exception
        }

        if( $_.Exception.Response.StatusCode.Value__ -eq 401 )
        {
                Write-Verbose "::401 Status - Benutzer kann sich nicht mit dem Kennwort anmelden"
                return $false;
        }
    }

}

function Set-EventStoreUserPassword{

    [Cmdletbinding()]
    Param(
        [String]    $url = "http://localhost:2113",
        [System.Management.Automation.PSCredential] $user,
        [System.Management.Automation.PSCredential] $credential
    )

    Write-Verbose ":: Setting the Password for User: ($user.UserName) with Admin User: ($credential.UserName) on URL:$url"

    $url = -join ( $url , '/users/', $user.UserName , '/command/reset-password' )
    Write-Verbose ":: Rest URL: $url"

    $JSON = '{"newPassword":"' + $user.GetNetworkCredential().Password + '"}'

    $unsecureCreds = $credential.GetNetworkCredential()
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $unsecureCreds.UserName,$unsecureCreds.Password)))
    Remove-Variable unsecureCreds

    Write-Verbose ":: JSON: $JSON"
    Write-Verbose ":: Invoking RestMethod"
    Invoke-RestMethod $url -Credential $credential -Method Post -Body $JSON -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    Write-Verbose ":: Waiting 2 seconds"
    Start-Sleep -s 2
}


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
        $userSecPassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $userCredential = New-Object System.Management.Automation.PSCredential($User, $userSecPassword)

        $adminSecPassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
        $adminCredential = New-Object System.Management.Automation.PSCredential($AdminUser, $adminSecPassword)

        Set-EventStoreUserPassword -credential $adminCredential -user $userCredential
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

    $userSecPassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $userCredential = New-Object System.Management.Automation.PSCredential($User, $userSecPassword)

    $ret = (Test-EventStoreUserHasPassword -url $Url -credential $userCredential)

    Write-Host "EventStoreUserHasPassword $url $ret"

    if ($ret -eq "False") {
        return $true;
    }

    return $false;
}

Export-ModuleMember -Function *-TargetResource
