Add-PSSnapin Quest.ActiveRoles.ADManagement
#Get-QADComputer        Retrieve computer objects that match specified conditions.
#Connect-QADService     Connect to AD domain controller (or AD LDS) 
    #Disconnect-QADService  Disconnect from an AD domain controller
#Get-QADGroup          Retrieve groups that match specific conditions
    #Set-QADGroup          Modify attributes of group(s)
    #New-QADGroup          Create a new workgroup
#Get-QADGroupMember    Retrieve members of a group
    #Add-QADGroupMember    Add one or more objects to a group
    #Remove-QADGroupMember Remove one or more members from a group
    #Get-QADMemberOf       Retrieve group memberships of a particular object
#Get-QADUser           Retrieve users that match specific conditions
    #Set-QADUser           Modify attributes of a user account
    #New-QADUser           Create a new user account
    #Enable-QADUser        Enable a user account
#Move-QADObject        Move an object to a new OU
    #Remove-QADObject      Delete object(s) from Active Directory
    #Rename-QADObject      Rename an object in Active Directory
#Disable-QADUser       Disable a user account
    #Unlock-QADUser        Unlock a user account
    #Deprovision-QADUser   Deprovision a user account in AD


#Quest Examples
Get-QADUser rdennis | Format-Table name, displayname -AutoSize -Wrap
Get-QADGroup "Domain" | Format-Table name, displayname -AutoSize -Wrap
Get-QADGroupMember "Domain Admins" | Format-Table name, displayname -AutoSize -Wrap
Get-QADMemberOf "Brenton, Joe" | Select Name | Where { $_.name -like "*VPN*"}

Add-QADGroupMember Uss-Chemdat-modify (Get-QADGroupMember Uss-Chemdat-read) 

$textfile = 'C:\temp\Bobcat_Users.csv'
$outputFile = 'C:\temp\Bobcat_Users_users_with_email.csv'
Get-Content -Path $textfile |
ForEach-Object {
$user = $_
Get-QADUser $user | select name, displayname, title, email, ParentContainer | export-csv -Path $outputFile -Append
}

$sender = "r.dennis"
Get-MessageTrackingLog -Server callisto1 -Sender (Get-QADUser $sender |  foreach { $_.PrimarySMTPAddress}) -Start (Get-Date).AddHours(-24) | Format-Table RecipientCount, MessageSubject, TimeStamp -Wrap -AutoSize

# Assumes a CanonicalName of server accounts like example.org/servers/<location>/<servername>
# This groups the results of Get-ADComputer on the <location> element of the CName
Get-QADComputer -SearchBase "OU=CTLB - Local Account,OU=Lecterns,OU=Workstations,OU=CT,DC=colleges,DC=ad,DC=unm,DC=edu" -Filter {Enabled -eq $true} -Properties CanonicalName | Group-Object {($_.CanonicalName -Split "/")[2]}


Import-Csv C:\scripts\oak_users_021915.csv | ForEach-Object{Get-QADUser -Identity $_.name | Select name, displayname, title, department} | export-csv C:\Scripts\Oak_Users_With_Title.csv

Get-QADMemberOf "Brenton, Joe" | Select Name | Where { $_.name -like "*VPN*"}

#The following example demonstrates how to retrieve the total number of objects that are stored in the Active Directory database of the Fabrikam.com domain:
Get-ADObject -Filter {name -like '*'} -SearchBase 'CN=Schema,CN=Configuration,DC=Fabrikam,DC=COM' -ResultSetSize $null | Measure-Object
PS C:\Users\Ray> Get-ADObject -Filter {name -like '*'} -SearchBase 'DC=unfcsd,DC=unf,DC=edu' -ResultSetSize $null | Measure-Object
Count    : 131263 


#used to get public folder statistics from exchange admin server (shell)
[PS] C:\Windows\system32>Get-PublicFolderStatistics -Server Saturn | Select AdminDisplayName, CreationTime, FolderPath, LastModificationTime | Export-CSV C:\Temp\PublicFolderStats.csv


#Copy all files in the folder, combine them to a new file.
Get-ChildItem -filter *.* | % {Get-Content $_ -ReadCount 0 | Add-Content .\logs.csv}

#setup firewall rules on new machine
import-module netsecurity
New-NetFirewallRule -Name Allow_Ping -DisplayName "Allow Ping"`
  -Description "Packet Internet Groper ICMPv4" `
  -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow `
   

#setup vmware PowerCLI
  # Adds the base cmdlets
Add-PSSnapin VMware.VimAutomation.Core
# Add the following if you want to do things with Update Manager
Add-PSSnapin VMware.VumAutomation
# This script adds some helper functions and sets the appearance. You can pick and choose parts of this file for a fully custom appearance.
"C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"


#remote Hyper-V management
#on client machine, run:
cmdkey /add:<ServerName> /user:<UserName> /pass:<password>

#start Console Manager as different user
runas /netonly /user:$DOMAIN\$USER "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.exe"


#delete files with extenion 
 get-childitem "C:\Temp" -include *.json -recurse | foreach ($_) {remove-item $_.fullname}

 #move files with extenion 
 get-childitem "C:\Temp" -include *.avi -recurse | foreach ($_) {move-item $_.fullname "C:\Temp"}


#Select property from object
$hostname = [System.Net.Dns]::GetHostbyAddress($IP) | Select-Object -ExpandProperty HostName 
Get-ADComputer -Filter "Name -like 'CT-*'" -SearchBase "OU=CT,DC=colleges,DC=ad,DC=unm,DC=EDU" | Select-Object Name


#Environmental variables
$console = $host.ui.RawUI
$console.Foregroundcolor = "darkyellow"
$console.WindowTitle = "CLOUD 365"
function Prompt {return "PS> "}

#Sign in variable.
$LiveCred  = Get-Credential raditsvc@unmm.onmicrosoft.com     
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $LiveCred -Authentication Basic -AllowRedirection 
Import-PSSession $Session

#Load MSOnline (Azure AD) commandlets. Requires download and installof MSOnline module. 
Import-Module MSOnline
Connect-MSOLService -Credential $LiveCred

#Get list of installed applications - Select name, version format table
Get-WmiObject -Class Win32_Product | select name, version | FT


#Invoke script command on remote machine
Invoke-Command -ComputerName IT-VM3W7MBG2 -FilePath C:\Users\raditsvc\OneDrive\PowerShell\SCCM\Build\SCCM-Build\DisableUnifiedWriteFiltering.ps1

Get-ADuser mgonza36 -Properties gecos,description | FT @{n='Name';e={$_.gecos}},@{n='Department';e={$_.description}}

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "WES:" # Set the current location to be the site code.
