Import-Csv C:\scripts\lookupUsers.csv | ForEach-Object{Get-ADuser -Filter {gecos -eq $_.name} -Properties gecos,description | FT @{n='Name';e={$_.gecos}},@{n='Department';e={$_.description}}}

