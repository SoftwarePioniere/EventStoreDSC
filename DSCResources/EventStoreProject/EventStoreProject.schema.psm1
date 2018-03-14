configuration EventStoreProject
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [string]    $RootDrive = 'f:',
        [string]    $RootDirectory = 'eventstore',      
        [string]    $BaseDirectoryName = $RootDrive + $RootDirectory,                         

        [string]    $CertificateFile = 'softwarepioniere_dev.pfx',
        [string]    $CertificateDownloadUrl = 'https://softwarepioniere.blob.core.windows.net/devcert/' + $CertificateFile,
        [string]    $CertificatePassword = 'changeit',
        [string]    $CertificateFileName = $BaseDirectoryName + '\' + $CertificateFile,

        [string]    $ZipName401= 'EventStore-OSS-Win-v4.0.1',
        [string]    $ArchiveFile401 = $BaseDirectoryName + '\' + $ZipName401 + '.zip',
        
        [string]    $ZipName401Hotfix4= 'EventStore-OSS-Win-v4.0.1-hotfix4',
        [string]    $ArchiveFile401Hotfix4 = $BaseDirectoryName + '\' + $ZipName401Hotfix4 + '.zip',

        [string]    $ZipName403= 'EventStore-OSS-Win-v4.0.3',
        [string]    $ArchiveFile403 = $BaseDirectoryName + '\' + $ZipName403 + '.zip',

        [string]    $ZipName410= 'EventStore-OSS-Win-v4.1.0',
        [string]    $ArchiveFile410 = $BaseDirectoryName + '\' + $ZipName410 + '.zip' ,
        
        [string]    $ProjectName = 'es1',
        [string]    $ProjectDirectoryName = $BaseDirectoryName + '\' + $ProjectName,

        [string]    $ExtIp = '10.0.0.4',
        [string]    $IntHttpPort = '2212',
        [string]    $ExtHttpPort = '2213',
        [string]    $IntTcpPort = '1212',
        [string]    $ExtTcpPort = '1213',
        [string]    $IntSecureTcpPort = '3212',
        [string]    $ExtSecureTcpPort = '3213',
 
        [string]    $OldAdminPassword = 'changeit',
        [string]    $OldOpsPassword = 'changeit',
        [string]    $NewAdminPassword = 'changedit',
        [string]    $NewOpsPassword = 'changedit',
      
        [string]    $AppDirectory401 = $ProjectDirectoryName + '\' + $ZipName401 ,
        [string]    $AppExe401 = $AppDirectory401 + '\EventStore.ClusterNode.exe',
      
        [string]    $AppDirectory401Hotfix4 = $ProjectDirectoryName + '\' + $ZipName401Hotfix4,
        [string]    $AppExe401Hotfix4 = $AppDirectory401Hotfix4 + '\EventStore.ClusterNode.exe',
      
        [string]    $AppDirectory403 = $ProjectDirectoryName + '\' + $ZipName403,
        [string]    $AppExe403 = $AppDirectory403 + '\EventStore.ClusterNode.exe',
     
        [string]    $AppDirectory410 = $ProjectDirectoryName + '\' + $ZipName410,
        [string]    $AppExe410 = $AppDirectory410 + '\EventStore.ClusterNode.exe',
            
        [string]    $ConfigFile =  $ProjectDirectoryName + '\config.yaml',
        [string]    $StarterFile = $ProjectDirectoryName + '\start.cmd',
        [string]    $AdminUrl = 'http://'+  $ExtIp  +  ':' + $ExtHttpPort
    
    )

    Import-DscResource -ModuleName @{ModuleName='xNetworking';ModuleVersion='5.0.0.0'}
    Import-DSCResource -ModuleName @{ModuleName='FileDownloadDSC';ModuleVersion='1.0.5'}
    Import-DSCResource -ModuleName EventStoreDSC
    
    File BaseDirectory
    {
        Ensure          = 'Present'
        Type            = 'Directory'
        DestinationPath = $BaseDirectoryName
    }  
    
    FileDownload DownloadCertificate
    {
        DependsOn = '[File]BaseDirectory'
        FileName = $CertificateFileName
        Url = $CertificateDownloadUrl
    }

    FileDownload DownloadEventStoreV401
    {
            DependsOn = '[FileDownload]DownloadCertificate'
            FileName = $ArchiveFile401
            Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.1.zip'
    }

    FileDownload DownloadEventStoreV401Hotfix4
    {
            DependsOn = '[FileDownload]DownloadCertificate'
            FileName = $ArchiveFile401Hotfix4
            Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.1-hotfix4.zip'
    }

    FileDownload DownloadEventStoreV403
    {
            DependsOn = '[FileDownload]DownloadCertificate'
            FileName = $ArchiveFile403
            Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.0.3.zip'
    }

    FileDownload DownloadEventStoreV410
    {
            DependsOn = '[FileDownload]DownloadCertificate'
            FileName = $ArchiveFile410
            Url = 'https://eventstore.org/downloads/EventStore-OSS-Win-v4.1.0.zip'
    }


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
        LocalPort             = ( $IntTcpPort , $IntHttpPort , $IntSecureTcpPort )
        Protocol              = 'TCP'
    }

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

    # =========================== EventStore Files ======================================================


    File ( 'ES_' + $ProjectName + '_Directory')
    {
        DependsOn       = '[File]BaseDirectory'
        Ensure          = 'Present'
        Type            = 'Directory'
        DestinationPath = $ProjectDirectoryName
    }

    Archive ( 'ES_' + $ProjectName + '_EventStoreV401')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV401'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile401
        Destination = $AppDirectory401
    }

    Archive ( 'ES_' + $ProjectName + '_EventStoreV401Hotfix4')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV401Hotfix4'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile401Hotfix4
        Destination = $AppDirectory401Hotfix4
    }

    Archive ( 'ES_' + $ProjectName + '_EventStoreV403')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV403'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile403
        Destination = $AppDirectory403
    }

    Archive ( 'ES_' + $ProjectName + '_EventStoreV410')
    {
        DependsOn   = ('[File]ES_' + $ProjectName + '_Directory'), '[FileDownload]DownloadEventStoreV410'
        Ensure      = 'Present'  # You can also set Ensure to 'Absent'
        Path        = $ArchiveFile410
        Destination = $AppDirectory410
    }

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
IntHttpPort: ' + $IntHttpPort + '
ExtHttpPort: ' + $ExtHttpPort + '
IntTcpPort: ' + $IntTcpPort + '
ExtTcpPort: ' + $ExtTcpPort  + '
IntSecureTcpPort: ' + $IntSecureTcpPort + '
ExtSecureTcpPort: ' + $ExtSecureTcpPort + '
CertificateFile: ' + $CertificateFileName + '
CertificatePassword: ' + $CertificatePassword
    }

    File ( 'ES_'+ $ProjectName + '_StartFile')
    {
        DependsOn       = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure          = 'Present'
        DestinationPath = $StarterFile
        Type            = 'File'
        Contents        =
'

START ' + $AppExe410 + ' --config=' + $ConfigFile
    }



    WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV401Process')
    {
        Arguments   = '--config=' + $ConfigFile
        Path        = $AppExe401
        DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure      = 'Absent'
    }

    WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV401Hotfix4Process')
    {
        Arguments   = '--config=' + $ConfigFile
        Path        = $AppExe401Hotfix4
        DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure      = 'Absent'
    }

    WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV403Process')
    {
        Arguments   = '--config=' + $ConfigFile
        Path        = $AppExe403
        DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure      = 'Absent'
    }

    WindowsProcess ( 'ES_' + $ProjectName + '_EventStoreV410Process')
    {
        Arguments   = '--config=' + $ConfigFile
        Path        = $AppExe410
        DependsOn   = '[File]ES_'+ $ProjectName + '_ConfigFile'
        Ensure      = 'Present'
    }

    EventStoreStartupTask('ES_' + $ProjectName + '_EventStoreStartupTask') 
    {
        DependsOn   = '[WindowsProcess]'+ 'ES_' + $ProjectName + '_EventStoreV410Process'
        TaskName    = 'EventStore Startup' + $ProjectName
        Directory   = $ProjectDirectoryName
    }

    EventStoreRunning('ES_' + $ProjectName + '_EventStoreRunning') 
    {
        DependsOn   = '[WindowsProcess]'+ 'ES_' + $ProjectName + '_EventStoreV410Process'
        Url         = $AdminUrl
    }
   
    EventStoreLogin('ES_' + $ProjectName + '_Login_Admin') 
    {
        DependsOn       = '[EventStoreRunning]' + 'ES_' + $ProjectName + '_EventStoreRunning'
        Url             = $AdminUrl
        User            = 'admin'
        Password        = $OldAdminPassword
        NewPassword     = $NewAdminPassword
        AdminUser       = 'admin'
        AdminPassword   = $OldAdminPassword        
    }

    EventStoreLogin('ES_' + $ProjectName + '_Login_Ops') 
    {
        DependsOn       = '[EventStoreLogin]' + 'ES_' + $ProjectName + '_Login_Admin'
        Url             = $AdminUrl
        User            = 'ops'
        Password        = $OldOpsPassword
        NewPassword     = $NewOpsPassword
        AdminUser       = 'admin'
        AdminPassword   = $NewAdminPassword        
    }     
        
}