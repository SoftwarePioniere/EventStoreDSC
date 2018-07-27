$password = ConvertTo-SecureString "Password" -AsPlainText -Force

Configuration Sample1
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreNode esnode
        {
            RootDrive = "c:"
            ExtIp = "127.0.0.1"
            UseSecure = $true
            CertificatePassword = $password
            ProjectName = "test1"
            IntHttpPort = "2812"
            ExtHttpPort = "2813"
            IntTcpPort = "1812"
            ExtTcpPort = "1813"
            ExtSecureTcpPort = "3813"

      }
    }
}


Sample1 -Verbose
Start-DscConfiguration .\Sample1 -Wait -Force -Verbose -Debug

Start-Process 'http://localhost:2813'