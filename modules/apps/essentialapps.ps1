Write-Host "Installing required programs" -ForegroundColor Cyan -BackgroundColor DarkGray -n; Write-Host ([char]0xA0)
Write-Host -ForegroundColor Cyan "The following programs will be installed:"
Write-Host -ForegroundColor Cyan "- Winaero Tweaker" #dl1
Write-Host -ForegroundColor Cyan "- Open-Shell" -n; Write-Host " (4.4.170)" #dl2
Write-Host -ForegroundColor Cyan "- T-Clock" -n; Write-Host " (2.4.4)" #dl4
Write-Host -ForegroundColor Cyan "- PENetwork Manager" -n; Write-Host " (Hi Julia)" #dl5 but built-in, so no dl
Write-Host -ForegroundColor Cyan "- Mozilla Firefox ESR" #dl6
#Write-Host -ForegroundColor Cyan "- VideoLan VLC" -n; Write-Host " (3.0.18)" #dl7
Write-Host -ForegroundColor Cyan "- Notepad++" -n; Write-Host " (8.5, Hi Zach)" #dl8
Write-Host -ForegroundColor Cyan "- ShareX (13.1.0)" #dl9
Write-Host -ForegroundColor Cyan "- Paint.NET (4.0.19)" #dl10 but same as dl5
Write-Host -ForegroundColor Cyan "- Classic Task Manager & Classic System Configuration" #dl11 but same as dl5
Write-Host -ForegroundColor Cyan "- DesktopInfo (3.10.1, with custom configuration)"
Write-Host "Some of these might not be on their latest releases. You can update them on your own later."

# Download links
$dl1 = "https://winaerotweaker.com/download/winaerotweaker.zip"
$dl2 = "https://github.com/Open-Shell/Open-Shell-Menu/releases/download/v4.4.170/OpenShellSetup_4_4_170.exe"
$dl4 = "https://github.com/White-Tiger/T-Clock/releases/download/v2.4.4%23492-rc/T-Clock.zip"
$dl6 = "https://download.mozilla.org/?product=firefox-esr-latest&os=win64&lang=en-US"
$dl7 = "http://download.videolan.org/pub/videolan/vlc/3.0.18/win64/vlc-3.0.18-win64.exe"
$dl8 = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5/npp.8.5.Installer.x64.exe"
$dl9 = "https://github.com/ShareX/ShareX/releases/download/v13.1.0/ShareX-13.1.0-setup.exe"

# Create downloads folder
$dlfe = Test-Path -Path "$workdir\dls"
if ($dlfe -eq $false) {
	New-Item -Path $workdir -Name dls -itemType Directory | Out-Null
}

# Download'em all
Start-BitsTransfer -Source $dl1 -Destination $workdir\dls\winaero.zip -RetryInterval 60
Start-BitsTransfer -Source $dl2 -Destination $workdir\dls\openshellinstaller.exe -RetryInterval 60
Start-BitsTransfer -Source $dl4 -Destination $workdir\dls\tclock.zip -RetryInterval 60
Start-BitsTransfer -Source $dl6 -Destination $workdir\dls\firefoxesr.exe -RetryInterval 60
#Start-BitsTransfer -Source $dl7 -Destination $workdir\dls\vlc.exe -RetryInterval 60
Start-BitsTransfer -Source $dl8 -Destination $workdir\dls\npp.exe -RetryInterval 60
Start-BitsTransfer -Source $dl9 -Destination $workdir\dls\sharex462.exe -RetryInterval 60
Write-Host -ForegroundColor Cyan "Download complete. Proceeding to install"

# Install zip-based installers
$deskinfo = "$env:SYSTEMDRIVE\Program Files\DesktopInfo"
New-Item -Path $env:USERPROFILE -Name "tclock" -ItemType Directory
Expand-Archive -Path $workdir\dls\winaero.zip -DestinationPath $workdir\dls
Expand-Archive -Path $workdir\dls\tclock.zip -DestinationPath $env:USERPROFILE\tclock
Expand-Archive -Path $workdir\utils\penm.zip -DestinationPath "$env:SYSTEMDRIVE\Windows\PENetwork"
Expand-Archive -Path $workdir\utils\DesktopInfo.zip -DestinationPath $deskinfo
Copy-Item -Path $workdir\utils\PENetwork.lnk -Destination "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\PENetwork.lnk"
$waxe = (Get-ChildItem -Path $workdir\dls -Filter WinaeroTweaker*.exe)

# Install exe-based installers
Start-Process "$workdir\dls\$waxe" -Wait -NoNewWindow -ArgumentList "/SP- /VERYSILENT"
Start-Process $workdir\dls\firefoxesr.exe -Wait -NoNewWindow -ArgumentList "/S /PrivateBrowsingShortcut=false /PreventRebootRequired=true /TaskbarShortcut=false"
#Start-Process $workdir\dls\vlc.exe -Wait -NoNewWindow -ArgumentList "/L=1033 /S"
Start-Process $workdir\dls\npp.exe -Wait -NoNewWindow -ArgumentList "/S"
Start-Process $workdir\dls\sharex462.exe -Wait -NoNewWindow -ArgumentList "/VERYSILENT /NORUN"
Start-Process $workdir\utils\paintdotnet462.exe -NoNewWindow -Wait -ArgumentList "/AUTO"
Expand-Archive -Path $workdir\utils\tm_cfg_win8-win10.zip -DestinationPath $workdir\dls
Start-Process $workdir\dls\tm_cfg_win8-win10.exe -NoNewWindow -Wait -ArgumentList "/SILENT"


# Preconfigure some programs
reg.exe import $workdir\utils\PENM.reg
Start-Process C:\Windows\PENetwork\PENetwork.exe

reg.exe import $workdir\utils\tclock.reg
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$tclock = "$env:USERPROFILE\tclock\Clock64.exe"
$ShortcutPath1 = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\tclock.lnk"
$shortcut1 = $WscriptObj.CreateShortcut($ShortcutPath1)
$shortcut1.TargetPath = $tclock
$shortcut1.WindowStyle = 1
$shortcut1.Save()

$ShortcutPath2 = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\DesktopInfo.lnk"
$shortcut2 = $WscriptObj.CreateShortcut($ShortcutPath2)
$shortcut2.TargetPath = "$deskinfo\DesktopInfo.exe"
$shortcut2.Save()
Copy-Item -Force -Path $deskinfo\Convection\Conv.ttf -Destination C:\Windows\Fonts\Conv.ttf
Copy-Item -Force -Path $deskinfo\Convection\Convb.ttf -Destination C:\Windows\Fonts\Convb.ttf
Copy-Item -Force -Path $deskinfo\Convection\Convc.ttf -Destination C:\Windows\Fonts\Convc.ttf
Copy-Item -Force -Path $deskinfo\Convection\Convexb.ttf -Destination C:\Windows\Fonts\Convexb.ttf
Copy-Item -Force -Path $deskinfo\Convection\Convit.ttf -Destination C:\Windows\Fonts\Convit.ttf
Copy-Item -Force -Path $deskinfo\Convection\Convmd.ttf -Destination C:\Windows\Fonts\Convmd.ttf
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Convection (TrueType)" -Value "Conv.ttf" -Type String -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Convection Bold (TrueType)" -Value "Convb.ttf" -Type String -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Convection Condensed (TrueType)" -Value "Convc.ttf" -Type String -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Convection Extra Bold (TrueType)" -Value "Convexb.ttf" -Type String -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Convection Italic (TrueType)" -Value "Convit.ttf" -Type String -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Convection Medium (TrueType)" -Value "Convmd.ttf" -Type String -Force

$sxnou = Test-Path -Path "$env:USERPROFILE\Documents\ShareX"
if ($sxnou -eq $false) {
	New-Item -Path "$env:USERPROFILE\Documents" -Name ShareX -itemType Directory
}
Copy-Item -Path $workdir\utils\ApplicationConfig.json -Destination "$env:USERPROFILE\Documents\ShareX\ApplicationConfig.json"
