#
# Script.ps1
#
# Dieses Skript geht davon aus, dass der Microsoft Virtual Machine Converter bereits am Rechner installiert ist
# Testscript
#
# 
# Import MVMC PowerShell Cmdlets
Import-Module -Name "C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1"

# Test
#
#PS D:\> Get-Command *-mvmc*
#
#CommandType     Name                                               Version    S
#                                                                             o
#                                                                              u
#                                                                             r
#                                                                              c
#                                                                              e
#-----------     ----                                               -------    -
#Alias           ConvertTo-MvmcVhd
#Cmdlet          ConvertTo-MvmcAzureVirtualHardDisk                 2.0        M
#Cmdlet          ConvertTo-MvmcP2V                                  2.0        M
#Cmdlet          ConvertTo-MvmcP2VVirtualHardDisk                   2.0        M
#Cmdlet          ConvertTo-MvmcVirtualHardDisk                      2.0        M
#Cmdlet          ConvertTo-MvmcVirtualHardDiskOvf                   2.0        M
#Cmdlet          Disable-MvmcSourceVMTools                          2.0        M
#Cmdlet          Get-MvmcHyperVHostInfo                             2.0        M
#Cmdlet          Get-MvmcP2VSourceSystemInformation                 2.0        M
#Cmdlet          Get-MvmcSourceVirtualMachine                       2.0        M
#Cmdlet          New-MvmcHyperVHostConnection                       2.0        M
#Cmdlet          New-MvmcP2VRequestParam                            2.0        M
#Cmdlet          New-MvmcP2VSourceConnection                        2.0        M
#Cmdlet          New-MvmcSourceConnection                           2.0        M
#Cmdlet          New-MvmcSourceVirtualMachineSnapshot               2.0        M
#Cmdlet          New-MvmcVirtualMachineFromOvf                      2.0        M
#Cmdlet          Restore-MvmcSourceVirtualMachineSnapshot           2.0        M
#Cmdlet          Stop-MvmcSourceVirtualMachine                      2.0        M
#Cmdlet          Uninstall-MvmcSourceVMTools                        2.0        M
#
# Sample command: convert local VM from vSphere to Hyper-V
# ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath "D:\VMware\Windows 10 x64_PlayerWS\Windows 10 x64_PlayerWS.vmdk" -DestinationLiteralPath "D:\VMware\Windows 10 x64_PlayerWS\Windows 10 x64_PlayerWS.vhdx" -VhdFormat VHDX
# Sample command: convert VM from local vSphere Host to Hyper-V and upload it to the Azure cloud:
# sample command....
# Do the local conversion - just a test to verify MVMC powershell cmdlets are usable ;
ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath "D:\Win10VBOX\Win10VBOX-disk1.vmdk" -DestinationLiteralPath "D:\Win10VBOX\Win10VBOX-disk1.vhdx" -VhdFormat VHDX