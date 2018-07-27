Configuration Sample3
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreNode esnode
        {
            RootDrive = "c:"
            ExtIp = "127.0.0.1"
            ProjectName = "test3"
            IntHttpPort = "2712"
            ExtHttpPort = "2713"
            IntTcpPort = "1712"
            ExtTcpPort = "1713"
      }
    }
}


Sample3 -Verbose
Start-DscConfiguration .\Sample3 -Wait -Force -Verbose -Debug

Start-Process 'http://localhost:2713'