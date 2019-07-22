$action = New-ScheduledTaskAction -Execute '"C:\Program Files (x86)\VMware\VMware Horizon View Client\vmware-view.exe"' -Argument '-serverURL https://one.unm.edu -desktopName Kiosk_IC -connectusboninsert 0 -loginAsCurrentUser 1 -desktopLayout fullscreen'
$trigger =  New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Highest
Register-ScheduledTask -TaskName "RunView" -TaskPath "\UNM" -Action $action -Trigger $trigger -Principal $principal

$action = New-ScheduledTaskAction -Execute Powershell.exe -Argument '-WindowStyle Hidden C:\Scripts\LogOff_When_ViewDesktop_Closes.ps1'
$trigger =  New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Highest
Register-ScheduledTask -TaskName "LogOFfWhenViewCloses" -TaskPath "\UNM" -Action $action -Trigger $trigger -Principal $principal