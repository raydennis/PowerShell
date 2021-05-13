$credential = Get-Credential 

# old Reset-ComputerMachinePassword -Server it153cdc03.colleges.ad.unm.edu

new Test-ComputerSecureChannel -Repair -Credential (Get-Credential)
