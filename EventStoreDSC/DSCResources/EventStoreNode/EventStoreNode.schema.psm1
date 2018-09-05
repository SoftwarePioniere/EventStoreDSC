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
        [boolean]   $UseStartupTask = $true,
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

        [string]    $ProjectName = 'es1',
        [string]    $ProjectDirectoryName = $BaseDirectoryName + '\' + $ProjectName,

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

        [string]    $AppDirectory410 = $ProjectDirectoryName + '\' + $ZipName410,
        [string]    $AppExe410 = $AppDirectory410 + '\EventStore.ClusterNode.exe',

        [string]    $AppDirectory411Hotfix1 = $ProjectDirectoryName + '\' + $ZipName411Hotfix1,
        [string]    $AppExe411Hotfix1 = $AppDirectory411Hotfix1 + '\EventStore.ClusterNode.exe',

        [string]    $ConfigFile =  $ProjectDirectoryName + '\config.yaml',
        [string]    $StarterFile = $ProjectDirectoryName + '\start.cmd',
        [string]    $AdminUrl = 'http://'+  $ExtIp  +  ':' + $ExtHttpPort,

        [string]    $CurrentAppExe = $AppExe411Hotfix1
    )

    Import-DscResource -ModuleName @{ModuleName='xNetworking';ModuleVersion='5.7.0.0'}
    Import-DSCResource -ModuleName @{ModuleName='FileDownloadDSC';ModuleVersion='1.0.10'}
    Import-DSCResource -ModuleName EventStoreDSC

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

    FileDownload DownloadEventStoreV410
    {
            DependsOn = '[File]BaseDirectory'
            FileName = $ArchiveFile410
            Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.1.0.zip'
    }

    FileDownload DownloadEventStoreV411Hotfix1
    {
            DependsOn = '[File]BaseDirectory'
            FileName = $ArchiveFile411Hotfix1
            Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.1.1-hotfix1.zip'
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

    Archive ( 'ES_' + $ProjectName + '_EventStoreV410')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV410'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile410
        Destination = $AppDirectory410
    }

    Archive ( 'ES_' + $ProjectName + '_EventStoreV411Hotfix1')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV411Hotfix1'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile411Hotfix1
        Destination = $AppDirectory411Hotfix1
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
Log: ' +  $ProjectDirectoryName + '\log
Db: ' + $ProjectDirectoryName + '\data
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
CertificatePassword: ' + (New-Object System.Management.Automation.PSCredential('xxx', $CertificatePassword)).GetNetworkCredential().Password
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
Log: ' +  $ProjectDirectoryName + '\log
Db: ' + $ProjectDirectoryName + '\data
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
CertificatePassword: ' + (New-Object System.Management.Automation.PSCredential('xxx', $CertificatePassword)).GetNetworkCredential().Password
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
Log: ' +  $ProjectDirectoryName + '\log
Db: ' + $ProjectDirectoryName + '\data
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
ExtTcpPort: ' + $ExtTcpPort
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
Log: ' +  $ProjectDirectoryName + '\log
Db: ' + $ProjectDirectoryName + '\data
StatsPeriodSec: 120
DisableHTTPCaching: true
ExtIp: ' + $ExtIp + '
IntIp: ' + $IntIp + '
IntHttpPort: ' + $IntHttpPort + '
ExtHttpPort: ' + $ExtHttpPort + '
IntTcpPort: ' + $IntTcpPort + '
ExtTcpPort: ' + $ExtTcpPort
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



    # WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV401Process')
    # {
    #     Arguments   = '--config=' + $ConfigFile
    #     Path        = $AppExe401
    #     DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
    #     Ensure      = 'Absent'
    # }

    # WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV401Hotfix4Process')
    # {
    #     Arguments   = '--config=' + $ConfigFile
    #     Path        = $AppExe401Hotfix4
    #     DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
    #     Ensure      = 'Absent'
    # }

    # WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV403Process')
    # {
    #     Arguments   = '--config=' + $ConfigFile
    #     Path        = $AppExe403
    #     DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
    #     Ensure      = 'Absent'
    # }

    WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV410Process')
    {
        Arguments   = '--config=' + $ConfigFile
        Path        = $AppExe410
        DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure      = 'Absent'
    }

    WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV411Hotfix1Process')
    {
        Arguments   = '--config=' + $ConfigFile
        Path        = $AppExe411Hotfix1
        DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure      = 'Present'
    }

    if ($UseStartupTask) {
        EventStoreStartupTask('ES_' + $ProjectName + '_EventStoreStartupTask')
        {
            DependsOn   = '[WindowsProcess]'+ 'ES_' + $ProjectName + '_EventStoreV411Hotfix1Process'
            TaskName    = 'EventStore Startup - ' + $ProjectName
            Directory   = $ProjectDirectoryName
        }
    }

    if ($CheckRunning) {
        WaitForEventStore('ES_' + $ProjectName + '_EventStoreRunning')
        {
            DependsOn   = '[WindowsProcess]'+ 'ES_' + $ProjectName + '_EventStoreV411Hotfix1Process'
            Url         = $AdminUrl
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