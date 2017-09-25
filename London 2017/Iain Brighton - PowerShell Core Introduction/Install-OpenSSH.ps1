#requires -RunAsAdministrator
#requires -Version 5

## Install latest Win32_OpenSSH x64 release
$latestRelease = Invoke-WebRequest -Uri https://github.com/PowerShell/Win32-OpenSSH/releases/latest -UseBasicParsing
$zipRelativeLink = $latestRelease.Links | Where href -Match '-Win64.zip' | % href
$zipPath = Join-Path -Path $env:TEMP -ChildPath $zipRelativeLink.Split('/')[-1]

Invoke-WebRequest -Uri ('https://github.com{0}' -f $zipRelativeLink) -OutFile $zipPath
Unblock-File -Path $zipPath

if (-not (Test-Path -Path "$env:ALLUSERSPROFILE\PowerShell")) {
    $null = New-Item -Path $env:ALLUSERSPROFILE -Name 'PowerShell' -ItemType Directory -Force
}

Expand-Archive -Path $zipPath -DestinationPath $env:ALLUSERSPROFILE

Push-Location -Path "$env:ALLUSERSPROFILE\OpenSSH-Win64"
& "$env:ALLUSERSPROFILE\OpenSSH-Win64\install-sshd.ps1"
& C:\ProgramData\OpenSSH-Win64\ssh-keygen.exe -A
& "$env:ALLUSERSPROFILE\OpenSSH-Win64\FixHostFilePermissions.ps1" -Confirm:$false
'sshd', 'ssh-agent' | Set-Service -StartupType Automatic
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

## Update sshd_config and start services
$sshdConfig = @'
#	$OpenBSD: sshd_config,v 1.84 2011/05/23 03:30:07 djm Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

# The default requires explicit activation of protocol 1
#Protocol 2

# HostKey for protocol version 1
#HostKey /etc/ssh/ssh_host_key
# HostKeys for protocol version 2
#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_dsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key

# Lifetime and size of ephemeral version 1 server key
#KeyRegenerationInterval 1h
#ServerKeyBits 1024

# Logging
# obsoletes QuietMode and FascistLogging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#RSAAuthentication yes
#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile	.ssh/authorized_keys

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#RhostsRSAAuthentication no
# similar for protocol version 2
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# RhostsRSAAuthentication and HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication yes
#PermitEmptyPasswords no

# Change to no to disable s/key passwords
#ChallengeResponseAuthentication yes

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes

# Set this to 'yes' to enable PAM authentication, account processing, 
# and session processing. If this is enabled, PAM authentication will 
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
#UsePAM no

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
#X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#UseLogin no
#UsePrivilegeSeparation yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS yes
#PidFile /var/run/sshd.pid
#MaxStartups 10
#PermitTunnel no
#ChrootDirectory none

# no default banner path
#Banner none

# override default of no subsystems
Subsystem	sftp	sftp-server.exe
Subsystem	powershell	c:/program files\powerShell/6.0.0-beta.7/powershell.exe -sshs -NoLogo -NoProfile

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	ForceCommand cvs server
# PubkeyAcceptedKeyTypes ssh-ed25519*
hostkeyagent \\.\pipe\openssh-ssh-agent
'@
$sshdConfig -replace "`n","`r`n" | Set-Content -Path .\sshd_config
'sshd', 'ssh-agent' | Start-Service

Pop-Location
