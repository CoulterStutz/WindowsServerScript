$branch = "0.6.5"
$hostname = "Solara"
$userPassword = "TestPassword"

# Create Active Directory user cstutz and add them to the administrators group
New-ADUser -Name "cstutz" -SamAccountName "cstutz" -AccountPassword (ConvertTo-SecureString $userPassword -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true
Add-ADGroupMember -Identity "Administrators" -Members "cstutz"

# Install Git and Python 3
Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe" -OutFile "$env:TEMP\Git-2.35.1.2-64-bit.exe"
Start-Process -FilePath "$env:TEMP\Git-2.35.1.2-64-bit.exe" -ArgumentList "/VERYSILENT /NORESTART" -Wait
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe" -OutFile "$env:TEMP\python-3.10.2-amd64.exe"
Start-Process -FilePath "$env:TEMP\python-3.10.2-amd64.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

# Clone the repository
git clone https://github.com/CoulterStutz/ServerManager.git C:\ServerManager
cd C:\ServerManager
git checkout $branch

# Create a startup script to run main.py in the background
$scriptPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startServerManager.bat"
@"
@echo off
start "" pythonw.exe C:\ServerManager\Client\main.py
"@ | Out-File -FilePath $scriptPath -Encoding ascii

# Set the hostname to Solara
Rename-Computer -NewName $hostname -Force

# Enable Remote Desktop for other users in the domain and on LAN
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Restart the server
Restart-Computer -Force
