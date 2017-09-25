break
<#
JEA Demos 2 - Creating a simple basic endpoint

Author: Stuart Moore
Email: stuart@stuart-moore.com
Twitter: @napalmgram
blog: https://stuart-moore.com

These examples are targeting a locally hosted VM called $vmname

The server has 4 users:
alice - alice admin - member of administrators
dave  - dave developer - no group membership
harry - harry helpdesk - no group membership
stuart - stuart sql admin - no group membership
#>

#region setup some creds
$VmName = 'jea server'
$secpasswd = ConvertTo-SecureString "RAND0m1" -AsPlainText -Force
$AdminCred = New-Object System.Management.Automation.PSCredential ("Administrator", $secpasswd)
$AliceCred = New-Object System.Management.Automation.PSCredential ("alice", $secpasswd)
$DaveCred = New-Object System.Management.Automation.PSCredential ("dave", $secpasswd)
$HarryCred  = New-Object System.Management.Automation.PSCredential ("harry", $secpasswd)
$StuartCred = New-Object System.Management.Automation.PSCredential ("stuart", $secpasswd)

$AdminSess = New-PsSession -VmName $VmName -Credential $AdminCred

if ((get-Vm -VMName $VmName).State -eq 'off'){
    get-Vm -VMName $VmName | Start-Vm 
} 

#endregion setup some creds

#region Create Module framework
$Root = 'C:\jeademo'
$ModuleName = 'JeaModule'
if (!(Test-Path -Path "$Root\$ModuleName")){
    New-Item "$Root\$ModuleName" -ItemType Directory
}

if (!(Test-Path -Path "$Root\$ModuleName\RoleCapabilities")){
    New-Item "$Root\$ModuleName\RoleCapabilities" -ItemType Directory
}

if (!(Test-Path -Path "$Root\$ModuleName\$ModuleName.psm1")){
    New-Item "$Root\$ModuleName\$ModuleName.psm1" -ItemType File
}

if (!(Test-Path -Path "$Root\$ModuleName\$ModuleName.psd1")){
    New-ModuleManifest -Path "$Root\$ModuleName\$ModuleName.psd1" `
            -RootModule "$Root\$ModuleName\$ModuleName.psm1" `
            -Description "Let's play with Jea" `
            -Author "Stuart Moore" 
}
#endregion Create Module framework


#region create empty session config 
$ConfigFile = "$Root\$ModuleName\RoleCapabilities\$moduleName.pssc"
New-PSSessionConfigurationFile -path $ConfigFile  -Full

$RoleFile = "$Root\$ModuleName\RoleCapabilities\$moduleName.psrc"
New-PsRoleCapabilityFile -path $RoleFile

ise "$Root\$ModuleName\RoleCapabilities\$moduleName.psrc"
ise "$Root\$ModuleName\RoleCapabilities\$moduleName.pssc"

Function Register-DemoModule
{
    $AdminSess = New-PsSession -VmName $VmName -Credential $AdminCred
    copy-Item $Root\$ModuleName 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force -ToSession $AdminSess

    $RegisterSb = [Scriptblock]::Create(@"
        if ((Get-PsSessionConfiguration -Name $ModuleName).count -ne 0){
            Unregister-PsSessionConfiguration -Name $ModuleName
        }
        Register-PsSessionConfiguration -Path "C:\Program Files\WindowsPowerShell\Modules\$ModuleName\RoleCapabilities\$moduleName.pssc" -Name $ModuleName
        Restart-Service WinRM
"@)

$AdminSess = New-PsSession -VmName $VmName -Credential $AdminCred
Invoke-Command -ScriptBlock $RegisterSb -Session $AdminSess
}

Register-DemoModule

$AliceSess = New-PsSession -VMName $VmName -Credential $AliceCred -ConfigurationName $ModuleName

Enter-PsSession -Session $AliceSess
Get-PSSessionConfiguration | select Name, Permission | Format-List
exit-PsSession

#No Roles yet, so Harry connect as normal:

$HarrySess = New-PSSession -VMName $VmName -Credential $HarryCred -ConfigurationName $ModuleName
Enter-PsSession -Session $HarrySess
Exit-PSSession

Enter-PsSession -VMName $Vmname -Credential $HarryCred


#endregion create empty session config

#region start restricting the session:

<# Typing in a demo, what could possibly go wrong.....

Change SessionType in $ConfigFile to:
SessionType = 'RestrictedRemoteServer'

Add this:
RoleDefinitions = @{ 'harry' = @{ RoleCapabilities = 'JeaModule' } }
#>

Register-DemoModule

#Even an administrator can't connect to the session if they aren't in a role
$AliceSess = New-PsSession -VMName $VmName -Credential $AliceCred -ConfigurationName $ModuleName


#Harry can though:
$HarrySess = New-PsSession -VMName $VmName -Credential $HarryCred -ConfigurationName $ModuleName
Enter-PsSession -Session $HarrySess

#RestrictedRemoteServer sets the available cmdlets to a very small set:
Get-Command

get-command | Where-Object {$_.name -like 'get*'}
(Get-command).StartsWith('get')


<#
Let's give Harry some more commands:

Add this to RoleConfig file:
VisibleCmdlets = 'Get-Service', 'Restart-Service'
#>

Register-DemoModule

$HarrySess = New-PsSession -VMName $VmName -Credential $HarryCred -ConfigurationName $ModuleName
Enter-PsSession -Session $HarrySess
#Harry can now see all services
Get-Service

#Lets restart some:
Restart-Service -name bits
Restart-Service -name dnscache

#oops, he doesn't have the rights to do that
Exit-PsSession

<#
Add this to the Session Config file:
RunAsVirtualAccount = $true

This will cause the session to run as a virtual account.
On standard computer (server or workstation) this will be a member of Administrators
On a Domain Controller, it'll be a member of Domain Admins
#>
Register-DemoModule

$HarrySess = New-PsSession -VMName $VmName -Credential $HarryCred -ConfigurationName $ModuleName
Enter-PsSession -Session $HarrySess

Restart-Service -name bits
Restart-Service -name dnscache

Exit-PsSession

<#
Change
VisibleCmdlets = 'Get-Service', 'Restart-Service'

to
VisibleCmdlets = 'Get-Service', @{ Name = 'Restart-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'bits' } }
#>

Register-DemoModule

$HarrySess = New-PsSession -VMName $VmName -Credential $HarryCred -ConfigurationName $ModuleName
Enter-PsSession -Session $HarrySess

Restart-Service -name bits
Restart-Service -name dnscache

Get-Service -Name Bits | Restart-Service
Get-Service -Name Fax | Restart-Service

Exit-PsSession

<#
Change
VisibleCmdlets = 'Get-Service', @{ Name = 'Restart-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'bits' } }

to
VisibleCmdlets = 'Get-Service', @{ Name = 'Restart-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'bits'; Name='Verbo } }
#>

Register-DemoModule

$HarrySess = New-PsSession -VMName $VmName -Credential $HarryCred -ConfigurationName $ModuleName
Enter-PsSession -Session $HarrySess

Restart-Service -name bits 
Restart-Service -name fax

Get-Service -Name Bits | Restart-Service
Get-Service -Name Fax | Restart-Service

Exit-PsSession

#endregion start restricting the session

#region adding another role

$AdminRoleName = 'AdminRole'
$AdminRoleFile = "$Root\$ModuleName\RoleCapabilities\$AdminRoleName.psrc"
New-PsRoleCapabilityFile -path $AdminRoleFile

ise $AdminRoleFile

<#
Add to AdminRole File
VisibleCmdlets = 'Get-Service','Restart-Service' 

In pssc change
RoleDefinitions = @{ 'harry' = @{ RoleCapabilities = 'JeaModule' } }

to 
RoleDefinitions = @{ 'harry' = @{ RoleCapabilities = 'JeaModule' }; 'alice' = @{ RoleCapabilities = 'AdminRole' } } 
#>

Register-DemoModule

$AliceSess = New-PsSession -VMName $VmName -Credential $AliceCred -ConfigurationName $ModuleName
Enter-PSSession -Session $AliceSess

Restart-Service bits
Restart-Service spooler

Exit-PsSession

#endregion adding another role

#region Logging user actions
<#
In session config, add
TranscriptDirectory = 'C:\Transcripts\'
#>

#Quick cleanup:
if (!(Test-Path "$Root\transcripts")){
    New-Item "$Root\transcripts" -ItemType Directory
} else {
    Remove-Item "$Root\transcripts\*"
} 

Register-DemoModule
Invoke-Command -Session $AdminSess -ScriptBlock {Remove-Item c:\transcripts\*}


$HarrySess = New-PsSession -VMName $VmName -Credential $HarryCred -ConfigurationName $ModuleName
Enter-PsSession -Session $HarrySess

Restart-Service -name bits 
Restart-Service -name dnscache

Exit-PsSession

#This is a hack to force WinRM to release it's grip on the transcript file just so the demo carries on
Register-DemoModule

copy-Item c:\Transcripts\* "$Root\transcripts" -FromSession $AdminSess
Invoke-Item "$Root\transcripts"

#endregion Logging user actions


