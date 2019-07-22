$primaryUsers = @()
$primaryUserDetails = @()
$computers = Import-Csv C:\scripts\lookupmachines.csv
ForEach($computer in $computers)
{
    
    $primaryUsers += Get-CMUserDeviceAffinity -DeviceName $computer.name | Where {$_.Types -eq '1'} | select ResourceName, UniqueUserName
}
for ($i = 0; $i -lt $primaryUsers.Count; $i++)
{ 
    try
    {
       $curUser = ''
       $curUser = Get-ADuser $primaryUsers[$i].UniqueUserName.Split('\')[-1] -Properties gecos,description | Select gecos,description
    }
    catch{}

    if($curUser -ne "")
    {
        $curDeviceDescription = Get-ADComputer($primaryUsers[$i].ResourceName) -Properties Description | Select -ExpandProperty Description
        $userObj = new-object psobject
        $userObj | add-member -Name Device -MemberType NoteProperty -Value $primaryUsers[$i].ResourceName
        $userObj | add-member -Name "Primary User" -MemberType NoteProperty -Value $curUser.gecos
        $userObj | add-member -Name Department -MemberType NoteProperty -Value $curUser.description
        $userObj | add-member -Name "Device description" -MemberType NoteProperty -Value $curDeviceDescription
        $primaryUserDetails += $userObj
    }
}
$primaryUserDetails