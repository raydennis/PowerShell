<#	
	===========================================================================
	 Created on:   	9/20/2017 1:47 PM
	 Created by:   	Ray Dennis
	 Filename:     	WhatsWrongWithYourEmail.ps1
	 Purpose:		This script will attempt to determine the cause of email problems
	-------------------------------------------------------------------------
	===========================================================================
#>

#region connections

#Connect to Exchange
if(!(Get-PSSession))
{
    Write-Host Enter your credentials Ex: serviceaccount@unmm.onmicrosoft.com 
    $LiveCred  = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $LiveCred -Authentication Basic -AllowRedirection 
    Import-PSSession $Session
}

#Load MSOnline (Azure AD) commandlets. Requires download and installof MSOnline module. 
if(Get-Module -List MSOnline) #if it is installed
{
    if(!(Get-Module MSonline)) #if it is not loaded
    {
        Import-Module MSonline
        Connect-MSOLService -Credential $LiveCred
    }
}
else
{
    Write-Host "Could not load MSOnline.  Please install from https://docs.microsoft.com/en-us/powershell/module/msonline/?view=azureadps-1.0" -ForegroundColor Red
    break
}

#Load AD
if(Get-Module -List ActiveDirectory) #if it is installed
{
    if(!(Get-Module ActiveDirectory)) #if it is not loaded
    {
    
        Import-Module ActiveDirectory
    }
}
else
{
    Write-Host "Could not load ActiveDirectory.  Please install RSAT (available in Software Center)" -ForegroundColor Red
}
#endregion


$mailbox = Read-Host -Prompt 'What mailbox?'
if(!($mailbox.Contains("@")))
{
    $mailbox = $mailbox+"@unm.edu"
}

#region AD variables
$adUser = $mailbox.replace("@unm.edu", "")
$adUser = $adUser.replace("@salud.unm.edu", "")
try
{
    $adUser = Get-ADUser $adUser -Properties LockedOut, AccountLockoutTime, BadLogonCount, LastBadPasswordAttempt, LastLogonDate, PasswordExpired, PasswordLastSet -ErrorAction Stop
}
catch
{
    Write-Host "User $aduser could not be found.  Please check the spelling and try again." -ForegroundColor Red
    break
}
#endregion

#region Exchange variables
$mailStatistics = Get-MailboxStatistics $mailbox -ErrorAction SilentlyContinue | Select LastLogonTime, LastLogoffTime, IsQuarantined, totalitemsize
$lastMessageRecieved = Get-MessageTrace -RecipientAddress $mailbox -PageSize 1 -ErrorAction SilentlyContinue | Select -ExpandProperty MessageID
$lastMessageRecievedTrace = Get-MessageTrace -MessageID $lastMessageRecieved -ErrorAction SilentlyContinue
$lastMessageSent = Get-MessageTrace -SenderAddress $mailbox -PageSize 1 | Select -ExpandProperty MessageID -ErrorAction SilentlyContinue
$lastMessageSentTrace = Get-MessageTrace -MessageID $lastMessageSent -ErrorAction SilentlyContinue
$mailboxConfiguration = Get-Mailbox $mailbox -ErrorAction SilentlyContinue | Select ID, IsMailBoxEnabled, ProhibitSendQuota, DeliverToMailboxAndForward, ForwardingAddress, ForwardingSmtpAddress
$inboxRules = Get-InboxRule -Mailbox $mailbox -ErrorAction SilentlyContinue | Select Enabled, Description | FL
$gotMobile = Get-MobileDeviceStatistics -mailbox $mailbox -ErrorAction SilentlyContinue | Select DeviceFriendlyName, LastSyncAttemptTime, LastSuccessSync, ClientType
$mountTimeZone = New-TimeSpan -Hours "-6"
#endregion

#region MSOL
    $islicensed = Get-MsolUser -UserPrincipalName $mailbox -ErrorAction SilentlyContinue | select -ExpandProperty isLicensed
#endregion

#region Report header
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "Discovery of mailbox " -ForegroundColor Green -NoNewline
Write-Host "$mailbox" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Green
#endregion

#region begin Active Directory Credentials discovery
Write-Host "Locked out of AD           " -NoNewline
if($adUser.LockedOut)
{
    Write-Host "TRUE Account lockout time" $adUser.AccountLockoutTime -ForegroundColor Red
}
else
{
    Write-Host "FALSE" -ForegroundColor Green
}
Write-Host "AD password expired        " -NoNewline
if($adUser.PasswordExpired)
{
    Write-Host "TRUE  Password was last set on " $adUser.PasswordLastSet -ForegroundColor Red
}
else
{
    Write-Host "FALSE" -ForegroundColor Green
}
#endregion


#region begin Exchange Mailbox discovery
Write-Host "Mailbox quarantined        " -NoNewline
if($mailStatistics.IsQuarantined)
{
    Write-Host "TRUE" -ForegroundColor Red
}
else
{
    Write-Host "FALSE" -ForegroundColor Green
}

Write-Host "Mailbox enabled            " -NoNewline
if(!$mailboxConfiguration.IsMailboxEnabled)
{
    Write-Host "FALSE" -ForegroundColor Red
}
else
{
    Write-Host "TRUE" -ForegroundColor Green

    #region mailsize
    #there has to be a better way...
    Write-Host "Mailbox quota reached      " -NoNewline
    if($mailStatistics.TotalItemSize.Value.toString().Split()[1] -eq "GB")
    {
        $mailsize = [double]$mailStatistics.TotalItemSize.Value.toString().Split()[0]
    }
    elseif($mailStatistics.TotalItemSize.Value.toString().Split()[1] -eq "MB")
    {
        $mailsize = [double]$mailStatistics.TotalItemSize.Value.toString().Split()[0] / 1000
    }
    elseif($mailStatistics.TotalItemSize.Value.toString().Split()[1] -eq "KB")
    {
        $mailsize = [double]$mailStatistics.TotalItemSize.Value.toString().Split()[0] / 10000
    }
    if(([double]$mailboxConfiguration.ProhibitSendQuota.ToString().Split()[0]) -le $mailSize) 
    {
        Write-Host "TRUE" -ForegroundColor Red
    }
    else
    {
         Write-Host "FALSE" -ForegroundColor Green
    }
    #endregion
}
Write-Host "Mailbox forwarding enabled " -NoNewline
if($mailboxConfiguration.DeliverToMailboxAndForward)
{
    Write-Host "TRUE" -ForegroundColor Red -NoNewLine
    if($mailboxConfiguration.ForwardingAddress -ne "")
    {
        Write-Host " It is being FORWARDED to "$mailboxConfiguration.ForwardingAddress
    }
    elseif($mailboxConfiguration.ForwardingSmtpAddress -ne "")
    {
        Write-Host " It is being REDIRECTED to "$mailboxConfiguration.ForwardingSmtpAddress
    }

}
else
{
     Write-Host "FALSE" -ForegroundColor Green
}
Write-Host "User licensed for O365     " -NoNewline
if(!$islicensed)
{
    Write-Host "FALSE" -ForegroundColor Red
}
else
{
    Write-Host "TRUE" -ForegroundColor Green
}
if($inboxRules -ne $null)
{
    Write-Host 
    Write-Host "=============================Inbox Rules==============================" -ForegroundColor Magenta
    Write-Host "User has the following inbox rules created:" -ForegroundColor Magenta
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host ($inboxRules | FT | Out-String) -ForegroundColor Magenta
}
else
{
    Write-Host "Inbox rules created        " -NoNewline
    Write-Host "FALSE" -ForegroundColor Green
}

if($lastMessageSentTrace -ne $null)
{
    if($lastMessageSentTrace.Count -gt 0)
    {
        for ($i = 0; $i -lt $lastMessageSentTrace.Count; $i++)
        { 
            #convert every message to mountainTimeZone
            $lastMessageSentTrace[$i].Received = $lastMessageSentTrace[$i].Received + $mountTimeZone
        }
    }
    else
    {
        #convert single message to mountainTimeZone
        $lastMessageSentTrace.Received = $lastMessageSentTrace.Received + $mountTimeZone
    }


    Write-Host 
    Write-Host "=================================Sent=================================" -ForegroundColor Cyan
    Write-Host "The trace for the last email $mailbox sent is as follows:" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ($lastMessageSentTrace | FT | Out-String) -ForegroundColor Cyan
}
else
{
     Write-Host "The user has no recently sent email" -ForegroundColor Green
}

if($lastMessageRecievedTrace -ne $null)
{
    if($lastMessageRecievedTrace.Count -gt 0)
    {
         for ($i = 0; $i -lt $lastMessageRecievedTrace.Count; $i++)
         { 
            #convert every message to mountainTimeZone
            $lastMessageRecievedTrace[$i].Received = $lastMessageRecievedTrace[$i].Received + $mountTimeZone
         } 
    }
    else
    {
         #convert single message to mountainTimeZone
        $lastMessageRecievedTrace.Received = $lastMessageRecievedTrace.Received + $mountTimeZone
    }
    Write-Host 
    Write-Host "==============================Received================================" -ForegroundColor Yellow
    Write-Host "The trace for the last email $mailbox recieved is as follows:" -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Yellow
    Write-Host ($lastMessageRecievedTrace | FT | Out-String) -ForegroundColor Yellow
}
else
{
    Write-Host "The user has no recently received email" -ForegroundColor Green
}



if($gotMobile -ne $null)
{
    Write-Host 
    Write-Host "==================================Mobile==============================" -ForegroundColor Gray
    Write-Host "User has the following mobile device(s) attached:" -ForegroundColor Gray
    Write-Host "======================================================================" -ForegroundColor Gray
    Write-Host ($gotMobile | FT | Out-String) -ForegroundColor Gray
}
else
{
    Write-Host "User has no mobile device connected" -ForegroundColor Green
}

#endregion