configuration EventStoreNode
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [string]    $RootDrive = 'f:',
        [string]    $RootDirectory = 'eventstore',
        [string]    $BaseDirectoryName = $RootDrive + '\' + $RootDirectory,

        [boolean]   $UseSecure = $false,
        [boolean]   $UseFirewall = $false,
        [boolean]   $UseStartupTask = $false,
        [boolean]   $UseWindowsService = $false,
        [boolean]   $CheckRunning = $true,
        [boolean]   $IsClusterNode = $false,

        [string]    $CertificateFile = 'softwarepioniere_dev.pfx',
        [string]    $CertificateDownloadUrl = 'https://softwarepioniere.blob.core.windows.net/devcert/' + $CertificateFile,
        [securestring] $CertificatePassword =  (ConvertTo-SecureString "Password" -AsPlainText -Force),
        [string]    $CertificateFileName = $BaseDirectoryName + '\' + $CertificateFile,

        [string]    $ZipName401= 'EventStore-OSS-Win-v4.0.1',
        [string]    $ArchiveFile401 = $BaseDirectoryName + '\' + $ZipName401 + '.zip',

        [string]    $ZipName401Hotfix4= 'EventStore-OSS-Win-v4.0.1-hotfix4',
        [string]    $ArchiveFile401Hotfix4 = $BaseDirectoryName + '\' + $ZipName401Hotfix4 + '.zip',

        [string]    $ZipName403= 'EventStore-OSS-Win-v4.0.3',
        [string]    $ArchiveFile403 = $BaseDirectoryName + '\' + $ZipName403 + '.zip',

        [string]    $ZipName410= 'EventStore-OSS-Win-v4.1.0',
        [string]    $ArchiveFile410 = $BaseDirectoryName + '\' + $ZipName410 + '.zip' ,

        [string]    $ZipName411Hotfix1= 'EventStore-OSS-Win-v4.1.1-hotfix1',
        [string]    $ArchiveFile411Hotfix1 = $BaseDirectoryName + '\' + $ZipName411Hotfix1 + '.zip',
        [string]    $ServiceName411Hotfix1 = 'EventStore_411X1_' + $ProjectName,

        [string]    $ZipName500= 'EventStore-OSS-Win-v5.0.0',
        [string]    $ArchiveFile500 = $BaseDirectoryName + '\' + $ZipName500 + '.zip',
        [string]    $ServiceName500 = 'EventStore_500_' + $ProjectName,

        [string]    $ZipName501 = 'EventStore-OSS-Win-v5.0.1',
        [string]    $ArchiveFile501 = $BaseDirectoryName + '\' + $ZipName501 + '.zip',
        [string]    $ServiceName501 = 'EventStore_501_' + $ProjectName,

        [string]    $ZipName502 = 'EventStore-OSS-Win-v5.0.2',
        [string]    $ArchiveFile502 = $BaseDirectoryName + '\' + $ZipName502 + '.zip',
        [string]    $ServiceName502 = 'EventStore_502_' + $ProjectName,

        [string]    $ProjectName = 'es1',
        [string]    $ProjectDirectoryName = $BaseDirectoryName + '\' + $ProjectName,
        [string]    $ProjectDataDirectoryName = $ProjectDirectoryName + '\data',
        [string]    $ProjectLogDirectoryName = $ProjectDirectoryName + '\log',

        [string]    $ExtIp = '127.0.0.1',
        [string]    $IntIp = '127.0.0.1',
        [string]    $IntHttpPort = '2212',
        [string]    $ExtHttpPort = '2213',
        [string]    $IntTcpPort = '1212',
        [string]    $ExtTcpPort = '1213',
        # [string]    $IntSecureTcpPort = '3212',
        [string]    $ExtSecureTcpPort = '3213',

        [string]    $ClusterSize = '3',
        [string]    $GossipSeed = '',

        [string]    $CustomConfigFileContent = '',

                # [string]    $OldAdminPassword = 'changeit',
        # [string]    $OldOpsPassword = 'changeit',
        # [string]    $NewAdminPassword = 'changedit',
        # [string]    $NewOpsPassword = 'changedit',

        # [string]    $AppDirectory401 = $ProjectDirectoryName + '\' + $ZipName401 ,
        # [string]    $AppExe401 = $AppDirectory401 + '\EventStore.ClusterNode.exe',

        # [string]    $AppDirectory401Hotfix4 = $ProjectDirectoryName + '\' + $ZipName401Hotfix4,
        # [string]    $AppExe401Hotfix4 = $AppDirectory401Hotfix4 + '\EventStore.ClusterNode.exe',

        # [string]    $AppDirectory403 = $ProjectDirectoryName + '\' + $ZipName403,
        # [string]    $AppExe403 = $AppDirectory403 + '\EventStore.ClusterNode.exe',

        # [string]    $AppDirectory410 = $ProjectDirectoryName + '\' + $ZipName410,
        # [string]    $AppExe410 = $AppDirectory410 + '\EventStore.ClusterNode.exe',

        # [string]    $AppDirectory411Hotfix1 = $ProjectDirectoryName + '\' + $ZipName411Hotfix1,
        # [string]    $AppExe411Hotfix1 = $AppDirectory411Hotfix1 + '\EventStore.ClusterNode.exe',

        [string]    $AppDirectory500 = $ProjectDirectoryName + '\' + $ZipName500,
        [string]    $AppExe500 = $AppDirectory500 + '\EventStore.ClusterNode.exe',

        [string]    $AppDirectory501 = $ProjectDirectoryName + '\' + $ZipName501,
        [string]    $AppExe501 = $AppDirectory501 + '\EventStore.ClusterNode.exe',

        [string]    $AppDirectory502 = $ProjectDirectoryName + '\' + $ZipName502,
        [string]    $AppExe502 = $AppDirectory502 + '\EventStore.ClusterNode.exe',

        [string]    $ConfigFile =  $ProjectDirectoryName + '\config.yaml',
        [string]    $StarterFile = $ProjectDirectoryName + '\start.cmd',
        [string]    $AdminUrl = 'http://'+  $ExtIp  +  ':' + $ExtHttpPort,

        [string]    $CurrentAppExe = $AppExe502,
        [string]    $CurrentServiceName = $ServiceName502
    )

    Import-DscResource -ModuleName @{ModuleName='xNetworking';ModuleVersion='5.7.0.0'}
    Import-DSCResource -ModuleName @{ModuleName='FileDownloadDSC';ModuleVersion='1.1.0.0'}
    Import-DSCResource -ModuleName EventStoreDSC
    Import-DSCResource -ModuleName @{ModuleName='cChoco';ModuleVersion='2.4.0.0'}

    File BaseDirectory
    {
        Ensure          = 'Present'
        Type            = 'Directory'
        DestinationPath = $BaseDirectoryName
    }

    if ($UseSecure) {
        FileDownload DownloadCertificate
        {
            DependsOn = '[File]BaseDirectory'
            FileName = $CertificateFileName
            Url = $CertificateDownloadUrl
        }
    }

    cChocoInstaller installChoco
    {
        InstallDir = "c:\choco"
    }



    # FileDownload DownloadEventStoreV401
    # {
    #         DependsOn = '[File]BaseDirectory'
    #         FileName = $ArchiveFile401
    #         Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.1.zip'
    # }

    # FileDownload DownloadEventStoreV401Hotfix4
    # {
    #         DependsOn = '[File]BaseDirectory'
    #         FileName = $ArchiveFile401Hotfix4
    #         Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.1-hotfix4.zip'
    # }

    # FileDownload DownloadEventStoreV403
    # {
    #         DependsOn = '[File]BaseDirectory'
    #         FileName = $ArchiveFile403
    #         Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.3.zip'
    # }

    # FileDownload DownloadEventStoreV410
    # {
    #         DependsOn = '[File]BaseDirectory'
    #         FileName = $ArchiveFile410
    #         Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.1.0.zip'
    # }

    # FileDownload DownloadEventStoreV411Hotfix1
    # {
    #         DependsOn = '[File]BaseDirectory'
    #         FileName = $ArchiveFile411Hotfix1
    #         Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.1.1-hotfix1.zip'
    # }

    # FileDownload DownloadEventStoreV500
    # {
    #         DependsOn = '[File]BaseDirectory'
    #         FileName = $ArchiveFile500
    #         Url = 'https://eventstore.org/downloads/win/EventStore-OSS-Win-v5.0.0.zip'
    # }

    FileDownload DownloadEventStoreV501
    {
            DependsOn = '[File]BaseDirectory'
            FileName = $ArchiveFile501
            Url = 'https://eventstore.org/downloads/win/EventStore-OSS-Win-v5.0.1.zip'
    }

     FileDownload DownloadEventStoreV502
    {
            DependsOn = '[File]BaseDirectory'
            FileName = $ArchiveFile502
            Url = 'https://eventstore.org/downloads/win/EventStore-OSS-Win-v5.0.2.zip'
    }

    if ($UseFirewall) {

        # =========================== EventStore Firewall ======================================================
        xFirewall ( 'ES_' + $ProjectName + '_FirewallEventStoreInternal' )
        {
            Name                  = 'EventStore Allow_EventStore_Int_In_' + $ProjectName
            DisplayName           = 'EventStore Allow inbound Internal Event Store traffic ' + $ProjectName
            Group                 = 'EventStore Firewall Rule Group'
            Ensure                = 'Present'
            Enabled               = 'True'
            Profile               = ('Domain', 'Private', 'Public')
            Direction             = 'Inbound'
            LocalPort             = ( $IntTcpPort , $IntHttpPort )
            Protocol              = 'TCP'
        }

        if ($UseSecure) {

            xFirewall ( 'ES_' + $ProjectName + '_FirewallEventStoreExternal' )
            {
                Name                  = 'EventStore Allow_EventStore_Ext_In_' + $ProjectName
                DisplayName           = 'EventStore Allow inbound External Event Store traffic ' + $ProjectName
                Group                 = 'EventStore Firewall Rule Group'
                Ensure                = 'Present'
                Enabled               = 'True'
                Profile               = ('Domain', 'Private', 'Public')
                Direction             = 'Inbound'
                LocalPort             = ($ExtTcpPort, $ExtHttpPort, $ExtSecureTcpPort )
                Protocol              = 'TCP'
            }

        }else{

            xFirewall ( 'ES_' + $ProjectName + '_FirewallEventStoreExternal' )
            {
                Name                  = 'EventStore Allow_EventStore_Ext_In_' + $ProjectName
                DisplayName           = 'EventStore Allow inbound External Event Store traffic ' + $ProjectName
                Group                 = 'EventStore Firewall Rule Group'
                Ensure                = 'Present'
                Enabled               = 'True'
                Profile               = ('Domain', 'Private', 'Public')
                Direction             = 'Inbound'
                LocalPort             = ($ExtTcpPort, $ExtHttpPort )
                Protocol              = 'TCP'
            }
        }
    }

    # =========================== EventStore Files ======================================================


    File ( 'ES_' + $ProjectName + '_Directory')
    {
        DependsOn       = '[File]BaseDirectory'
        Ensure          = 'Present'
        Type            = 'Directory'
        DestinationPath = $ProjectDirectoryName
    }

    # Archive ( 'ES_' + $ProjectName + '_EventStoreV401')
    # {
    #     DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV401'
    #     Ensure      = 'Present'  # You can also set Ensure to 'Absent'
    #     Path        = $ArchiveFile401
    #     Destination = $AppDirectory401
    # }

    # Archive ( 'ES_' + $ProjectName + '_EventStoreV401Hotfix4')
    # {
    #     DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV401Hotfix4'
    #     Ensure      = 'Present'  # You can also set Ensure to 'Absent'
    #     Path        = $ArchiveFile401Hotfix4
    #     Destination = $AppDirectory401Hotfix4
    # }

    # Archive ( 'ES_' + $ProjectName + '_EventStoreV403')
    # {
    #     DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV403'
    #     Ensure      = 'Present'  # You can also set Ensure to 'Absent'
    #     Path        = $ArchiveFile403
    #     Destination = $AppDirectory403
    # }

    # Archive ( 'ES_' + $ProjectName + '_EventStoreV410')
    # {
    #     DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV410'
    #     Ensure      = 'Present'  # You can also set Ensure to 'Absent'
    #     Path        = $ArchiveFile410
    #     Destination = $AppDirectory410
    # }

    # Archive ( 'ES_' + $ProjectName + '_EventStoreV411Hotfix1')
    # {
    #     DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV411Hotfix1'
    #     Ensure      = 'Present'  # You can also set Ensure to 'Absent'
    #     Path        = $ArchiveFile411Hotfix1
    #     Destination = $AppDirectory411Hotfix1
    # }

    # Archive ( 'ES_' + $ProjectName + '_EventStoreV500')
    # {
    #     DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV500'
    #     Ensure      = 'Present'  # You can also set Ensure to 'Absent'
    #     Path        = $ArchiveFile500
    #     Destination = $AppDirectory500
    # }

    Archive ( 'ES_' + $ProjectName + '_EventStoreV501')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV501'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile501
        Destination = $AppDirectory501
    }

    Archive ( 'ES_' + $ProjectName + '_EventStoreV502')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV502'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile502
        Destination = $AppDirectory502
    }

    if ($UseSecure) {

        if ($IsClusterNode) {
            File ( 'ES_'+ $ProjectName + '_ConfigFile')
            {
                DependsOn       = ('[File]ES_' + $ProjectName + '_Directory') , '[FileDownload]DownloadCertificate'
                Ensure          = 'Present'
                DestinationPath = $ConfigFile
                Type            = 'File'
                Contents        =
'RunProjections: all
Log: ' + $ProjectLogDirectoryName + '
Db: ' + $ProjectDataDirectoryName + '
StatsPeriodSec: 120
DisableHTTPCaching: true
DiscoverViaDns: false
ClusterSize: ' + $ClusterSize + '
GossipSeed: ' + $GossipSeed + '
ExtIp: ' + $ExtIp + '
IntIp: ' + $IntIp + '
IntHttpPort: ' + $IntHttpPort + '
ExtHttpPort: ' + $ExtHttpPort + '
IntTcpPort: ' + $IntTcpPort + '
ExtTcpPort: ' + $ExtTcpPort + '
ExtSecureTcpPort: ' + $ExtSecureTcpPort + '
CertificateFile: ' + $CertificateFileName + '
CertificatePassword: ' + (New-Object System.Management.Automation.PSCredential('xxx', $CertificatePassword)).GetNetworkCredential().Password + 
$CustomConfigFileContent
# IntSecureTcpPort: ' + $IntSecureTcpPort + '
            }

        }else{

            File ( 'ES_'+ $ProjectName + '_ConfigFile')
            {
                DependsOn       = ('[File]ES_' + $ProjectName + '_Directory') , '[FileDownload]DownloadCertificate'
                Ensure          = 'Present'
                DestinationPath = $ConfigFile
                Type            = 'File'
                Contents        =
'RunProjections: all
Log: ' + $ProjectLogDirectoryName + '
Db: ' + $ProjectDataDirectoryName + '
StatsPeriodSec: 120
DisableHTTPCaching: true
ExtIp: ' + $ExtIp + '
IntIp: ' + $IntIp + '
IntHttpPort: ' + $IntHttpPort + '
ExtHttpPort: ' + $ExtHttpPort + '
IntTcpPort: ' + $IntTcpPort + '
ExtTcpPort: ' + $ExtTcpPort + '
ExtSecureTcpPort: ' + $ExtSecureTcpPort + '
CertificateFile: ' + $CertificateFileName + '
CertificatePassword: ' + (New-Object System.Management.Automation.PSCredential('xxx', $CertificatePassword)).GetNetworkCredential().Password + 
$CustomConfigFileContent
# IntSecureTcpPort: ' + $IntSecureTcpPort + '
            }
        }
    }
    else{
        if ($IsClusterNode) {
            File ( 'ES_'+ $ProjectName + '_ConfigFile')
            {
                DependsOn       = '[File]ES_' + $ProjectName + '_Directory'
                Ensure          = 'Present'
                DestinationPath = $ConfigFile
                Type            = 'File'
                Contents        =
'RunProjections: all
Log: ' + $ProjectLogDirectoryName + '
Db: ' + $ProjectDataDirectoryName + '
StatsPeriodSec: 120
DisableHTTPCaching: true
DiscoverViaDns: false
ClusterSize: ' + $ClusterSize + '
GossipSeed: ' + $GossipSeed + '
ExtIp: ' + $ExtIp + '
IntIp: ' + $IntIp + '
IntHttpPort: ' + $IntHttpPort + '
ExtHttpPort: ' + $ExtHttpPort + '
IntTcpPort: ' + $IntTcpPort + '
ExtTcpPort: ' + $ExtTcpPort +
$CustomConfigFileContent
            }
        }
        else{

            File ( 'ES_'+ $ProjectName + '_ConfigFile')
            {
                DependsOn       = '[File]ES_' + $ProjectName + '_Directory'
                Ensure          = 'Present'
                DestinationPath = $ConfigFile
                Type            = 'File'
                Contents        =
'RunProjections: all
Log: ' + $ProjectLogDirectoryName + '
Db: ' + $ProjectDataDirectoryName + '
StatsPeriodSec: 120
DisableHTTPCaching: true
ExtIp: ' + $ExtIp + '
IntIp: ' + $IntIp + '
IntHttpPort: ' + $IntHttpPort + '
ExtHttpPort: ' + $ExtHttpPort + '
IntTcpPort: ' + $IntTcpPort + '
ExtTcpPort: ' + $ExtTcpPort +
$CustomConfigFileContent
            }
        }
    }


    File ( 'ES_'+ $ProjectName + '_StartFile')
    {
        DependsOn       = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure          = 'Present'
        DestinationPath = $StarterFile
        Type            = 'File'
        Contents        =
'

START ' + $CurrentAppExe + ' --config=' + $ConfigFile
    }


    # if (!$UseWindowsService) {

    #     WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV410Process')
    #     {
    #         Arguments   = '--config=' + $ConfigFile
    #         Path        = $AppExe410
    #         DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
    #         Ensure      = 'Absent'
    #     }

    #     WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV411Hotfix1Process')
    #     {
    #         Arguments   = '--config=' + $ConfigFile
    #         Path        = $AppExe411Hotfix1
    #         DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
    #         Ensure      = 'Absent'
    #     }

    #     if ($CheckRunning) {
    #         WaitForEventStore('ES_' + $ProjectName + '_EventStoreRunning')
    #         {
    #             DependsOn   = '[WindowsProcess]'+ 'ES_' + $ProjectName + '_EventStoreV411Hotfix1Process'
    #             Url         = $AdminUrl
    #         }
    #     }

    #     if ($UseStartupTask) {
    #         EventStoreStartupTask('ES_' + $ProjectName + '_EventStoreStartupTask')
    #         {
    #             DependsOn   = '[WindowsProcess]'+ 'ES_' + $ProjectName + '_EventStoreV411Hotfix1Process'
    #             TaskName    = 'EventStore Startup - ' + $ProjectName
    #             Directory   = $ProjectDirectoryName
    #         }
    #     }
    # }

    if ($UseWindowsService) {

        cChocoPackageInstaller installnssm
        {
            Name = "nssm"
            DependsOn = "[cChocoInstaller]installChoco"
            AutoUpgrade = $True
        }

        EventStoreService('ES_' + $ProjectName + '_EventStoreInstaller') {
            DependsOn   = '[cChocoPackageInstaller]installnssm'
            ServiceName =  $CurrentServiceName
            App = $CurrentAppExe
            AppArgs = ' --config=' + $ConfigFile
        }

        # Service ('ES_' + $ProjectName + '_Service411Hotfix1')
        # {
        #     Name        = $ServiceName411Hotfix1
        #     StartupType = 'Disabled'
        #     State       = 'Stopped'
        #     Ensure      = 'Absent'
        # }

        Service ('ES_' + $ProjectName + '_Service500')
        {
            Name        = $ServiceName500
            StartupType = 'Disabled'
            State       = 'Stopped'
            Ensure      = 'Absent'
        }

        Service ('ES_' + $ProjectName + '_Service501')
        {
            Name        = $ServiceName500
            StartupType = 'Disabled'
            State       = 'Stopped'
            Ensure      = 'Absent'
        }

        Service ('ES_' + $ProjectName + '_Service502')
        {
            Name        = $ServiceName502
            StartupType = 'Automatic'
            State       = 'Running'

        }

        # if ($CheckRunning) {
        #     WaitForEventStore('ES_' + $ProjectName + '_EventStoreRunning1')
        #     {
        #         DependsOn   = '[Service]'+ 'ES_' + $ProjectName + '_Service411Hotfix1'
        #         Url         = $AdminUrl
        #     }
        # }

        if ($CheckRunning) {
            WaitForEventStore('ES_' + $ProjectName + '_EventStoreRunning1')
            {
                DependsOn   = '[Service]'+ 'ES_' + $ProjectName + '_Service502'
                Url         = $AdminUrl
            }
        }
    }



    # EventStoreLogin('ES_' + $ProjectName + '_Login_Admin')
    # {
    #     DependsOn       = '[EventStoreRunning]' + 'ES_' + $ProjectName + '_EventStoreRunning'
    #     Url             = $AdminUrl
    #     User            = 'admin'
    #     Password        = $OldAdminPassword
    #     NewPassword     = $NewAdminPassword
    #     AdminUser       = 'admin'
    #     AdminPassword   = $OldAdminPassword
    # }

    # EventStoreLogin('ES_' + $ProjectName + '_Login_Ops')
    # {
    #     DependsOn       = '[EventStoreLogin]' + 'ES_' + $ProjectName + '_Login_Admin'
    #     Url             = $AdminUrl
    #     User            = 'ops'
    #     Password        = $OldOpsPassword
    #     NewPassword     = $NewOpsPassword
    #     AdminUser       = 'admin'
    #     AdminPassword   = $NewAdminPassword
    # }

}