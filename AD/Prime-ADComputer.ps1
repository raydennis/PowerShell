function New-PADComputer
{
    [CmdletBinding()]
    param([string]$computerName, [string]$location)
    process
    {
        while($computerName -eq '')
        {
            Write-Host 'Please enter a computer name in the format IT-(L or D)(Serialnumber)'  
            Write-Host 'i.e. "IT-Lxxxx" for a laptop or "IT-Dxxxx" for a desktop'
            Write-Host 'An easy way to grab the serialnumber is to type "Wmic bios get serialnumber" from the console on the machine.'

            $computerName = Read-Host -Prompt 'Computer name'

            try
            {
                if(Get-adcomputer($computerName))
                {
                    Write-Host "$computerName already exists" -ForegroundColor RED
                    $computerName = ''
                }
            }
            catch{}
        }

        while($location -eq '')
        {
            Write-Host 'Please enter a location for the computer to be added.'
            Write-Host 'For instance, you could enter: ' -NoNewline
            Write-Host '"OU=From Computers' -ForegroundColor Yellow -NoNewline
            Write-Host ',OU=Workstations,OU=IT,DC=colleges,DC=ad,DC=unm,DC=edu" for the default location' 

            Write-Host 'Common locations are:'
            Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase 'OU=Workstations,OU=IT,DC=colleges,DC=ad,DC=unm,DC=edu' -SearchScope OneLevel | FT name, @{L='location';E={$_.DistinguishedName}}
            $location = Read-Host 'Location'

            try
            {
                if(Get-ADOrganizationalUnit($location))
                {
                    Write-Host "Creating " -NoNewline
                    Write-Host $computerName -ForegroundColor Yellow -NonewLine
                    Write-Host " in " -NoNewLine
                    Write-Host $location -ForegroundColor Green
                }

            }
            catch
            {
                Write-Host 'That location does not exist, please create it first or retype an existing one'
            }
        }

        New-ADComputer -Name $computerName -Location $location
    }
}

