#LogOff when desktop closes
Start-Sleep -s 60
 
while($process = Get-Process -Name vmware-remotemks -ErrorAction SilentlyContinue)
{
start-sleep -s 5
}
logoff