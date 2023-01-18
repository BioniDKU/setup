Clear-Host
Write-Host 'Project BioniDKU - Next Generation AutoIDKU' -ForegroundColor White -BackgroundColor Magenta
Write-Host "Starting up..." -ForegroundColor Magenta -BackgroundColor Gray
Write-Host " "

# Script build number and the PowerShell 7 download link
$scriptbuild = "Build 22107.201_b1.oseprod_betarel.230118-1802"
$pwsh7 = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.1/PowerShell-7.3.1-win-x64.msi"

# Create Registry Folder
$autoidku = Test-Path -Path 'HKCU:\SOFTWARE\AutoIDKU'
if ($autoidku -eq $false) {
	Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Setting up environment"
	New-Item -Path 'HKCU:\SOFTWARE' -Name AutoIDKU
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "BootStrapped" -Value 0 -Type DWord -Force
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Butter" -Value $scriptbuild
}

# Is the bootstrap process already completed?
$booted = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").BootStrapped
if ($booted -eq 1) {exit}

# Find the build number and the UBR of the OS. 
# This script runs best on General Availability builds between 10240 and 19045. You can of course modify the lines below for it to run on untested builds, although stability will suffer and I will not be providing support for those scenarios.
Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Checking your PC"
$build = [System.Environment]::OSVersion.Version | Select-Object -ExpandProperty "Build"
$ubr = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').UBR
$gablds = 10240,10586,14393,15063,16299,17134,17763,18362,18363,19041,19042,19043,19044,19045
switch ($build) {
    {$_ -ge 10240 -and $_ -le 19045} {
		if ($gablds.Contains($_) -eq $true) {
			Write-Host "Supported stable build of Windows 10 detected" -ForegroundColor Green -BackgroundColor DarkGray -n; Write-Host ([char]0xA0)
		} else {
			Write-Host "Your Windows 10 build appears to be in the supported range, but doesn't seem to be a General Availability build. `r`nStability might suffer and I will not be providing support for issues happening on such builds." -ForegroundColor Yellow -BackgroundColor DarkGray -n; Write-Host ([char]0xA0)
			$ngawarn = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").SkipNotGABWarn
			if ($ngawarn -ne 1) {
				Write-Host "Press Enter to continue."; Read-Host
				Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "SkipNotGABWarn" -Value 1 -Type DWord -Force
			}
		}
	}
    default {
        Write-Host "You're not running a supported build of Windows for this script. Press Enter to exit." -ForegroundColor Red -BackgroundColor DarkGray -n; Write-Host ([char]0xA0)
		Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Denied" -Value 1 -Type DWord -Force
        Read-Host
        exit
    }
}
Write-Host "You're running Windows 10 build"$build"."$ubr

# Apply TLS settings, which will take effect immediately when launching main.ps1
if ($build -le 17134 -and $build -ge 10240) {
    $tls1 = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319').SchUseStrongCrypto
    $tls2 = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319').SchUseStrongCrypto
    if ($tls1 -eq 0 -or $tls2 -eq 0 -or $null -eq $tls1 -or $null -eq $tls2) {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
    }
}

# Get the utilities package
Write-Host -ForegroundColor Green -BackgroundColor DarkGray "Getting dependencies ready"
Start-Process powershell -Wait -ArgumentList "-Command $PSScriptRoot\..\utils\utilsg.ps1" -WorkingDirectory $PSScriptRoot\..\utils

# Install PowerShell 7 for the music player cross-version
Import-Module BitsTransfer
$pwsh7e = Test-Path -Path "$env:SYSTEMDRIVE\Program Files\PowerShell\7"
if ($pwsh7e -eq $false) {
	Start-BitsTransfer -Source $pwsh7 -Destination $PSScriptRoot\core7.msi -RetryInterval 60
	Write-Host -ForegroundColor Green -BackgroundColor DarkGray "Getting ready"
	Start-Process msiexec -Wait -ArgumentList "/package $PSScriptRoot\core7.msi /quiet ADD_PATH=1"
}

if ($build -le 10586) {
	Write-Host " "
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Pwsh" -Value 5 -Type DWord -Force
}
if ($build -ge 14393) {
	Write-Host " "
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Pwsh" -Value 7 -Type DWord -Force
}
Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "BootStrapped" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "ConfigSet" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "ConfigEditing" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "ChangesMade" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Denied" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "HikaruMode" -Value 0 -Type DWord -Force
exit