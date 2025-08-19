Write-Host "===== Windows 11 CIS Benchmark Audit =====" -ForegroundColor Cyan

# 1. Firewall Enabled Check
$firewall = Get-NetFirewallProfile | Select-Object Name, Enabled
foreach ($f in $firewall) {
    if ($f.Enabled -eq 1) {
        Write-Host "PASS - Firewall $($f.Name) is enabled" -ForegroundColor Green
    } else {
        Write-Host "FAIL - Firewall $($f.Name) is disabled" -ForegroundColor Red
    }
}

# 2. Minimum Password Length
$netAccounts = net accounts
$minPwdLength = ($netAccounts | Select-String "Minimum password length").ToString().Split(":")[1].Trim()
if ([int]$minPwdLength -ge 14) {
    Write-Host "PASS - Minimum password length is $minPwdLength" -ForegroundColor Green
} else {
    Write-Host "FAIL - Minimum password length is $minPwdLength (should be >=14)" -ForegroundColor Red
}

# 3. Maximum Password Age
$maxPwdAge = ($netAccounts | Select-String "Maximum password age").ToString().Split(":")[1].Trim()
if ([int]$maxPwdAge -le 365 -and [int]$maxPwdAge -ge 1) {
    Write-Host "PASS - Maximum password age is $maxPwdAge days" -ForegroundColor Green
} else {
    Write-Host "FAIL - Maximum password age is $maxPwdAge (should be between 1 and 365)" -ForegroundColor Red
}

# 4. Guest Account Disabled
$guest = Get-LocalUser | Where-Object {$_.Name -eq "Guest"}
if ($guest.Enabled -eq $false) {
    Write-Host "PASS - Guest account is disabled" -ForegroundColor Green
} else {
    Write-Host "FAIL - Guest account is enabled" -ForegroundColor Red
}

# 5. Remote Desktop Status
$rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections
if ($rdp -eq 1) {
    Write-Host "PASS - Remote Desktop is disabled" -ForegroundColor Green
} else {
    Write-Host "FAIL - Remote Desktop is enabled" -ForegroundColor Red
}
