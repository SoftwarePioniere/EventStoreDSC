@{
    ModuleVersion     = "0.0.4.2";
    GUID              = "21be7e07-c245-4f2e-b1c5-721f9bccfa5e";
    Author            = "Tobias Boeker";
    CompanyName       = "Softwarepioniere GmbH & Co. KG";
    Copyright         = "(c) 2018 Softwarepioniere GmbH & Co. KG. Alle Rechte vorbehalten.";
    Description       = "EventStoreDSC";
    PowerShellVersion = "4.0";
    CLRVersion        = "4.0";
    FunctionsToExport = "*";
    CmdletsToExport   = "*";
    DscResourcesToExport =  @('EventStoreProject');
   # RequiredModules = @('FileDownloadDSC','EventStoreUtil')
    PrivateData = @{
        PSData = @{
            ProjectUri = 'https://github.com/SoftwarePioniere/EventStoreDSC'
        }    
    }
}

