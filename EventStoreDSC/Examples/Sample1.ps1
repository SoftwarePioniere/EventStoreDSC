Configuration Sample1
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreProject EventStoreTestInstance
        {
            RootDrive = "c:"
            ExtIp = "127.0.0.1"
<<<<<<< HEAD
            CertificatePassword = "Password"
            ProjectName = "test"
            IntHttpPort = "2812"
            ExtHttpPort = "2813"
            IntTcpPort = "1812"
            ExtTcpPort = "1813"
            IntSecureTcpPort = "3812"
            ExtSecureTcpPort = "3813"
=======
            #CertificatePassword = "xxx"
            CertificatePassword = "Password"
            ProjectName = "test"
            # IntHttpPort = "2912"
            # ExtHttpPort = "2913"
            # IntTcpPort = "1912"
            # ExtTcpPort = "1913"
            # IntSecureTcpPort = "3912"
            # ExtSecureTcpPort = "3913"
>>>>>>> e9421b2e35ca352cf8f3fc5a2177e059e3ad8ab5
            OldAdminPassword = "changeit"
            OldOpsPassword = "changeit"
            NewAdminPassword = "changedit"
            NewOpsPassword = "changedit"
      }
    }
}


Sample1 -Verbose
Start-DscConfiguration .\Sample1 -Wait -Force -Verbose -Debug