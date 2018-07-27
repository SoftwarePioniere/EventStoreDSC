
```powershell

# cluster on a single machine
.\Sample1.ps1

# run sample 2 with secure string for certificate and external config
$password = ConvertTo-SecureString "Password" -AsPlainText -Force
.\Sample2.ps1 -CertificatePassword $password

```