#
# Script.ps1
# Script for automatic replication of pre-defined on-premises VMs
# Script aims to connect to Azure, will enable replication for them (inside Azure), should also do a test 
# failover and finally will force the migration to Azure.

# First of all, start to import necessary Azure PowerShell modules...
Import-PSModule
