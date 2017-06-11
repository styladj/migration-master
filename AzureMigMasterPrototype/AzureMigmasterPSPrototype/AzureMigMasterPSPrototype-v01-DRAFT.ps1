################# ###########################################
################# ####################### ###################
################# MIGMASTER PROTOTYPE V1.0 ##################
#############################################################
#############################################################

# Script for automatic replication of pre-defined on-premises VMs
# Script aims to connect to Azure, will enable replication for them (inside Azure), should also do a test 
# failover and finally will force the migration to Azure.


################# CHANGELOG #################################
# v0.1 - 2017-05-30 initial release
# 2017-06-11: 
#	- adaptions to 'ARMClient'
#	- added installation of chocolatey and ARMClient
#	- added authentication to Azure by token
#	- added resource group listing

# BASIC VARIABLES
# VAR for subscription
Set-Variable -Name "SUB" -Value "/subscriptions/8074cfce-94b3-4af9-b6c3-18df7b96e869"
# VAR for resourceGroup Name
Set-Variable -Name "ResGroup" -Value "mmaster"
# VAR for Azure API version; change version here if required; 
Set-Variable -Name "ResAZapi" -Value "2016-09-01"
# VAR for Azure Tenant ID
Set-Variable -Name "TenantID" -Value "e2367125-41e3-4124-bacc-5ee027d27287"
# VAR for Azure AD application ID
Set-Variable -Name "AppID" -Value "8c2e06a6-d5b6-4be1-8d60-7086d2ccc972"
# VAR for Azure AD application
Set-Variable -Name "SPKey" -Value "IyvZvyZDIuuLRucg0Q+ssjACzacwJrU6k/3OZv1dVz0="

# Return values to user
Echo "Your tenant and application ID are: ";
Get-Variable -Name "TenantID"
Get-Variable -Name "AppID"


# Wait for User input to start application
Echo "Hit any key to start the application..."
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

# LOG START
echo "Script started on: " > logs/script.log
date >> logs/script.log

# First of all, adapt PowerShell Execution Policy
Echo "PowerShell Execution Policy will be adapted now accordingly..."
Set-ExecutionPolicy ByPass

# Now install 'chocolatey', the software management which will install the 'ARMClient' for us
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Use chocolatey to install 'ARMClient'
choco install armclient

# Authenticate with Azure; Get a token
armclient spn e2367125-41e3-4124-bacc-5ee027d27287 8c2e06a6-d5b6-4be1-8d60-7086d2ccc972 IyvZvyZDIuuLRucg0Q+ssjACzacwJrU6k/3OZv1dVz0=

Echo "Hit any key to start basic tests to ensure you can access Azure..."
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()
# Get resource groups in Azure
Echo "Getting resource groups in Azure..."
armclient GET $SUB/resourceGroups?api-version=$ResAZapi