@{
    ModuleVersion     = "9.9.9";
    GUID              = "21be7e07-c245-4f2e-b1c5-721f9bccfa5e";
    Author            = "Tobias Boeker";
    CompanyName       = "Softwarepioniere GmbH & Co. KG";
    Copyright         = "(c) 2018 Softwarepioniere GmbH & Co. KG. Alle Rechte vorbehalten.";
    Description       = "EventStoreDSC";
    PowerShellVersion = "4.0";
    CLRVersion        = "4.0";
    FunctionsToExport = '*'
    CmdletsToExport   = '*'
    DscResourcesToExport   = '*'
    # DscResourcesToExport =  @('EventStoreProject');
    RequiredModules = @(
    @{ModuleName = 'xNetworking'; ModuleVersion = '5.7.0.0'; },
    @{ModuleName = 'FileDownloadDSC'; RequiredVersion = '1.0.10'; })

    PrivateData = @{
        PSData = @{
            ProjectUri = 'https://github.com/SoftwarePioniere/EventStoreDSC'
        }
    }
}

