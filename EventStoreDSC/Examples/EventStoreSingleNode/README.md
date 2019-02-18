
```powershell

# run sample1, default with ssl
.\Sample1.ps1

# run sample3, default without ssl
.\Sample3.ps1

# run sample 2 with secure string for certificate and external config
$password = ConvertTo-SecureString "Password" -AsPlainText -Force
.\Sample2.ps1 -CertificatePassword $password


# run sample4, default without ssl, windows service
.\Sample4.ps1

```