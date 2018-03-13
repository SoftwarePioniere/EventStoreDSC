Configuration Sample1
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreProject EventStoreTestInstance
        {
            DataDrive = "c:\"
            ExtIp = "127.0.0.1"
            ESName = "test"
            IntHttpPort = "2912"
            ExtHttpPort = "2913"
            IntTcpPort = "1912"
            ExtTcpPort = "1913"
            IntSecureTcpPort = "3912"
            ExtSecureTcpPort = "3913"
            OldAdminPassword = "changeit"
            OldOpsPassword = "changeit"
            NewAdminPassword = "changedit"
            NewOpsPassword = "changedit"
        }
    }
}


Sample1
Start-DscConfiguration .\Sample1 -Wait -Force