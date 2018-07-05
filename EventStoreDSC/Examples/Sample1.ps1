Configuration Sample1
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreProject EventStoreTestInstance
        {
            RootDrive = "c:\"
            ExtIp = "127.0.0.1"
            CertificatePassword = "Password"
            ProjectName = "test"
            IntHttpPort = "2812"
            ExtHttpPort = "2813"
            IntTcpPort = "1812"
            ExtTcpPort = "1813"
            IntSecureTcpPort = "3812"
            ExtSecureTcpPort = "3813"
            OldAdminPassword = "changeit"
            OldOpsPassword = "changeit"
            NewAdminPassword = "changedit"
            NewOpsPassword = "changedit"
      }
    }
}


Sample1 -Verbose
Start-DscConfiguration .\Sample1 -Wait -Force -Verbose -Debug