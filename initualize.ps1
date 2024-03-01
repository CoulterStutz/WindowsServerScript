$alias = "Ethernet"
$ipAddress = "192.168.1.3"
$prefix = 24
$gateway = "192.168.1.1"
$NameServer1 = "192.168.1.3"
$NameServer2 = "1.1.1.1"

Set-NetIPInterface -InterfaceAlias $alias -Dhcp Enabled

# Install Hyper-V + DNS + AD
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
Install-WindowsFeature -Name DNS -IncludeManagementTools
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses ($Dns1, $Dns2)

Install-ADDSForest `
    -DomainName "cstutz.dev" `
    -DomainMode "WinThreshold" `
    -ForestMode "WinThreshold" `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -NoRebootOnCompletion:$false `
    -Force:$true