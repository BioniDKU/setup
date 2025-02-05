# BioniDKU main menu (2nd-generation) - The thing that appears on first run of the script
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

# Branding, directory and information stuffs
function Show-Branding($clr) {
	if ($clr -like "clear") {Clear-Host}
	Write-Host 'Project BioniDKU - Next Generation AutoIDKU' -ForegroundColor White -BackgroundColor Blue
	Write-Host "$releasetype - $butter" -ForegroundColor Black -BackgroundColor White
	Write-Host " "
}
function Show-WelcomeText {
	Show-Branding clear
	Write-OSInfo
	Write-Host -ForegroundColor Magenta "Welcome to BioniDKU!"; Write-Host " "
}

$global:releasetype = (Get-ItemProperty -Path "HKCU:\Software\BioniDKU").ReleaseType
$global:butter = (Get-ItemProperty -Path "HKCU:\Software\BioniDKU").ReleaseIDEx
$global:pwsh = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").Pwsh
$global:workdir = Split-Path(Split-Path "$PSScriptRoot")
$global:coredir = Split-Path "$PSScriptRoot"
$global:datadir = "$workdir\data"

. $coredir\kernel\osinfo.ps1
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Ambient.psm1
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Support.psm1
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Windowing.psm1

# Menu functions - Switches modifiers
function Show-Disenabled($regvalue,$type) {
	# Displays the state of a registry switch value, designed to be printed after a Write-Host -n
	$regreturns = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU${type}").$regvalue
	if ($regreturns -eq 1) {
		Write-Host -ForegroundColor Green " (ENABLED)"
	} else {
		Write-Host -ForegroundColor Red " (DISABLED)"
	}
}
function Select-Disenabled($regvalue,$type) {
	# Upon invoking, switches the desired value to the opposite state
	$regreturns = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU${type}").$regvalue
	if ($regreturns -eq 1) {
		Set-ItemProperty -Path "HKCU:\Software\AutoIDKU${type}" -Name $regvalue -Value 0 -Type DWord -Force
	} else {
		Set-ItemProperty -Path "HKCU:\Software\AutoIDKU${type}" -Name $regvalue -Value 1 -Type DWord -Force
	}
}

# Menu functions - System checkers
function Check-Defender {
	$notdctrled = Get-Process MsMpEng -ErrorAction SilentlyContinue
	if ($notdctrled) {
		return $false
	} else {return $true}
}
function Check-EnoughActions {
	switch ($true) {
		{$essentialapps -eq 1} {}
		$removeUWPapps {}
		$registrytweaks {}
		$removesystemapps {}
		default {
			return $false
		}
	}
	return $true
}
function Check-SafeLocation {if ($workdir -like "$env:USERPROFILE\Downloads*" -and $removedownloads) {return $false} else {return $true}}

# Menu functions - Text displays
function Confirm-DeleteDownloads {
	$dlhasfiles = Test-Path -Path "$env:USERPROFILE\Downloads\*"
	if ($removedownloads -and $dlhasfiles) {} else {return $true}
	Write-Host -ForegroundColor Black -BackgroundColor Red "HOLD UP"
	Write-Host " "
	Write-Host -ForegroundColor Red 'You have selected to DELETE your Downloads folder during the operation. The script has deteced that you have files in this folder. Please back up anything necessary before proceeding any further.'
	Write-Host 'If you do not want Downloads to get deleted, answer anything else except YES to go back, select 3 then 1 to reconfigure the script and set the' -n; Write-Host -ForegroundColor Cyan ' "Remove Downloads folder" ' -n; Write-Host 'switch to FALSE under the' -n; Write-Host -ForegroundColor Green ' "ADVANCED SCRIPT CONFIGURATION: Registry Switches" ' -n; Write-Host 'section.'
	Write-Host " "
	Write-Host -ForegroundColor Black -BackgroundColor Red "THIS IS YOUR LAST WARNING!!!" 
	Write-Host -ForegroundColor Cyan "If you are sure and want to proceed, answer `"DELETE`"."
	Write-Host "> " -n ; $deload = Read-Host
	switch ($deload) {
		{$deload -like "delete"} {return $true}
		default {return $false}
	}
}
function Confirm-Starting {
	Write-Host -ForegroundColor Black -BackgroundColor Yellow "Are sure you want to start?"
	Write-Host -ForegroundColor Yellow "Once started, there is NO turning back! If you are ready, answer `"1`" once again."
	Write-Host -ForegroundColor Red "UAC will be disabled immediately once you start the script."
	
	Write-Host "> " -n ; $startfirm = Read-Host
	switch ($startfirm) {
		{$startfirm -like "1"} {return $true}
		default {return $false}
	}
}
function Show-StartAllowed {
	$snareason1 = " - You did not select enough options in to proceed. Try selecting a few more options, and try again."
	$snareason2 = " - Windows Defender is currently active. Please disable it (using dControl) and try again."
	$snareason3 = " - The script folder is currently being placed inside your Downloads folder.`r`n   Either move it to somewhere else or disable Downloads folder removal in Advanced configuration menu (Main menu action 3)."

	if (-not (Check-EnoughActions) -or -not (Check-Defender) -or -not (Check-SafeLocation)) {
		$stcolor = "DarkGray"; $global:startallowed = $false
		Write-Host "DENIED:" -ForegroundColor Black -BackgroundColor Red -n; Write-Host -ForegroundColor Red " Starting the script is currently not allowed due to the following reasons:"
		switch ($true) {
			{-not (Check-EnoughActions)} {Write-Host $snareason1}
			{-not (Check-Defender)} {Write-Host $snareason2}
			{-not (Check-SafeLocation)} {Write-Host $snareason3}
		}
		Write-Host " "
	} else {$stcolor = "White"; $global:startallowed = $true}

	return $stcolor
}
function Show-Notice {
	$increasewait = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").RunningThisRemotely
	$ngawarn = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").NotGABuild

	if ($increasewait -eq 1 -or $ngawarn -eq 1) {
		Write-Host "NOTE:" -ForegroundColor Black -BackgroundColor Yellow
		switch (1) {
			$increasewait {Write-Host " - Increase wait time is enabled. The script will wait 30 seconds on every system restart before continuing`r`n   or until you press CTRL+C.`r`n   You can toggle this option in the Script configuration menu (Main menu action 2)." -ForegroundColor Yellow}
			$ngawarn {Write-Host " - Non-General Availability (or Insider) build detected.`r`n   Stability might suffer and I will not be providing support for issues related to these builds.`r`n   Proceed at your own risk." -ForegroundColor Yellow}
		}
		Write-Host " "
	}
}
function Show-MenuText($item) {
	switch ($item) {
		"main" {
			Show-WelcomeText
			$stcolor = Show-StartAllowed
			Show-Notice
			Write-Host -ForegroundColor Yellow " What do you want to do?"
			Write-Host -ForegroundColor $stcolor " 1. Start the script"
			Write-Host -ForegroundColor White " 2. Configure the script"
			Write-Host -ForegroundColor White " 3. Further adjust the script (advanced)"
			Write-Host -ForegroundColor White " 4. Show credits"
			Write-Host -ForegroundColor White " R. Exit this script`r`n"
		}
		"confign" {
			Show-Branding clear
			$setupmusic = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").HikaruMusic
			$essentialapps = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").EssentialApps
			if ($build -eq 10240 -and $disablelogonbg) {$wucolor = "DarkGray"} else {$wucolor = "White"}
			Write-Host -ForegroundColor Yellow "`Configure the script by tuning the following options to your desire."
			Write-Host -ForegroundColor $wucolor " 1. Toggle Windows Update mode" -n; if ($build -eq 10240 -and $disablelogonbg) {Write-Host " (FORCEFULLY ENABLED)" -ForegroundColor DarkGray} else {Show-Disenabled WUmodeSwitch}
			Write-Host -ForegroundColor White " 2. Keep System Restore enabled" -n; Show-Disenabled KeepSR
			Write-Host -ForegroundColor White " 3. Set desktop wallpaper to the one from the script" -n; Show-Disenabled SetWallpaper
			Write-Host -ForegroundColor White " 4. Increase wait time (ideal for remote setups)" -n; Show-Disenabled RunningThisRemotely
			Write-Host -ForegroundColor White " 5. Toggle background music" -n; Show-Disenabled HikaruMusic
			if ($setupmusic -eq 1) {Write-Host -ForegroundColor White " 6. Customize your music selection"}
			Write-Host -ForegroundColor White " 7. Toggle the installation of Essential Apps" -n; Show-Disenabled EssentialApps
			if ($essentialapps -eq 1) {Write-Host -ForegroundColor White " 8. Customize which Apps to install"}
			Write-Host -ForegroundColor White " 9. Toggle logging for troubleshooting purposes" -n; Show-Disenabled Transcribe
			Write-Host -ForegroundColor White " R. Accept the current configuration and return to main menu`r`n"
		}
		"configa" {
			Show-ModulesConfig # This can be found at the very bottom of config.ps1
			Write-Host -ForegroundColor Yellow "`r`nThen, select the following actions:"
			Write-Host -ForegroundColor White " 1. Open the script in Notepad to reconfigure the options,"
			Write-Host -ForegroundColor White "    it will wait for you and refresh once you close Notepad"
			Write-Host -ForegroundColor White " R. Accept the current configuration and return to main menu" -n; Write-Host " (Default answer)`r`n"
		}
	}
}
# Menu functions - Support functions
function Reset-Script {
	Write-Host -ForegroundColor Yellow "`r`nDo you want to clean up what the script created (basically resetting it)? (Yes)"

	Write-Host "> " -n ; $resetfirm = Read-Host
	switch ($resetfirm) {
		{$resetfirm -like "yes"} {Remove-Item $datadir -Force -Recurse; Remove-Item HKCU:\Software\AutoIDKU -Recurse; Remove-Item HKCU:\Software\BioniDKU -Recurse; exit}
		default {exit}
	}
}

# Now to the main part - the main menu loop
Show-WindowTitle 0
while ($true) {
	. $coredir\kernel\config.ps1
	Show-MenuText "main"
	Write-Host "> " -n ; $menusel = Read-Host
	
	switch ($menusel) {
		"1" {
			Write-Host " "
			if (-not $startallowed) {continue}
			$dldelete = Confirm-DeleteDownloads; if (-not $dldelete) {continue}
			$startconfirm = Confirm-Starting; if (-not $startconfirm) {continue}
			Write-Host " "; Play-Ambient 1
			Write-Host -ForegroundColor Black -BackgroundColor Green "Alright, starting the script..."
			Start-Sleep -Seconds 5
			& $coredir\support\getready.ps1
		}
		"2" {
			$menuselsub = 2
			while ($menuselsub -eq 2) {
				Show-MenuText "confign"
				Write-Host "> " -n ; $confignsel = Read-Host
				$setupmusic = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").HikaruMusic
				$essentialapps = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU").EssentialApps
				switch ($confignsel) {
					"1" {if ($build -eq 10240 -and $disablelogonbg) {exit} else {Select-Disenabled WUmodeSwitch}}
					"2" {Select-Disenabled KeepSR}
					"3" {Select-Disenabled SetWallpaper}
					"4" {Select-Disenabled RunningThisRemotely}
					"5" {Select-Disenabled HikaruMusic}
					"6" {if ($setupmusic -eq 1) {& $coredir\music\musicpicker.ps1}}
					"7" {Select-Disenabled EssentialApps}
					"8" {if ($essentialapps -eq 1) {& $coredir\support\appspicker.ps1}}
					"9" {Select-Disenabled Transcribe}
					{$_ -like "r"} {$menuselsub = 0}
				}
			}
		}
		"3" {
			$menuselsub = 3
			Set-WindowState -State MAXIMIZE -MainWindowHandle (Get-Process -Id $cpid).MainWindowHandle
			while ($menuselsub -eq 3) {
				Show-MenuText "configa"
				Write-Host "> " -n ; $configasel = Read-Host
				switch ($configasel) {
					"1" {
						Write-Host -ForegroundColor Cyan "Now opening $PSScriptRoot\config.ps1 in Notepad"
						Write-Host -ForegroundColor Cyan "Once you close Notepad, this screen will refresh with your changes"
						Start-Process notepad.exe -Wait -NoNewWindow -ArgumentList "$PSScriptRoot\config.ps1"
						. $coredir\kernel\config.ps1
					}
					{$_ -like "r"} {$menuselsub = 0}
				}
			}
			Set-WindowState -State RESTORE -MainWindowHandle (Get-Process -Id $cpid).MainWindowHandle
		}
		"4" {
			Set-WindowState -State MAXIMIZE -MainWindowHandle (Get-Process -Id $cpid).MainWindowHandle
			& $PSScriptRoot\credits.ps1
			Set-WindowState -State RESTORE -MainWindowHandle (Get-Process -Id $cpid).MainWindowHandle
		}
		{$_ -like "r"} {Set-ItemProperty -Path "HKCU:\Software\AutoIDKU" -Name "RebootScript" -Value 0 -Type DWord -Force; Reset-Script}
	}
}
