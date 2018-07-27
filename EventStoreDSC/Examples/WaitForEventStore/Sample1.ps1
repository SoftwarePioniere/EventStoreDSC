Configuration Sample1
{
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        WaitForEventStore waitFor
        {
            Url = "http://localhost:2113"
        }

    }
}


Sample1 -Verbose
Start-DscConfiguration .\Sample1 -Wait -Force -Verbose -Debug