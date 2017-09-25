## Demo 1: Installing
## ------------------

## Installing PowerShell Core on Linux using the Universal Installer
## https://cloudywindows.io/post/the-universal-powershell-core-installer-install-powershell.sh/
## bash <(wget -O - https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/install-powershell.sh)
## Installing PowerShell Core on Windows using the MSI
## Installing PowerShell Core on Windows using the ZIP
## https://github.com/PowerShell/PowerShell/releases/latest


## Demo 2: Commands
## ----------------

## $PSVersionTable
## Get-Command | Measure-Object
## Get-Process
## Get-Process | Get-Member
## Get-Process | Where processname -match systemd
## Get-Process | Where processname -match systemd | % id
## Get-Process | Where processname -match systemd | Select -Expand id

## Get-Location | fl
## Split-Path -Path $pwd
## Split-Path -Path $pwd -Leaf
## Join-Path -Path /etc -ChildPath ssh/sshd_config


## Demo 3: Gotchas
## ---------------

## ls / -al | gm
## [System.Text.Encoding]::UTF8.GetBytes([System.Environment]::NewLine)
## Get-Alias -Name ls
## Get-Service
## Get-LocalUser
## $PSVersionTable.BuildVersion


## Demo 4: Classes
## ---------------

## Class Car {
##     [System.String] $Vin = (New-Guid).ToString().ToUpper().Replace('-','')
##     [System.Byte]$NumberOfDoors = 2
##     [System.Int16] $Year = (Get-Date).Year
##     [System.String] $Model
##     static [System.Byte] $NumberOfWheels = 4
## }

## [Car]::New()
## [Car]::NumberOfWheels


## Demo 5: PSRemoting
## ------------------

## PowerShell Core 6.0 (on Windows) >> Windows PowerShell 5.1
## Enter-PSSession -ComputerName 10.200.1.101 -Credential ~\Administrator
## ** PowerShell Core 6.0 (on Linux) >> Windows PowerShell 5.1 requires OMI and PSRP

## Configure SSH on Linux
## sudo vi /etc/ssh/sshd_config
## ** Add 'Subsystem powershell powershell -sshs -NoLogo -NoProfile'
## sudo service sshd restart

## Install OpenSSH on Windows
## https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH
## .\Install-OpenSSH.ps1

## SSH from Windows to Linux to test SSH is working ;)
## ssh ubuntu@10.200.1.105
## powershell
## uname -a

## PowerShell Core 6.0 (on Windows) >> PowerShell Core 6.0 (on Linux)
## Enter-PSSession -HostName 10.200.1.105 -UserName ubuntu
## $PSVersionTable
## uname -a

## PowerShell Core 6.0 (on Linux) >> PowerShell Core 6.0 (on Windows)
## Enter-PSSession -HostName 10.200.1.101 -UserName Administrator
## $PSVersionTable
## cmd.exe /c ver

