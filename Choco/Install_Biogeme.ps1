Set-ExecutionPolicy Bypass

#install chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

#install cygwin and cyg-get with chocolatey
choco install cygwin cyg-get -y
cyg-get autoconf automake bison flex gcc-g++ libstdc++ libtool make python3

#create temp directory
new-item -ItemType directory -Path C:\BioGemeInstall
cd C:\BioGemeInstall

#download biogeme tarball
Invoke-WebRequest -Uri 'http://biogeme.epfl.ch/distrib/biogeme-2.4.tar.gz' -Outfile C:\BioGemeInstall\biogeme-2.4.tar.gz

#explain how to create the biogeme install in cygwin
echo "cd C:\biogemeinstall\`n" "tar xvzf biogeme-2.4.tar.gz`n" "cd biogeme-2.4`n" "./configure --enable-python`n" "make`n" "make install`n" | clip
Add-Type –AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("Please perform the following steps: `n 1. Open the Cygwin Terminal`n 2. Right click and choose paste`n 3. Press enter")
