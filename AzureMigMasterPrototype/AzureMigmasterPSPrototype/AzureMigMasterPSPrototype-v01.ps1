################# ###########################################
################# ####################### ###################
################# MIGMASTER PROTOTYPE V1.0 ##################
#############################################################
#############################################################

<# 
1) BASIC INFORMATION:

	Script for automatic replication of pre-defined on-premises VMs
	Script aims to connect to Azure, will enable replication for them (inside Azure), should also do a test 
	failover and finally will force the migration to Azure.
	And as an (optional) step: It can also initiate the repair of the replication of a specific VM
	NOTE: THE PROTOTYPE WILL MODIFY YOUR INFRASTRUCTURE IN AZURE !!!
	USE IT WITH CARE !!!	

2.) RUNNING THIS SCRIPT / SCRIPT EXECUTION:

	The script installs software.
	Therefore it needs to be run with administrator permissions.
	The PowerShell execution policy has to be set to 'Unrestricted' or needs to be bypassed 
	to run this script accordingly.
		
	To set the execution policy to 'Unrestricted' open PowerShell as administrator and enter:
		Set-ExecutionPolicy Unrestricted
	To bypass execution policy start the script with:
		PowerShell.exe -ExecutionPolicy Bypass .\scriptfile.ps1

	To permanently bypass the execution policy open PowerShell as administrator and enter:
		Set-ExecutionPolicy ByPass

3.) CHANGELOG:

	2017-05-30:
		- initial draft release
	2017-06-11: 
		- adaptions to 'ARMClient'
		- added installation of chocolatey and ARMClient
		- added authentication to Azure by token
		- added resource group listing
	2017-06-12:
		- added fabrics
	2017-06-25:
		- added test failover and failover commands
		- created JSON input files for test failover and final failover
	2017-06-28:
		- added code for VM replication
		- created JSON input file for VM to enable replication
		- added code to initiate repair VM replication state in ASR
		- code cleanup

4.) SOURCES:

	ARMClient:
		- http://blog.davidebbo.com/2015/01/azure-resource-manager-client.html
	Chocolatey:
		- https://chocolatey.org/
	Azure:
		- https://azure.microsoft.com/
	Azure Site Recovery:
		- https://docs.microsoft.com/en-us/azure/site-recovery/
	Azure Site Recovery REST API Documentation:
		- https://msdn.microsoft.com/en-us/library/mt750497.aspx

#>

Echo "Setting variables now..." 
# BASIC VARIABLES ;
# VAR for subscription ;
Set-Variable -Name "SUB" -Value "/subscriptions/8074cfce-94b3-4af9-b6c3-18df7b96e869";
# VAR for resourceGroup Name ;
Set-Variable -Name "ResGroup" -Value "mmaster";
# VAR for Azure API version ;
# change version here if required ;
Set-Variable -Name "ResAZapi" -Value "2016-09-01";
# VAR for Azure Tenant ID ;
Set-Variable -Name "TenantID" -Value "e2367125-41e3-4124-bacc-5ee027d27287";
# VAR for Azure AD application ID ;
Set-Variable -Name "AppID" -Value "8c2e06a6-d5b6-4be1-8d60-7086d2ccc972";
# VAR for Azure AD application key ;
Set-Variable -Name "SPKey" -Value "IyvZvyZDIuuLRucg0Q+ssjACzacwJrU6k/3OZv1dVz0=";
# VAR for Azure Site Recovery vault ;
Set-Variable -Name "ASRVault" -Value "MMaster-AZ-Site-Recovery";
# VAR for Azure Site Recovery fabric with friendlyName SUN; Azure requires the id ;
# id for Sun is bb725fe4ee3afccf122c02184fd8d596a21ea8f232b6cf782fb16525f58a529f ;
Set-Variable -Name "fabric" -Value "bb725fe4ee3afccf122c02184fd8d596a21ea8f232b6cf782fb16525f58a529f";
# VAR for Recovery Services Providers id in Azure Site Recovery ;
Set-Variable -Name "ASRProviderID" -Value "6484e0e8-9d78-46e1-b1ac-278f76e0725d";
# VAR for Protection container name of Configuration Server 'SUN' ;
# Protection container name is in this case: cloud_6484e0e8-9d78-46e1-b1ac-278f76e0725d ;
Set-Variable -Name "ASRProtectionContainerName" -Value "cloud_6484e0e8-9d78-46e1-b1ac-278f76e0725d";
# VARIABLES FOR ADVANCED PART ;
# VAR for ASR name of protectable on-premises VM 'Moon_UbuntuBOX' ;
Set-Variable -Name "ProtectableItemMoon" -Value "28cb61d5-4af6-11e7-8306-005056ae9154"
# VAR for ASR name of protected on-premises VM 'Moon_UbuntuBOX' ;
Set-Variable -Name "ProtectedItemMoon" -Value "28cb61d5-4af6-11e7-8306-005056ae9154"
# VAR for Replication policy name in ASR ;
Set-Variable -Name "ReplicationPolicy" -Value "d8e4aaf5-3fee-4291-8928-4aff1dc783cf"
# VAR for Failback Replication policy name in ASR ;
Set-Variable -Name "FailbackReplicationPolicy" -Value "10c93c82-a5ac-4a03-bc7f-2ad1943af72a"

# Return values to user ;
Echo "Your tenant and application ID are: ";
Get-Variable -Name "TenantID"
Get-Variable -Name "AppID"

# Wait for User input to start application ;
Echo "ATTENTION: THE PROTOTYPE WILL MODIFY YOUR INFRASTRUCTURE IN AZURE !!!"
Echo "USE IT WITH CARE !!!"
Echo "The script installs software."
Echo "Therefore it needs to be run with administrator permissions."
Echo "Hit any key to start the application..."
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

# LOG START ;
echo "Script started on: " > logs/script.log
date >> logs/script.log

# Now install 'chocolatey', the software management which will install the 'ARMClient' for us ;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Use chocolatey to install 'ARMClient' ;
choco install armclient

# Authenticate with Azure; Get a token ;
Echo "Requesting authentication token now by using Service Principal account..."
armclient spn $TenantID $AppID $SPKey

Echo "Hit any key to start basic tests to ensure you can access Azure..."
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

# Get resource groups in Azure  and display all available resource groups the service principal can access ;
Echo "Getting and displaying all resource groups the service principal can access in Azure..."
armclient GET $SUB/resourceGroups?api-version=$ResAZapi

# Get fabrics in Azure Site Recovery ;
Echo "Getting list of fabrics in Azure Site Recovery..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics?api-version=2015-11-10

Echo "Getting details about our fabric..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/"$fabric"?api-version=2015-11-10

# Get recovery services providers in Azure Site Recovery ;
Echo "Getting recovery services providers in Azure Site Recovery..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationRecoveryServicesProviders?api-version=2015-11-10

# Protection Container ;
# First of all, list all protection containers in our replication fabric ;
Echo "List all protection containers..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/?api-version=2015-11-10

##################### END OF BASIC PART ##################

##################### VM PROTECTION ####################
# Now the prototype will list all protectable items ;
# This is the first critical step to successfully activate the replication for a VMware vSphere VM ;

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

# List protection container mappings for a protection container in ASR ;
Echo "Listing protection container mappings for the protection container in ASR..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtectionContainerName/replicationProtectionContainerMappings?api-version=2015-11-10

# Get a list of replication protected items in Azure ;
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtectionContainerName/replicationProtectedItems?api-version=2015-11-10

# Get details of protected on-premises VM 'Moon_UbuntuBOX' ;
Echo "The prototype will now get more information about the protected on-premises VM 'Moon_UbuntuBOX'..."
armclient GET $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtectionContainerName/replicationProtectedItems/"$ProtectedItemMoon"?api-version=2015-11-10

# Enable replication ;
Echo "ATTENTION: The prototype will now try to enable the replication for the Client-VM!"
Echo "Prototype will sleep for 10 hrs!"
Echo "Proceed with ANY key when ready..."
# Ask user for key input ;
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

# REST PUT to pass on the JSON file to enable the replication ;
armclient PUT $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtection/ContainerName/replicationProtectedItems/$ProtectedItemMoon/testFailover?api-version=2015-11-10 "@.\json\ReplicationMoon.json"

# Sleep and wait until replication is done ; 
Echo "Entering sleep mode for 10 hrs!"
Start-Sleep -Seconds 36000

Echo "The prototype is now ready to execute the test failover!"
Echo "Proceed with ANY key when ready..."
# Ask user for key input ;
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

# Prepare for failover ... ;
# Starting with testFailover ... ;
armclient POST $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtection/ContainerName/replicationProtectedItems/$ProtectedItemMoon/testFailover?api-version=2015-11-10 "@.\json\TestFailoverMoon.json"
Echo "Check the Azure Portal now and complete the test failover."
Echo "Delete test instance immediately..."
# Sleep now for 10 Minutes to complete the test failover steps ;
Echo "Waiting for 10 Minutes now to complete the test failover steps..."
Start-Sleep -Seconds 600
Echo "Proceed with ANY key when ready..."
# Ask user for key input ;
$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

# Final failover >
Echo "The prototype will now execute the failover together with Azure Site Recovery."
Echo "After the failover has been completed successfully you will be able to see the VM in 'Virtual Machines' on Azure."
armclient POST $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtection/ContainerName/replicationProtectedItems/$ProtectedItemMoon/unPlannedFailover?api-version=2015-11-10 "@.\json\FinalFailoverMoon.json"

<# Repair VM replication state in Azure Site Recovery ; 
# Uncomment these lines only if you want to do this ;
# EXAMPLE command from ASR REST API Documentation:
# https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.RecoveryServices/vaults/{resourceName}/replicationFabrics/{fabricName}/replicationProtectionContainers/{containerName}/replicationProtectedItems/{protectedItemName}/resyncVM?api-version=<api-version> #>
 
# Optional: initiate repair of the VM replication state
# Echo "The prototype will now initiate the repair of the VM replication state!"
# armclient POST $SUB/resourceGroups/$ResGroup/providers/Microsoft.RecoveryServices/vaults/$ASRVault/replicationFabrics/$fabric/replicationProtectionContainers/$ASRProtection/ContainerName/replicationProtectedItems/$ProtectedItemMoon/resyncVM?api-version=2015-11-10

# LOG END ;
echo "Script ended on: " > logs/script.log
date >> logs/script.log