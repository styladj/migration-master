#
# Script.ps1
# Script for automatic replication of pre-defined on-premises VMs
# Script aims to connect to Azure, will enable replication for them (inside Azure), should also do a test 
# failover and finally will force the migration to Azure.


# First of all, adapt PowerShell Execution Policy
Echo "PowerShell Execution Policy will be adapted now accordingly..."
Set-ExecutionPolicy AllSigned

# Now install 'chocolatey', the software management which will install the 'ARMClient' for us
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Use chocolatey to install 'ARMClient'
choco install armclient

# Generate test log
echo "install" > test.log
