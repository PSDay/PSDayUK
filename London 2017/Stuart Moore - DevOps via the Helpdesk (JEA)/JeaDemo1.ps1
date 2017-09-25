<#
JEA Demos 1 - Investigating the basic PowerShell endpoints

Author: Stuart Moore
Email: stuart@stuart-moore.com
Twitter: @napalmgram
blog: https://stuart-moore.com

This needs to be run in UAC elevated session
List all endpoints on a machine:
#>
Get-PSSessionConfiguration 


<#
Usually you'll get 4 on a clean machine:

microsoft.powershell                    
microsoft.powershell.workflow           
microsoft.powershell32                  
microsoft.windows.servermanagerworkflows

By Default you'll connect to the bit version you're running:
#>


Invoke-Command -ComputerName localhost -Scriptblock {[Environment]::Is64BitProcess}
Invoke-Command -ConfigurationName Microsoft.PowerShell32 -computerName localhost -ScriptBlock {[Environment]::Is64BitProcess}
Invoke-Command -ConfigurationName Microsoft.PowerShell -ComputerName localhost -Scriptblock {[Environment]::Is64BitProcess} 

<#
These have an associated set of permissions:
#>
Get-PsSessionConfiguration | select Name, Permission | Format-List

<#
This is the first level of constraint

If you've not modified your machine, this is why you can only remote from an elevated session

The next level of constraint is in the number of commands you're allowed to use:
#>

"Normal $((Get-Command | measure-Object).Count)"

Invoke-Command -ComputerName localhost {"Remote powershell32 $((Get-Command | measure-Object).Count)"} -ConfigurationName microsoft.powershell32
Invoke-Command -ComputerName localhost {"Remove PowerShell $((Get-Command | measure-Object).Count)"} -ConfigurationName microsoft.powershell
Invoke-Command -ComputerName localhost {"Remote Powershell workflow $((Get-Command | measure-Object).Count)"} -ConfigurationName microsoft.powershell.workflow
Invoke-Command -ComputerName localhost {"Remote ServerManagerWorkflow $((Get-Command | measure-Object).Count)"} -ConfigurationName microsoft.windows.servermanagerworkflows

<#
ServerManagerWorkflows really doesn't like you connecting:
#>
Enter-PsSession -ComputerName localhost -ConfigurationName microsoft.windows.servermanagerworkflows

<#
 This is a session running in no-language mode, so offers none of the usual ps commands. 
 This is usually an indication that someone doesn't want you playing with it!

Let's have a look at microsoft.powershell.workflow
#>

Enter-PsSession -ComputerName localhost -ConfigurationName microsoft.powershell.workflow
#This should be running in the session:
Get-Command
#Mainly commands to do with WorkFlows, plus some basics
Get-Command | Where-Object {$_.name -like 'stop*'}
#Pipeline support
$a = Get-Command | Where-Object {$_.name -like 'stop*'}
$a
#And we have variables as well!

Exit-PSSession

<#
Lots of other details also available if you want to peek
#>

clear-host
Get-PsSessionConfiguration -Name microsoft.powershell | select-object *
clear-host
Get-PsSessionConfiguration -Name microsoft.powershell.workflow | select-object *
clear-host
Get-PsSessionConfiguration -Name microsoft.windows.servermanagerworkflows | select-object *




