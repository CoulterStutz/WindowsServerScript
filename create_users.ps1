# Check if the script is run with the "--initialize" argument
if ($args.Contains("--initialize")) {
    # Create AD user cstutz and add to Administrators group
    New-ADUser -Name "cstutz" -SamAccountName "cstutz" -AccountPassword (ConvertTo-SecureString "YourPassword" -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true
    Add-ADGroupMember -Identity "Administrators" -Members "cstutz"

    # Create AD group Servers
    New-ADGroup -Name "Servers" -GroupScope Global -GroupCategory Security
    # Grant Servers group permission to add users to the domain
    $acl = Get-Acl "AD:\CN=Users,DC=domain,DC=com"
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule("Servers", "WriteProperty", "Allow")
    $acl.AddAccessRule($ace)
    Set-Acl "AD:\CN=Users,DC=domain,DC=com" $acl

    # Create AD user NAS and add to Servers group
    New-ADUser -Name "NAS" -SamAccountName "NAS" -AccountPassword (ConvertTo-SecureString "YourPassword" -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true
    Add-ADGroupMember -Identity "Servers" -Members "NAS"
}
else {
    # Loop to add users until closed
    while ($true) {
        $username = Read-Host "Enter username"
        $password = Read-Host "Enter password" -AsSecureString
        $passwordExpirationDate = (Get-Date).AddDays(1)  # Password must be changed at next logon

        New-ADUser -Name $username -SamAccountName $username -AccountPassword $password -Enabled $true -ChangePasswordAtLogon $true -PasswordNeverExpires $false -AccountExpirationDate $passwordExpirationDate
    }
}
