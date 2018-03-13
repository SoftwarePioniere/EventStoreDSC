configuration EventStoreProject
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [string]    $DataDrive = "f:",
        [string]    $ESName = "es1",
        [string]    $ExtIp = "10.0.0.4",
        [string]    $IntHttpPort = "2212",
        [string]    $ExtHttpPort = "2213",
        [string]    $IntTcpPort = "1212",
        [string]    $ExtTcpPort = "1213",
        [string]    $IntSecureTcpPort = "3212",
        [string]    $ExtSecureTcpPort = "3213",
        [string]    $CertificateFile = "softwarepioniere_dev.pfx",
        [string]    $CertificateDownloadUrl =  "https://softwarepioniere.blob.core.windows.net/devcert/" + $CertificateFile,
        [string]    $CertificatePassword = "Password",

        [string]    $OldAdminPassword = "changeit",
        [string]    $OldOpsPassword = "changeit",
        [string]    $NewAdminPassword = "changedit",
        [string]    $NewOpsPassword = "changedit",

        [string]    $ZipName401= "EventStore-OSS-Win-v4.0.1",
        [string]    $ArchiveFile401 = $DataDrive + "\" + $ZipName401 + ".zip",
        [string]    $AppDirectory401 = $DataDrive + "\eventstore_" + $ESName + "\" + $ZipName401,
        [string]    $AppExe401 = $AppDirectory401 + "\EventStore.ClusterNode.exe",

        [string]    $ZipName401Hotfix4= "EventStore-OSS-Win-v4.0.1-hotfix4",
        [string]    $ArchiveFile401Hotfix4 = $DataDrive + "\" + $ZipName401Hotfix4 + ".zip",
        [string]    $AppDirectory401Hotfix4 = $DataDrive + "\eventstore_" + $ESName + "\" + $ZipName401Hotfix4,
        [string]    $AppExe401Hotfix4 = $AppDirectory401Hotfix4 + "\EventStore.ClusterNode.exe",

        [string]    $ZipName403= "EventStore-OSS-Win-v4.0.3",
        [string]    $ArchiveFile403 = $DataDrive + "\" + $ZipName403 + ".zip",
        [string]    $AppDirectory403 = $DataDrive + "\eventstore_" + $ESName + "\" + $ZipName403,
        [string]    $AppExe403 = $AppDirectory403 + "\EventStore.ClusterNode.exe",

        [string]    $ZipName410= "EventStore-OSS-Win-v4.1.0",
        [string]    $ArchiveFile410 = $DataDrive + "\" + $ZipName410 + ".zip",
        [string]    $AppDirectory410 = $DataDrive + "\eventstore_" + $ESName + "\" + $ZipName410,
        [string]    $AppExe410 = $AppDirectory410 + "\EventStore.ClusterNode.exe",
        
        [string]    $BaseDirectory = $DataDrive + "\eventstore_" + $ESName,
        [string]    $ConfigFile =  $BaseDirectory + "\config.yaml",
        [string]    $StarterFile = $DataDrive + "\eventstore_" + $ESName + "\start.cmd",
        [string]    $AdminUrl = "http://"+  $ExtIp  +  ":" + $ExtHttpPort
    )

    Import-DscResource -ModuleName @{ModuleName="xNetworking";ModuleVersion="5.0.0.0"}
    Import-DSCResource -ModuleName @{ModuleName="FileDownloadDSC";ModuleVersion="1.0.5"}
    Import-DSCResource -ModuleName EventStoreDSC

    FileDownload DownloadCertificate
    {
        FileName = $DataDrive + "\" + $CertificateFile
        Url = $CertificateDownloadUrl
    }

    FileDownload DownloadEventStoreV401
    {
            DependsOn = "[FileDownload]DownloadCertificate"
            FileName = $ArchiveFile401
            Url = "https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.1.zip"
    }

    FileDownload DownloadEventStoreV401Hotfix4
    {
            DependsOn = "[FileDownload]DownloadCertificate"
            FileName = $ArchiveFile401Hotfix4
            Url = "https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.1-hotfix4.zip"
    }

    FileDownload DownloadEventStoreV403
    {
            DependsOn = "[FileDownload]DownloadCertificate"
            FileName = $ArchiveFile403
            Url = "https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.3.zip"
    }

    FileDownload DownloadEventStoreV410
    {
            DependsOn = "[FileDownload]DownloadCertificate"
            FileName = $ArchiveFile410
            Url = "https://eventstore.org/downloads/EventStore-OSS-Win-v4.1.0.zip"
    }

    # =========================== EventStore Firewall ======================================================
    xFirewall ( "ES_" + $ESName + "_FirewallEventStoreInternal" )
    {
        Name                  = "EventStore Allow_EventStore_Int_In_" + $ESName
        DisplayName           = "EventStore Allow inbound Internal Event Store traffic " + $ESName
        Group                 = "EventStore Firewall Rule Group"
        Ensure                = "Present"
        Enabled               = "True"
        Profile               = ("Domain", "Private", "Public")
        Direction             = "Inbound"
        LocalPort             = ( $IntTcpPort , $IntHttpPort , $IntSecureTcpPort )
        Protocol              = "TCP"
    }

    xFirewall ( "ES_" + $ESName + "_FirewallEventStoreExternal" )
    {
        Name                  = "EventStore Allow_EventStore_Ext_In_" + $ESName
        DisplayName           = "EventStore Allow inbound External Event Store traffic " + $ESName
        Group                 = "EventStore Firewall Rule Group"
        Ensure                = "Present"
        Enabled               = "True"
        Profile               = ("Domain", "Private", "Public")
        Direction             = "Inbound"
        LocalPort             = ($ExtTcpPort, $ExtHttpPort, $ExtSecureTcpPort )
        Protocol              = "TCP"
    }

    # =========================== EventStore Files ======================================================

    File ( "ES_" + $ESName + "_BaseDirectory")
    {

        Ensure          = "Present"
        Type            = "Directory"
        DestinationPath = $BaseDirectory
    }

    Archive ( "ES_" + $ESName + "_EventStoreV401")
    {
        DependsOn   = "[File]ES_" + $ESName + "_BaseDirectory"
        Ensure      = "Present"  # You can also set Ensure to "Absent"
        Path        = $ArchiveFile401
        Destination = $AppDirectory401
    }

    Archive ( "ES_" + $ESName + "_EventStoreV401Hotfix4")
    {
        DependsOn   = "[File]ES_" + $ESName + "_BaseDirectory"
        Ensure      = "Present"  # You can also set Ensure to "Absent"
        Path        = $ArchiveFile401Hotfix4
        Destination = $AppDirectory401Hotfix4
    }

    Archive ( "ES_" + $ESName + "_EventStoreV403")
    {
        DependsOn   = "[File]ES_" + $ESName + "_BaseDirectory"
        Ensure      = "Present"  # You can also set Ensure to "Absent"
        Path        = $ArchiveFile403
        Destination = $AppDirectory403
    }

    Archive ( "ES_" + $ESName + "_EventStoreV410")
    {
        DependsOn   = "[File]ES_" + $ESName + "_BaseDirectory"
        Ensure      = "Present"  # You can also set Ensure to "Absent"
        Path        = $ArchiveFile410
        Destination = $AppDirectory410
    }

    File ( "ES_"+ $ESName + "_ConfigFile")
    {
        DependsOn       = "[File]ES_" + $ESName + "_BaseDirectory"
        Ensure          = "Present"
        DestinationPath = $ConfigFile
        Type            = "File"
        Contents        =
"RunProjections: all
Log: " +  $BaseDirectory + "\log
Db: " + $BaseDirectory + "\data
StatsPeriodSec: 120
DisableHTTPCaching: true
ExtIp: " + $ExtIp + "
IntHttpPort: " + $IntHttpPort + "
ExtHttpPort: " + $ExtHttpPort + "
IntTcpPort: " + $IntTcpPort + "
ExtTcpPort: " + $ExtTcpPort  + "
IntSecureTcpPort: " + $IntSecureTcpPort + "
ExtSecureTcpPort: " + $ExtSecureTcpPort + "
CertificateFile: " + $DataDrive + "\" + $CertificateFile + "
CertificatePassword: " + $CertificatePassword

    }

    File ( "ES_"+ $ESName + "_StartFile")
    {
        DependsOn       = "[File]ES_" + $ESName + "_BaseDirectory"
        Ensure          = "Present"
        DestinationPath = $StarterFile
        Type            = "File"
        Contents        =
"

START " + $AppExe403 + " --config=" + $ConfigFile
    }



    WindowsProcess ( "ES_" + $ESName + "_EventStoreV401Process")
    {
        Arguments   = "--config=" + $ConfigFile
        Path        = $AppExe401
        DependsOn   = "[File]ES_"+ $ESName + "_ConfigFile"
        Ensure      = "Absent"
    }

    WindowsProcess ( "ES_" + $ESName + "_EventStoreV401Hotfix4Process")
    {
        Arguments   = "--config=" + $ConfigFile
        Path        = $AppExe401Hotfix4
        DependsOn   = "[File]ES_"+ $ESName + "_ConfigFile"
        Ensure      = "Absent"
    }

    WindowsProcess ( "ES_" + $ESName + "_EventStoreV403Process")
    {
        Arguments   = "--config=" + $ConfigFile
        Path        = $AppExe403
        DependsOn   = "[File]ES_"+ $ESName + "_ConfigFile"
        Ensure      = "Absent"
    }

    WindowsProcess ( "ES_" + $ESName + "_EventStoreV410Process")
    {
        Arguments   = "--config=" + $ConfigFile
        Path        = $AppExe410
        DependsOn   = "[File]ES_"+ $ESName + "_ConfigFile"
        Ensure      = "Present"
    }

    EventStoreStartupTask("ES_" + $ESName + "_EventStoreStartupTask") 
    {
        DependsOn   = "[WindowsProcess]"+ "ES_" + $ESName + "_EventStoreV410Process"
        TaskName    = $ESName + "EventStore Startup"
        Directory   = $BaseDirectory
        Argument    = $ESName
    }

    # Script ("ES_" + $ESName + "_EventStoreStartupTask")
    # {
    #     DependsOn   = "[WindowsProcess]"+ "ES_" + $ESName + "_EventStoreV410Process"
    #     SetScript =
    #     {
    #             $taskname = $using:ESName + "EventStore Startup";
    #             $dir = $using:BaseDirectory;
    #             $ex = $using:StarterFile;
    #             $arg = $using:ESName;

    #                 #ANFANG function CreateStartupTask aus Datei Test-EventStoreStartupTask.ps1
    #                 Write-Verbose ":Create StartupTask with $arg"

    #                 If ( Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskname } )
    #                 {
    #                     Write-Verbose ":: Unregister existing Task"
    #                     Unregister-ScheduledTask $taskname -Confirm:$false
    #                 }

    #                 $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30

    #                 Write-Host ":: New-ScheduledTaskAction -Execute $ex -WorkingDirectory $dir -Argument $arg"
    #                 $action =  New-ScheduledTaskAction -Execute $ex -WorkingDirectory $dir -Argument $arg
    #                 $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    #                 Write-Verbose ":: Register Scheduled Task"
    #                 Register-ScheduledTask -TaskName $taskname -Trigger $trigger -Action $action -Principal $principal
    #                 #ENDE function CreateStartupTask aus Datei Test-EventStoreStartupTask.ps1

    #     }
    #     TestScript = {

    #             $taskname = $using:ESName + "EventStore Startup";
    #             $arg = $using:ESName;

    #                 #ANFANG function CheckStartupTaskExists aus Datei Test-EventStoreStartupTask.ps1

    #                 $task= Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskname }
    #                 If ( $task )
    #                 {
    #                     Write-Verbose ":: task with name found"

    #                     $action = $task.Actions[0]

    #                     if ( $action )
    #                     {
    #                         Write-Verbose ":: action found"
    #                         $action | Out-String

    #                         $actionarg =  $action.Arguments | Out-String
    #                         Write-Verbose ":: action arguments: $actionarg"
    #                         Write-Verbose ":: args: $arg"
    #                         if ( $actionarg.ToLowerInvariant().Trim() -eq $arg.ToLowerInvariant().Trim())
    #                         {
    #                             return $true;
    #                         }
    #                     }
    #                 }

    #                 return $false

    #                 #ENDE function CheckStartupTaskExists aus Datei Test-EventStoreStartupTask.ps1
    #      }
    #     GetScript = {  }
    # }

    Script ( "ES_" + $ESName + "_WaitForProcess")
    {
        DependsOn = "[WindowsProcess]ES_" + $ESName + "_EventStoreV410Process"
        SetScript =
        {
            throw "EventStore is not running"
        }
        TestScript = {

            [String]    $url = $using:AdminUrl
            Write-Verbose "::Teste URL $url"

            $i = 1;
            while ($i -ne 10)
            {
                Write-Verbose "::Test Versuch $i / 10"
                try {
                    Write-Verbose "::Try Invoke-RestMethod with Get on $url"
                    $response = Invoke-RestMethod $url -Method Get
                    Write-Verbose "::Response $response"
                    return $true
                }
                catch {

                    Write-Verbose ":: $_"
                    #return $false
                    Write-Verbose "::Warte 2 sekunden"
                    Start-Sleep -s 2
                }

                $i=$i+1;
            }

            return $false
        }

        GetScript = {  }
    }

# =========================== EventStore Tecplus Passwords ======================================================

        Script ( "ES_" + $ESName + "_ChangeAdminPasswort")
        {

            DependsOn   = "[Script]ES_" + $ESName + "_WaitForProcess"
            SetScript =
            {

                #das neue passwort setzen
                [String]    $url = $using:AdminUrl
                [String]    $user = 'admin'
                [String]    $adminuser = 'admin'
                [String]    $newpassword = $using:NewAdminPassword
                [String]    $adminpassword = $using:OldAdminPassword


                    #ANFANG function Test-SetUserPassword aus Datei Test-EventStoreChangeUserPassword.ps1
                    Write-Verbose ":Setting the NewPassword:$newpassword for User: $user with Admin User: $adminuser and AdminPassword:$adminpassword on URL:$url"

                    $url = -join ( $url , '/users/', $user , '/command/reset-password' )
                    Write-Verbose "::Rest URL: $url"

                    $secpasswd = ConvertTo-SecureString $adminpassword -AsPlainText -Force
                    $credential = New-Object System.Management.Automation.PSCredential($adminuser, $secpasswd)
                    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$password)))

                    $JSON = '{"newPassword":"' + $newpassword + '"}'

                    Write-Verbose "::JSON: $JSON"
                    Write-Verbose "::Invoking RestMethod"
                    Invoke-RestMethod $url -Credential $credential -Method Post -Body $JSON -ContentType "application/json" -Headers @{Authorization = "Basic $base64AuthInfo" }

                    Write-Verbose "::Warte 2 sekunden"
                    Start-Sleep -s 2
                    #ENDE  function Test-SetUserPassword aus Datei Test-EventStoreChangeUserPassword.ps1

            }
            TestScript = {
                    # hier wird false zurück gegeben wenn sich der benutzer mit dem neuen passwort nicht anmelden kann
                    # hier wird false zurück gegeben, wenn das alte password gültig ist

                    [String]    $url = $using:AdminUrl
                    [String]    $user = 'admin'
                    [String]    $password = $using:NewAdminPassword


                        #ANFANG function TestUserHasPassword aus Datei Test-EventStoreUserPassword.ps1
                        Write-Verbose ":Check if User: $user Has Password:$password on URL:$url"

                        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
                        $credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)
                        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$password)))

                        $url = $url + '/users/' + $user
                        Write-Verbose "::Rest URL: $url"

                        try {
                            Write-Verbose "::Try Invoke with Credentials $url"
                            $response = Invoke-RestMethod  $url -Credential $credential -Method Get -Headers @{Authorization = "Basic $base64AuthInfo" }
                            Write-Verbose "::Response: $response"
                            Write-Verbose "::Benutzer $user kann sich mit dem Kennort anmelden"
                            return $true # benutzer kann
                        }
                        catch {

                            Write-Verbose "::$_"
                            if( $_.Exception.Response.StatusCode.Value__ -ne 401 )
                            {
                                    Write-Verbose "::Not a 401 Status - fehler"
                                    throw $_.Exception
                            }

                            if( $_.Exception.Response.StatusCode.Value__ -eq 401 )
                            {
                                    Write-Verbose "::401 Status - Benutzer kann sich nicht mit dem Kennwort anmelden"
                                    return $false;
                            }
                        }
                        #ENDE  function TestUserHasPassword aus Datei Test-EventStoreUserPassword.ps1

                }
            GetScript = {  }
        }


        Script ( "ES_" + $ESName + "_ChangeOpsPasswort")
        {

            DependsOn   = "[Script]ES_" + $ESName + "_ChangeAdminPasswort"
            SetScript =
            {

                #das neue passwort setzen
                [String]    $url = $using:AdminUrl
                [String]    $user = 'ops'
                [String]    $newpassword = $using:NewOpsPassword
                [String]    $adminuser = 'admin'
                [String]    $adminpassword = $using:NewAdminPassword

                    #ANFANG function Test-SetUserPassword aus Datei Test-EventStoreChangeUserPassword.ps1
                    Write-Verbose ":Setting the NewPassword:$newpassword for User: $user with Admin User: $adminuser and AdminPassword:$adminpassword on URL:$url"

                    $url = -join ( $url , '/users/', $user , '/command/reset-password' )
                    Write-Verbose "::Rest URL: $url"

                    $secpasswd = ConvertTo-SecureString $adminpassword -AsPlainText -Force
                    $credential = New-Object System.Management.Automation.PSCredential($adminuser, $secpasswd)
                    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$password)))

                    $JSON = '{"newPassword":"' + $newpassword + '"}'

                    Write-Verbose "::JSON: $JSON"
                    Write-Verbose "::Invoking RestMethod"
                    Invoke-RestMethod $url -Credential $credential -Method Post -Body $JSON -ContentType "application/json" -Headers @{Authorization = "Basic $base64AuthInfo" }

                    Write-Verbose "::Warte 2 sekunden"
                    Start-Sleep -s 2
                    #ENDE  function Test-SetUserPassword aus Datei Test-EventStoreChangeUserPassword.ps1

            }
            TestScript = {
                    # hier wird false zurück gegeben wenn sich der benutzer mit dem neuen passwort nicht anmelden kann
                    # hier wird false zurück gegeben, wenn das alte password gültig ist

                    [String]    $url = $using:AdminUrl
                    [String]    $user = 'ops'
                    [String]    $password =  $using:NewOpsPassword

                        #ANFANG function TestUserHasPassword aus Datei Test-EventStoreUserPassword.ps1
                        Write-Verbose ":Check if User: $user Has Password:$password on URL:$url"

                        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
                        $credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)
                        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$password)))

                        $url = $url + '/users/' + $user
                        Write-Verbose "::Rest URL: $url"

                        try {
                            Write-Verbose "::Try Invoke with Credentials $url"
                            $response = Invoke-RestMethod  $url -Credential $credential -Method Get -Headers @{Authorization = "Basic $base64AuthInfo" }
                            Write-Verbose "::Response: $response"
                            Write-Verbose "::Benutzer $user kann sich mit dem Kennort anmelden"
                            return $true # benutzer kann
                        }
                        catch {

                            Write-Verbose "::$_"
                            if( $_.Exception.Response.StatusCode.Value__ -ne 401 )
                            {
                                    Write-Verbose "::Not a 401 Status - fehler"
                                    throw $_.Exception
                            }

                            if( $_.Exception.Response.StatusCode.Value__ -eq 401 )
                            {
                                    Write-Verbose "::401 Status - Benutzer kann sich nicht mit dem Kennwort anmelden"
                                    return $false;
                            }
                        }
                        #ENDE  function TestUserHasPassword aus Datei Test-EventStoreUserPassword.ps1

                }
            GetScript = {  }
        }

}