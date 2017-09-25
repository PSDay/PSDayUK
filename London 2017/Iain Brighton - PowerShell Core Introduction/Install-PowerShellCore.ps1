#requires -RunAsAdministrator

## Install latest PowerShell Core MSI x64 release
$latestRelease = Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/latest -UseBasicParsing
$msiRelativeLink = $latestRelease.Links | Where href -Match '-win-x64.msi' | % href
$msiInstallerPath = Join-Path -Path $env:TEMP -ChildPath $msiRelativeLink.Split('/')[-1]

if (-not (Test-Path -Path $msiInstallerPath)) {
    Invoke-WebRequest -Uri ('https://github.com{0}' -f $msiRelativeLink) -OutFile $msiInstallerPath
}
& msiexec.exe /i $msiInstallerPath /qb
