Configuration Sample1
{
    Import-DSCResource -ModuleName EventStoreDSC

    Node localhost
    {
        EventStoreStartupTask task
        {
            Directory = "c:\windows"
            TaskName = "test-startup-task"
        }
    }
}


Sample1 -Verbose
Start-DscConfiguration .\Sample1 -Wait -Force -Verbose -Debug