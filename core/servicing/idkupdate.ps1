# BioniDKU Windows Update mode - main file
# 
# A decicated mode with a lightweight shell just to run Windows Update
# The purpose is so that the system can focus on the task at hand, without
# too much resources being used by the regular Explorer shell
# This file has a similar structure to the Hikaru menus, one part because
# it's technically a "menu" with the ability to update the system
#
# Project BioniDKU - Copyright (c) 2022-2024 Bionic Butter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# WinXShell is not covered under this license, nor is distributed under
# any licenses. Please see <https://theoven.org/viewtopic.php?t=89> for
# more details

$global:workdir = Split-Path(Split-Path "$PSScriptRoot")
$global:coredir = Split-Path "$PSScriptRoot"
$global:datadir = "$workdir\data"

. $coredir\kernel\osinfo.ps1
. $datadir\dls\PATCHME.ps1
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Windowing.psm1
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Support.psm1
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Ambient.psm1

$bubr = $latest | Select-String -Pattern $build
$lubr = $bubr.Line.Substring($bubr.Line.LastIndexOf(".")+1)
if ([int]$ubr -ge [int]$lubr) {Set-ItemProperty -Path "HKCU:\Software\AutoIDKU"  -Name "Wupdated" -Value 1 -Type DWord -Force}
$global:wupdated = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").Wupdated
$global:hkau = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").HikaruMusic

Show-WindowTitle 2.2 "Windows Update mode"

function Show-Branding {
	Clear-Host
	Write-Host 'Project BioniDKU - Next Generation AutoIDKU' -ForegroundColor White -BackgroundColor Blue
	Write-Host "Windows Update mode" -ForegroundColor Blue -BackgroundColor Gray
	Write-Host " "; Write-OSInfo; Write-Host " "
}
function Show-Menu {
	Show-Branding
	$targetcheck = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ErrorAction SilentlyContinue).TargetReleaseVersion
	if ($wupdated -eq 1) {$wumenudflt0 = "(Default)"} else {$wumenudflt1 = "(Default)"}
	Write-Host -ForegroundColor Yellow " What do you want to do?"
	Write-Host -ForegroundColor White " 1. Continue to Windows Update mode"  -n; Write-Host " $wumenudflt1"
	Write-Host -ForegroundColor White " 2. Switch to Wumgr for this session"
	if ($targetcheck -eq 1 -and $edition -notmatch "Core" -and $build -ge 17134 -and $wupdated -ne 1) {Write-Host -ForegroundColor White "3. I'm stuck at a Feature update!"}
	Write-Host -ForegroundColor White " R. Leave Windows Update mode" -n; Write-Host " $wumenudflt0"
	Write-Host " "
}
function Show-Confirm {
	Write-Host "`r`nAre sure you want to select this option? (1): " -ForegroundColor Yellow -n; $wuconf = Read-Host
	if ($wuconf -ne 1) {continue}
}
function Start-UpdateMode($mode) {
	Show-Branding
	Start-Logging WUMode
	if ((Test-Path -Path "$env:SYSTEMDRIVE\Bionic\WinXShell") -eq $false) {
		Expand-Archive -Path $datadir\utils\WinXShell.zip -DestinationPath $env:SYSTEMDRIVE\Bionic\WinXShell
		Write-Host "Starting WinXShell" -ForegroundColor Cyan -BackgroundColor DarkGray -n; Write-Host ", a lightweight desktop environment used in Windows Preinstalled Environments (Windows PE)"
	}
	Play-Ambient 3
	Start-Process "$env:SYSTEMDRIVE\Bionic\WinXShell\WinXShell.exe"
	if ($hkau -eq 1) {Start-Process powershell -ArgumentList "-Command $coredir\music\musicplayer.ps1"}
	
	switch ($mode) {
		default {
			Write-Host "Starting Windows Update mode normally" -ForegroundColor Cyan -BackgroundColor DarkGray; Start-Sleep -Seconds 3
			if ($wupdated -ne 1) {& $coredir\support\cWUngus.ps1}
			Write-Host "Getting Windows ready" -ForegroundColor Cyan -BackgroundColor DarkGray
			Import-Module PSWindowsUpdate; Write-Host " "
			Write-Host -ForegroundColor Cyan "Updating the system until it reaches the desired UBR"
			Restart-Service -Name wuauserv
			Write-Host -ForegroundColor White "Checking for updates"; Get-WUList
			Write-Host -ForegroundColor White "Checking for updates again and installing all updates found"; Get-WUList -AcceptAll -Install -NotCategory 'Upgrade' -IgnoreReboot | Out-Null
		}
		"Wumgr" {
			Write-Host " "; Write-Host "Starting Windows Update mode with Wumgr" -ForegroundColor Cyan -BackgroundColor DarkGray
			if ((Test-Path -Path "$datadir\utils\Wumgr") -eq $false) {Expand-Archive -Path $datadir\utils\Wumgr.zip -DestinationPath $datadir\utils\Wumgr}
			Start-Process "$datadir\utils\Wumgr\wumgr.exe" -Wait
		}
	}
	Restart-UpdateMode
}
function Stop-UpdateMode($status) {
	switch ($status) {
		"Success" {Play-Ambient 4; Write-Host "The latest updates have been installed." -ForegroundColor Green -BackgroundColor DarkGray -n; Write-Host " Leaving Windows Update mode..."}
		"Aborted" {Play-Ambient 5; Write-Host "You have aborted updates." -ForegroundColor Yellow -BackgroundColor DarkGray -n; Write-Host " Leaving Windows Update mode..."}
	}
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "HikaruMode" -Value 2 -Type DWord -Force
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "RebootScript" -Value 1 -Type DWord -Force
	Start-Sleep -Seconds 5
	Stop-Process -Name "WinXShell" -Force -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "HikaruMusicStop" -Value 1 -Type DWord -Force
	Stop-Process -Name "FFPlay" -Force -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:SYSTEMDRIVE\Bionic\WinXShell" -Recurse -Force
	exit
}
function Restart-UpdateMode {
	Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Wureboot" -Value 1 -Type DWord -Force
	Start-Process powershell -Wait -ArgumentList "-Command $coredir\support\hikancel.ps1"
	$hkbrb = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").Wureboot
	if ($hkbrb -eq 0) {
		Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Restarting to finish installing updates"
		Start-Sleep -Seconds 2
		Restart-System
	} else {
		Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Wureboot" -Value 0 -Type DWord -Force
		Stop-UpdateMode "Success"
	}
}
function Show-StuckHelp {
	if ($targetcheck -eq 1 -and $edition -notmatch "Core" -and $build -ge 17134 -and $wupdated -ne 1) {} else {return}
	Show-Branding
	Write-Host "If you got stuck at a Feature Update, try the following fix:" -ForegroundColor Black -BackgroundColor Yellow
	Write-Host "- Start Windows Update mode with Wumgr (option 2) or open Task Manager"  -ForegroundColor White
	Write-Host "- Open Registry Editor via the Run dialog like usual and nagivate to"  -ForegroundColor White
	Write-Host "  HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ForegroundColor Cyan
	Write-Host "- Change value"  -ForegroundColor White -n; Write-Host ' "TargetReleaseVersionInfo" ' -ForegroundColor Cyan -n; Write-Host "to an older version" -ForegroundColor White
	Write-Host "  (say if it's 2004, change it to 1909)"
	Write-Host "- Then, switch value"  -ForegroundColor White -n; Write-Host ' "TargetReleaseVersion" ' -ForegroundColor Cyan -n; Write-Host "to 0" -ForegroundColor White
	Write-Host "- After that, via Run, open a Command Prompt and type " -ForegroundColor White -n; Write-Host '"powershell Restart-Service -Name wuauserv"' -ForegroundColor Cyan
	Write-Host "- Switch value" -n -ForegroundColor White; Write-Host ' "TargetReleaseVersion" ' -ForegroundColor Cyan -n; Write-Host "back to 1" -ForegroundColor White
	Write-Host "- Run the restart service command again"  -ForegroundColor White
	Write-Host "- Finally check for updates in Wumgr. If update shows and it's not a Feature Update, you fixed it!" -ForegroundColor White
	Write-Host "- If the problem can't still be solved, try repeating from step 4 again. And if it still does no extra damage," -ForegroundColor White
	Write-Host "  your only choice then is to give Microsoft a middle finger, and abort WU mode." -ForegroundColor White
	Write-Host "`r`nPress Enter to return."; Read-Host
}

Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "Wucancel" -Value 1 -Type DWord -Force
Start-Process powershell -Wait -ArgumentList "-Command $coredir\support\hikancel.ps1"
$hkc = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").Wucancel

while($true) {
	if ($hkc -eq 1) {Show-Menu}
	Write-Host "> " -n ; if ($hkc -eq 1) {$hkchoice = Read-Host} else {$hkchoice = "4"}
	if ($hkc -eq 1 -and $hkchoice -ne "3") {Show-Confirm}
	if ($wupdated -eq 1) {
		switch ($hkchoice) {
			"1" {Start-UpdateMode}
			"2" {Start-UpdateMode "Wumgr"}
			"3" {Show-StuckHelp}
			default {if ($hkc -eq 0) {Show-Branding}; Stop-UpdateMode "Success"}
		}
	} else {
		switch ($hkchoice) {
			default {if ($hkc -eq 0) {Show-Branding}; Start-UpdateMode}
			"2" {Start-UpdateMode "Wumgr"}
			"3" {Show-StuckHelp}
			{$_ -like "r"} {Stop-UpdateMode "Aborted"}
		}
	}
}
