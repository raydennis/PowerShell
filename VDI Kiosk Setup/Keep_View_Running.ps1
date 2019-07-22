#keep View Running
$targetprocess = "vmware-view" 
$process = Get-Process -Name $targetprocess -ErrorAction SilentlyContinue
 
while ($true){ 
    while (!($process)){ 
        $process = Get-Process -Name $targetprocess -ErrorAction SilentlyContinue
        if (!($process)){ 
            Start-Process "C:\Program Files (x86)\VMware\VMware Horizon View Client\vmware-view.exe" "-serverURL https://it153horcon01.colleges.ad.unm.edu --loginAsCurrentUser 1 -desktopname 'Horizon Instant Clones'"
        } 
        start-sleep -s 5 
    } 
    if ($process){ 
        $process.WaitForExit() 
        start-sleep -s 2 
        $process = Get-Process -Name $targetprocess -ErrorAction SilentlyContinue
        Start-Process "C:\Program Files (x86)\VMware\VMware Horizon View Client\vmware-view.exe" "-serverURL https://it153horcon01.colleges.ad.unm.edu --loginAsCurrentUser 1 -desktopname 'Horizon Instant Clones'" 
    } 
}