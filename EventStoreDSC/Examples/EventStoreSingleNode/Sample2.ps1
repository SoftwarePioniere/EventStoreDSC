[Cmdletbinding()]
Param(
    [securestring] $CertificatePassword
)

Configuration Sample2
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node $AllNodes.NodeName
    {
        EventStoreNode ('esNode_' + $Node.NodeName + '_' + $Node.ProjectName)
        {
            RootDrive = $Node.RootDrive
            ExtIp = $Node.ExtIp
            UseSecure = $Node.UseSecure
            CertificatePassword = $Node.CertificatePassword
            ProjectName =    $Node.ProjectName
            IntHttpPort = $Node.IntHttpPort
            ExtHttpPort = $Node.ExtHttpPort
            IntTcpPort = $Node.IntTcpPort
            ExtTcpPort = $Node.ExtTcpPort
            ExtSecureTcpPort = $Node.ExtSecureTcpPort
      }
    }
}

$MyData =
@{
    AllNodes =
    @(
        @{
            NodeName    = 'localhost'
            ExtIp       = '127.0.0.1'
            RootDrive = 'c:'
            UseSecure = $true
            CertificatePassword = $CertificatePassword
            ProjectName = 'test2'
            IntHttpPort = '2912'
            ExtHttpPort = '2913'
            IntTcpPort  = '1912'
            ExtTcpPort  = '1913'
            IntSecureTcpPort = '3912'
            ExtSecureTcpPort = '3913'
        }
    )
}

Sample2 -Verbose -ConfigurationData $MyData
Start-DscConfiguration .\Sample2 -Wait -Force -Verbose -Debug

Start-Process 'http://localhost:2913'