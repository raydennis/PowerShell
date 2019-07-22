Function Create-DFSShare {
<#
.SYNOPSIS
    Creates a DFS Share
.DESCRIPTION
   #Create Folder
   #Attach DFS
   #Create Quota
   #Create ADGroup if it doesn't already exist
   #Give ADGroup correct access to share
.NOTES
    File Name  : Create-DFSSHare.ps1
    Author     : Ray Dennis
    Requires   : PowerShell Version 3.0, Azure module 8.12
    Tested     : PowerShell Version 4
.PARAMETER VmName
    The name of the Azure virtual machine to install the
    certificate for. 
.EXAMPLE
    Install-WinRmAzureVMCert -SubscriptionName "my subscription" -ServiceName "mycloudservice" -Name "myvm1" 
#>

#Create Folder

#Attach DFS

#Create Quota

#Create ADGroup if it doesn't already exist

#Give ADGroup correct access to share

New-Item "\\uss1\T$\New Folder" -type directory