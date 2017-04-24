$cert = New-SelfSignedCertificate -DnsName mmaster.cloudapp.net -CertStoreLocation "cert:\LocalMachine\My"
$password = ConvertTo-SecureString -String "V67OC!Mf" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath ".\Azure-CERT-v1.pfx" -Password $password
Export-Certificate -Type CERT -Cert $cert -FilePath .\Azure-CERT-v1.cer