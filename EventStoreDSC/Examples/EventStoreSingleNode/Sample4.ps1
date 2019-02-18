Configuration Sample4
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreNode esnode
        {
            RootDrive = "c:"
            ExtIp = "127.0.0.1"
            ProjectName = "test4"
            IntHttpPort = "2812"
            ExtHttpPort = "2813"
            IntTcpPort = "1812"
            ExtTcpPort = "1813"
            UseWindowsService = $true
      }
    }
}


Sample4 -Verbose
Start-DscConfiguration .\Sample4 -Wait -Force -Verbose -Debug

Start-Process 'http://localhost:2813'