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
# 2017-06-12:
#	- added fabrics
#	- prepared prototype for replication
############################################################

# BASIC VARIABLES
# VAR for subscription
Set-Variable -Name "SUB" -Value "/subscriptions/8074cfce-94b3-4af9-b6c3-18df7b96e869";
# VAR for resourceGroup Name
Set-Variable -Name "ResGroup" -Value "mmaster";
# VAR for Azure API version; change version here if required; 
Set-Variable -Name "ResAZapi" -Value "2016-09-01";
# VAR for Azure Tenant ID
Set-Variable -Name "TenantID" -Value "e2367125-41e3-4124-bacc-5ee027d27287";
# VAR for Azure AD application ID
Set-Variable -Name "AppID" -Value "8c2e06a6-d5b6-4be1-8d60-7086d2ccc972";
# VAR for Azure AD application
Set-Variable -Name "SPKey" -Value "IyvZvyZDIuuLRucg0Q+ssjACzacwJrU6k/3OZv1dVz0=";
# VAR for Azure Site Recovery vault
Set-Variable -Name "ASRVault" -Value "MMaster-AZ-Site-Recovery";
# VAR for Azure Site Recovery fabric with friendlyName SUN; Azure requires the id;
# id for Sun is bb725fe4ee3afccf122c02184fd8d596a21ea8f232b6cf782fb16525f58a529f;
Set-Variable -Name "fabric" -Value "bb725fe4ee3afccf122c02184fd8d596a21ea8f232b6cf782fb16525f58a529f";
# VAR for Recovery Services Providers id in Azure Site Recovery;
Set-Variable -Name "ASRProviderID" -Value "6484e0e8-9d78-46e1-b1ac-278f76e0725d";
# VAR for Protection container name of Configuration Server 'SUN';
# Protection container name is in this case: cloud_6484e0e8-9d78-46e1-b1ac-278f76e0725d;
Set-Variable -Name "ASRProtectionContainerName" -Value "cloud_6484e0e8-9d78-46e1-b1ac-278f76e0725d";

# VARIABLES FOR ADVANCED PART
# VAR for ASR name of protectable on-premises VM 'Moon_UbuntuBOX'
Set-Variable -Name "ProtectableItemMoon" -Value "28cb61d5-4af6-11e7-8306-005056ae9154"

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
armclient spn $TenantID $AppID $SPKey

Echo "Hit any key to start basic tests to ensure you can access Azure..."
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

# Get resource groups in Azure  and display all available resource groups the service principal can access
Echo "Getting and displaying all resource groups the service principal can access in Azure..."
armclient GET $SUB/resourceGroups?api-version=$ResAZapi

# Get fabrics in Azure Site Recovery
Echo "Getting list of fabrics in Azure Site Recovery..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics?api-version=2015-11-10

Echo "Getting details about our fabric..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/"$fabric"?api-version=2015-11-10

# Get recovery services providers in Azure Site Recovery
Echo "Getting recovery services providers in Azure Site Recovery..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationRecoveryServicesProviders?api-version=2015-11-10

# Protection Container
# First of all, list all protection containers in our replication fabric
Echo "List all protection containers..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/?api-version=2015-11-10

##################### END OF BASIC PART ##################

##################### VM PROTECTION ####################
# Now the prototype will list all protectable items
# This is the first critical step to successfully activate the replication for a VMware vSphere VM

Echo "Now the prototype will list all protectable items..."
Echo "ATTENTION: This is the first critical step to successfully activate the replication for a VMware vSphere VM!!!"
Echo "Therefore the on-premises VMware vSphere infrastructure MUST BE accessible NOW!!"
Echo "The prototype will now tell 'SUN' to retrieve information from the on-premises VMware vSphere Infrastructure."
Echo "Proceed with ANY key when ready..."
# Ask user for key input ;
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()
# now retrieve protectable items from infrastructure ;
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtectionContainerName/replicationProtectableItems?api-version=2015-11-10"&$filter=state eq '<protected | unprotected<'"

# Get details of protectable on-premises VM 'Moon_UbuntuBOX' ;
Echo "The prototype will now get more information about the protectable on-premises VM 'Moon_UbuntuBOX'..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtectionContainerName/replicationProtectableItems/"$ProtectableItemMoon"?api-version=2015-11-10

# Now add the protectable item to the protection container in Azure Site Recovery ;
#Echo "The prototype will now add the protectable item 'Moon_UbuntuBOX' to the protection container in Azure Site Recovery..."
#armclient POST $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtectionContainerName/discoverProtectableItem?api-version=2015-11-10

