# $ExtIp = "127.0.0.1"
# $ExtHttpPort = "2813"
# $AdminUrl = 'http://'+  $ExtIp  +  ':' + $ExtHttpPort

# $Url=$AdminUrl

# "Test-EventStoreRunning -url $Url"
# Test-EventStoreRunning -url $Url


# $OldAdminPassword = "changeit"
# $OldOpsPassword = "changeit"
# $NewAdminPassword = "changedit"
# $NewOpsPassword = "changedit"

#$cred =  ( New-Object System.Management.Automation.PSCredential('admin', ( ConvertTo-SecureString $OldAdminPassword -AsPlainText -Force  ) ) )
#$cred.UserName

#"Test-EventStoreUserHasPassword admin $OldAdminPassword"
#Test-EventStoreUserHasPassword -url $Url -credential ( New-Object System.Management.Automation.PSCredential('admin', ( ConvertTo-SecureString $OldAdminPassword -AsPlainText -Force  ) ) ) -Verbose

#"Test-EventStoreUserHasPassword admin $NewAdminPassword"
#Test-EventStoreUserHasPassword -url $Url -credential ( New-Object System.Management.Automation.PSCredential('admin', ( ConvertTo-SecureString $NewAdminPassword -AsPlainText -Force  ) ) ) -Verbose

# Set-EventStoreUserPassword -url $Url -user ( New-Object System.Management.Automation.PSCredential('admin', ( ConvertTo-SecureString $NewAdminPassword -AsPlainText -Force  ) ) ) -credential ( New-Object System.Management.Automation.PSCredential('admin', ( ConvertTo-SecureString $OldAdminPassword -AsPlainText -Force  ) ) ) -Verbose


# Set-EventStoreUserPassword -url $Url -user ( New-Object System.Management.Automation.PSCredential('ops', ( ConvertTo-SecureString $NewOpsPassword -AsPlainText -Force  ) ) ) -credential ( New-Object System.Management.Automation.PSCredential('admin', ( ConvertTo-SecureString $NewAdminPassword -AsPlainText -Force  ) ) ) -Verbose

# "Test-EventStoreUserHasPassword ops $OldOpsPassword"
#  Test-EventStoreUserHasPassword -url $Url -credential ( New-Object System.Management.Automation.PSCredential('ops', ( ConvertTo-SecureString $OldOpsPassword -AsPlainText -Force  ) ) ) -Verbose

# "Test-EventStoreUserHasPassword ops $NewOpsPassword"
# Test-EventStoreUserHasPassword -url $Url -credential ( New-Object System.Management.Automation.PSCredential('ops', ( ConvertTo-SecureString $NewOpsPassword -AsPlainText -Force  ) ) ) -Verbose
