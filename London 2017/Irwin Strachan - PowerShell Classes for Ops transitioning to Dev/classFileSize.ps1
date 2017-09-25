<#

Author: I. Strachan
Version: 1.0
Version History:

Purpose: Demo PowerShell Classes FileSize

#>
[CmdletBinding()]
param(
    $FilePath = 'C:\scripts\psdaysuk\files'
)

#region Example 1 Get File Size the Ops way

#This will give me the list in Bytes, rather have it in a format
Get-ChildItem $FilePath -Recurse -File |
Select-object BaseName,FullName,Length |
Format-List
#endregion

#region Example 2 Get File Size in Kb

#Next best option is to format your select. This will give me the size in KB
Get-ChildItem $FilePath -Recurse -File |
Select-object BaseName,FullName,
    @{Name ='SizeinKB'; Expression ={ $('{0:N2} {1}' -f ($_.Length /1kb), 'kB')}} |
Format-List
#endregion

#region Example 3 Get File Size in KB,MB and GB

#Why not just format thema all? This will give me the size in KB,MB and GB
Get-ChildItem $FilePath -Recurse -File |
Select-object BaseName,FullName,
    @{Name = 'SizeinKB'; Expression ={ $('{0:N2} {1}' -f ($_.Length /1kB), 'kB')}}, 
    @{Name = 'SizeinMB'; Expression ={ $('{0:N2} {1}' -f ($_.Length /1MB), 'MB')}}, 
    @{Name = 'SizeinGB'; Expression ={ $('{0:N2} {1}' -f ($_.Length /1GB), 'GB')}}    |
Format-List

#This gives you a weird list
#endregion

#region Example 4 Use Add-Member. Get File Size in different formats using a script method
$Files = Get-ChildItem $FilePath -Recurse -File |
ForEach-Object{
    [PSCustomObject]@{
        BaseName  = $_.BaseName
        FullName  = $_.FullName
        SizeBytes = $_.Length
    } | 
    Add-Member ScriptMethod SizeMB {'{0:N2} {1}' -f ($This.SizeBytes/1mb), 'MB' } -PassThru |
    Add-Member ScriptMethod SizeKB {'{0:N2} {1}' -f ($This.SizeBytes/1kb), 'KB' } -PassThru |
    Add-Member ScriptMethod SizeGB {'{0:N2} {1}' -f ($This.SizeBytes/1gb), 'GB' } -PassThru
}

#Get Files in KB
$Files | 
Select-Object FullName, SizeBytes, @{Name ='SizeKB'; Expression ={ $_.SizeKB()}}

#Get Files in MB
$Files | 
Select-Object FullName, SizeBytes, @{Name ='SizeMB'; Expression ={ $_.SizeMB()}}

#Get Files in GB
$Files | 
Select-Object FullName, SizeBytes, @{Name ='SizeGB'; Expression ={ $_.SizeGB()}}

#Get the last entry in $files
$Files[-1].BaseName
$Files[-1].SizeKB() #Would rather much have this in MB)
$Files[-1].SizeMB() #Much better
#endregion

#region Example 5a Use a Filter to to File Size
filter Get-FileSize {
    '{0:N2} {1}' -f $(
        if ($_ -lt 1kb) { $_, 'Bytes' }
        elseif ($_ -lt 1mb) { ($_/1kb), 'KB' }
        elseif ($_ -lt 1gb) { ($_/1mb), 'MB' }
        elseif ($_ -lt 1tb) { ($_/1gb), 'GB' }
        elseif ($_ -lt 1pb) { ($_/1tb), 'TB' }
        else { ($_/1pb), 'PB' }
    )
}

Get-ChildItem $FilePath -Recurse -File |
ForEach-Object{
    [PSCustomObject]@{
        BaseName  = $_.BaseName
        FullName  = $_.FullName
        SizeBytes = $_.Length
        SizeFM    = $($_.Length | Get-FileSize)
    } 
} |
Format-List
#endregion

#region Example 5b Use a script method to figure out the correct format size

#Before Classes this would have been to best way to go
$Files = Get-ChildItem $FilePath -Recurse -File |
ForEach-Object{
    [PSCustomObject]@{
        BaseName  = $_.BaseName
        FullName  = $_.FullName
        SizeBytes = $_.Length
    } | 
    Add-Member ScriptMethod SizeFormatted {
        '{0:N2} {1}' -f $(
            #Notice we need to use $This variable here? It was hiding in plain sight
            if ($This.SizeBytes -lt 1kb) { $This.SizeBytes, 'Bytes' }
            elseif ($This.SizeBytes -lt 1mb) { ($This.SizeBytes / 1kb), 'KB' }
            elseif ($This.SizeBytes -lt 1gb) { ($This.SizeBytes / 1mb), 'MB' }
            elseif ($This.SizeBytes -lt 1tb) { ($This.SizeBytes / 1gb), 'GB' }
            elseif ($This.SizeBytes -lt 1pb) { ($This.SizeBytes / 1tb), 'TB' }
            else { ($This.SizeBytes /1pb), 'PB' }
        )
    } -PassThru 
}

$Files | 
Select-Object FullName, SizeBytes, @{Name ='Formatted'; Expression ={ $_.SizeFormatted()}} |
Format-List
#endregion

#region Example 6 Let's make a Class of this

Class FileSize{
    [String]$BaseName
    [String]$FullName
    [Int64]$SizeBytes
    [String]$SizeFM
    Hidden $InvalidFile

    FileSize(){}

    FileSize($fn){
        if(Test-Path $fn -PathType Leaf){
            $item = Get-ChildItem -Path $fn

            $this.FullName = $item.FullName
            $this.SizeBytes = $item.Length
            $this.BaseName = $item.BaseName
            $this.SizeFormatted()
            $this.InvalidFile = $null
        }
        else{
            Write-Warning -Message "File $($fn) doesn't exists"
            $this.InvalidFile = $fn
            $this.FullName = $null
            $this.SizeBytes = $null
            $this.SizeFM = $null
            $this.BaseName = $null
        }
    }

    #Void Method
    SizeFormatted() {
        $This.SizeFM = '{0:N2} {1}' -f $(
            if ($This.SizeBytes -lt 1kb) { $This.SizeBytes, 'Bytes' }
            elseif ($This.SizeBytes -lt 1mb) { ($This.SizeBytes / 1kb), 'KB' }
            elseif ($This.SizeBytes -lt 1gb) { ($This.SizeBytes / 1mb), 'MB' }
            elseif ($This.SizeBytes -lt 1tb) { ($This.SizeBytes / 1gb), 'GB' }
            elseif ($This.SizeBytes -lt 1pb) { ($This.SizeBytes / 1tb), 'TB' }
            else { ($This.SizeBytes /1pb), 'PB' }
        )
    }

    #Static method returns string formatted size
    Static [String]SizeFormatted($fn){
        if(Test-Path $fn -PathType Leaf){
            $item = Get-ChildItem -Path $fn

            return '{0:N2} {1}' -f $(
                if ($item.Length -lt 1kb) { $item.Length, 'Bytes' }
                elseif ($item.Length -lt 1mb) { ($item.Length / 1kb), 'KB' }
                elseif ($item.Length -lt 1gb) { ($item.Length / 1mb), 'MB' }
                elseif ($item.Length -lt 1tb) { ($item.Length / 1gb), 'GB' }
                elseif ($item.Length -lt 1pb) { ($item.Length / 1tb), 'TB' }
                else { ($item.Length /1pb), 'PB' }
            )
        }
        else{
            return Write-Warning -Message "File $($fn) doesn't exists"
        }
    }

    #void method to verify if file exists
    VerifyFile(){
        if(Test-Path $this.FullName -PathType Leaf){
            $item = Get-ChildItem -Path $this.FullName

            $this.FullName = $item.FullName
            $this.SizeBytes = $item.Length
            $this.BaseName = $item.BaseName
            $this.SizeFormatted()
            $this.InvalidFile = $null
        }
        else{
            Write-Warning -Message "File $($this.FullName) doesn't exists"
            $this.InvalidFile = $this.FullName
            $this.FullName = $null
            $this.SizeBytes = $null
            $this.SizeFM = $null
            $this.BaseName = $null
        }
    }
}

#region reviewing the Class
#Overload Definitions
[FileSize]::new

#Get the basic information from the Class
[FileSize]::new() | Get-Member

#To get the hidden property use -Force
[FileSize]::new() | Get-Member -Force

#To get the Static methods
[FileSize]::new() | Get-Member -Static
#endregion

#region Instantiate a variable with [FileSize] objects
$classFiles = Get-ChildItem $FilePath -Recurse -File |
ForEach-Object{
    [FileSize]::new($_.FullName)
}

#The Results
$classFiles

#Let's change the last entry to something not valid
$classFiles[-1].FullName = 'C:\scripts\psdaysuk\files\WhatsAppSetup.ex'
$classFiles[-1]
$classFiles[-1].VerifyFile()
$classFiles[-1]
$classFiles.InvalidFile


#Repair the damage made
$classFiles[-1].FullName = 'C:\scripts\psdaysuk\files\WhatsAppSetup.exe'
$classFiles[-1]
$classFiles[-1].VerifyFile()
$classFiles[-1]
$classFiles.InvalidFile

#Get Static Method SizeFormatted with FullName as parameter
[FileSize]::SizeFormatted('C:\scripts\psdaysuk\files\WhatsAppSetup.ex')
[FileSize]::SizeFormatted('C:\scripts\psdaysuk\files\WhatsAppSetup.exe')
#endregion

#region create an array with some bad entries,fix and verify.

#The list here is specific for Demo purposes.
$arrFiles = @(
    'C:\scripts\psdaysuk\files\Get-SIDHistoryUserAndGroups.ps1'
    'C:\scripts\psdaysuk\files\Get-UserPrimarySMTPAddress.ps1'
    'C:\scripts\psdaysuk\files\New-ADDemoUser.ps1'
    'C:\scripts\psdaysuk\files\New-ADDemoUsers.Tests.ps1'
    'C:\scripts\psdaysuk\files\sharepointclientcomponents_16-6518-1200_x64-en-us.msi'
    'C:\scripts\psdaysuk\files\SlackSetup.ee'
    'C:\scripts\psdaysuk\files\WhatsAppSetup.ex'
)

$results = $arrFiles | 
ForEach-Object{
    [FileSize]::New($_)
}

$results | Format-List

#Get the InvalidFiles
$results.InvalidFile

#region Fix the bad entries
$results[2].InvalidFile
$results[2].FullName = 'C:\scripts\psdaysuk\files\New-ADDemoUsers.ps1'

$results[-2].InvalidFile
$results[-2].FullName = 'C:\scripts\psdaysuk\files\SlackSetup.exe'

$results[-1].InvalidFile
$results[-1].FullName = 'C:\scripts\psdaysuk\files\WhatsAppSetup.exe'
#endregion

#Verify that they are correct
$results.VerifyFile()

$results | Format-List

#Verify no more InvalidFile
$results.InvalidFile
#endregion

#endregion 
