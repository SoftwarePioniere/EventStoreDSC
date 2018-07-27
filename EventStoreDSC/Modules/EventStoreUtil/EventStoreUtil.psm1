function Assert-EventStoreUserHasPassword {

    [Cmdletbinding()]
    Param(
        [String]    $url = "http://localhost:2113",
        [System.Management.Automation.PSCredential] $user,
        [System.Management.Automation.PSCredential] $credential
    )

    Write-Information "Test-UserHasPassword with New Password"
    $hasNew = Test-EventStoreUserHasPassword -url $url -credential $user
    Write-Information "HasNewPassword $hasNew"

    if (-not $hasNew)
    {
        Write-Information "Should Change Password"

        Write-Information "Test-SetUserPassword"
        Set-EventStoreUserPassword -url $url -user $user -credential $credential

        Write-Information "Test-UserHasPassword with New Password"
        $hasNew = Test-EventStoreUserHasPassword -url $url -credential $user
        Write-Information "HasNewPassword $hasNew"
    }


    if (-not $hasNew){
        throw "Not the right Password"
    }
}
function New-EventStoreStartupTask()
{
    [Cmdletbinding(SupportsShouldProcess)]
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
function Set-EventStoreUserPassword{

    [Cmdletbinding(SupportsShouldProcess)]
    Param(
        [String]    $url = "http://localhost:2113",
        [System.Management.Automation.PSCredential] $user,
        [System.Management.Automation.PSCredential] $credential
    )

    $username = $user.UserName;
    $adminname = $credential.UserName;

    $unsecureCreds = $credential.GetNetworkCredential()
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $unsecureCreds.UserName,$unsecureCreds.Password)))
    Remove-Variable unsecureCreds

    Write-Verbose ":: Setting the Password for User: $username with Admin User: $adminname on URL:$url"

    $url = -join ( $url , '/users/', $user.UserName , '/command/reset-password' )
    Write-Verbose ":: Rest URL: $url"

    $JSON = '{"newPassword":"' + $user.GetNetworkCredential().Password + '"}'

    Write-Verbose ":: JSON: $JSON"
    Write-Verbose ":: Invoking RestMethod"
    Invoke-RestMethod $url -Credential $credential -Method Post -Body $JSON -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    Write-Verbose ":: Waiting 2 seconds"
    Start-Sleep -s 2
}
function Stop-EventStore{


    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [String]    $url = "http://localhost:2113",
        [System.Management.Automation.PSCredential] $credential
    )

    Write-Verbose (":: Shutting Down the Server with User: $adminuser on URL:$url")

    $url = -join ( $url , '/admin/shutdown' )
    Write-Verbose (":: Rest URL: $url")

    $unsecureCreds = $credential.GetNetworkCredential()
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $unsecureCreds.UserName,$unsecureCreds.Password)))
    Remove-Variable unsecureCreds

    Write-Verbose ":: Invoking RestMethod"
    Invoke-RestMethod $url -Credential $credential -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    Write-Verbose ":: Waiting 2 sekunden"
    Start-Sleep -s 2
}
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
function Test-EventStoreUserHasPassword{

    [OutputType('System.Boolean')]
    [Cmdletbinding()]
    Param(
        [String]    $url = "http://localhost:2113",
        [System.Management.Automation.PSCredential] $credential
    )

    $user = $credential.UserName;
    Write-Verbose ":: UserName: $user"
    Write-Verbose ":: Check if User: $user Has Password on URL:$url"

    $unsecureCreds = $credential.GetNetworkCredential()
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $unsecureCreds.UserName,$unsecureCreds.Password)))
    Remove-Variable unsecureCreds

    $url = $url + '/users/' + $user

    Write-Verbose ":: Rest URL: $url"

    try {
        Write-Verbose ":: Try Invoke with Credentials $url"
        $response = Invoke-RestMethod $url -Credential $credential -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
        $responseStatusCode = $response.success
        Write-Verbose ":: Response StatusCode: $responseStatusCode"
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