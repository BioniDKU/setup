# BioniDKU Hikaru installer - (c) Bionic Butter
# This gets executed at the very end of script execution, installs Hikaru and other remaining dependencies

function Start-NSSM($command) {Start-Process $env:SYSTEMDRIVE\Bionic\Kirisame\nssm.exe -Wait -WindowStyle Hidden -ArgumentList "$command"}; Set-Alias -Name nssm -Value Start-NSSM

Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Installing PowerShell 7"
Start-Process msiexec -Wait -ArgumentList "/package $datadir\dls\core7.msi /qr /norestart ADD_PATH=1 DISABLE_TELEMETRY=1 USE_MU=0 ENABLE_MU=0"
if ($build -ge 18362) {
	Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Installing ContextMenuNormalizer"
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "ContextMenuNormalizer" -Value "$env:SYSTEMDRIVE\Bionic\Hikaru\ContextMenuNormalizer.exe" -Type String -Force
}
$OpenShell = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU\Apps").OpenShell
if ($OpenShell -eq 1) {Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "TaskbarOpacity" -Value 80 -Type DWord -Force}

Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Installing Custom System Sounds"
Expand-Archive -Path $datadir\utils\Media9200.zip -DestinationPath $env:SYSTEMDRIVE\Windows\Media\Blue
Expand-Archive -Path $datadir\utils\Media1k74.zip -DestinationPath $env:SYSTEMDRIVE\Windows\Media\Threshold

# Install Hikaru and its services 
Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Installing BioniDKU Menus System"
Copy-Item -Path $env:SYSTEMDRIVE\Windows\System32\ApplicationFrameHost.exe -Destination "$env:SYSTEMDRIVE\Bionic\Hikaru\ApplicationFrameHost.QUARANTINE"
taskkill /f /im ApplicationFrameHost.exe
takeown /f "$env:SYSTEMDRIVE\Windows\System32\ApplicationFrameHost.exe"
icacls "$env:SYSTEMDRIVE\Windows\System32\ApplicationFrameHost.exe" /grant Administrators:F

$nssmlist = @(
	"install HikaruQMLd $env:SYSTEMDRIVE\Bionic\Hikaru\HikaruQMLd.exe",
	"set HikaruQMLd DisplayName `"BioniDKU Menus System Helper Service`"",
	"set HikaruQMLd Description `"This service helps the Hikaru tray app survive in case of Task Scheduler's automatic killing mechanism.`"",
	"set HikaruQMLd Start SERVICE_AUTO_START",
	"set HikaruQMLd Type SERVICE_WIN32_OWN_PROCESS",
	"set HikaruQMLd AppExit Default Ignore"
)
$nssmn = 1; foreach ($nssmc in $nssmlist) {
	Write-Progress -PercentComplete (($nssmn/$nssmlist.count)*100) -Activity "Installing BioniDKU Menus System Tray support service" -Status " "
	nssm $nssmc; $nssmn++
}
Write-Progress -Completed -Activity "Installing BioniDKU Menus System Tray support service"
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'HikaruQMLu' -Value "$env:SYSTEMDRIVE\Bionic\Hikaru\HikaruQMLu.exe" -Type String -Force

if ($build -eq 10586) {mofcomp $env:SYSTEMDRIVE\Windows\System32\wbem\SchedProv.mof} # 1511 broken Task Scheduler workaround
$hkF5name = 'BioniDKU Menus System Update Checker'
$hkF5action = New-ScheduledTaskAction -Execute "%SystemDrive%\Bionic\Hikarefresh\Hikarefresh.exe"
$hkF5trigger = @(
	$(New-ScheduledTaskTrigger -AtLogon),
	$(New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At 8am)
)
$hkF5settings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
$hkF5 = New-ScheduledTask -Action $hkF5action -Trigger $hkF5trigger -Settings $hkF5settings
Register-ScheduledTask -TaskName $hkF5name -TaskPath '\BioniDKU\' -InputObject $hkF5

$hkqmlname = "BioniDKU Menus System Hot Keys Service"
$hkqmltrigger = @($(New-ScheduledTaskTrigger -AtLogon -User "$env:COMPUTERNAME\$env:USERNAME"))
Register-ScheduledTask -xml (Get-Content "$env:SYSTEMDRIVE\Bionic\Hikaru\HikaruQML.xml" | Out-String) -TaskName $hkqmlname -TaskPath '\BioniDKU\' -User "$env:COMPUTERNAME\$env:USERNAME" -Force
Set-ScheduledTask -TaskName $hkqmlname -TaskPath '\BioniDKU\' -Trigger $hkqmltrigger

$hkbpstname = 'BioniDKU Windows Build String Modifier'
$hkbpaction = New-ScheduledTaskAction -Execute "%SystemDrive%\Bionic\Hikaru\HikaruBuildMod.exe"
$hkbprincipal = New-ScheduledTaskPrincipal -UserID "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$hkbpsettings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable -ExecutionTimeLimit 0 -MultipleInstances IgnoreNew
$hkbp = New-ScheduledTask -Action $hkbpaction -Principal $hkbprincipal -Settings $hkbpsettings
Register-ScheduledTask -TaskName $hkbpstname -TaskPath '\BioniDKU\' -InputObject $hkbp

$hklcstname = 'BioniDKU UWP Lockdown Controller'
$hklcaction = New-ScheduledTaskAction -Execute "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-Command `"& %SystemDrive%\Bionic\Hikaru\ApplicationControlHost.ps1`""
$hklcrincipal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$hklc = New-ScheduledTask -Action $hklcaction -Principal $hklcrincipal -Settings $hkbpsettings
Register-ScheduledTask -TaskName $hklcstname -TaskPath '\BioniDKU\' -InputObject $hklc

# Allow non-elevated processes to execute the task that would otherwise require elevation to start
# From: https://www.osdeploy.com/blog/2021/scheduled-tasks/task-permissions
$Scheduler = New-Object -ComObject "Schedule.Service"; $Scheduler.Connect() 
$hket = $hkF5name, $hkqmlname, $hkbpstname, $hklcstname
foreach ($hketname in $hket) {
	$GetTask = $Scheduler.GetFolder('\BioniDKU').GetTask($hketname)
	$GetSecurityDescriptor = $GetTask.GetSecurityDescriptor(0xF)
	if ($GetSecurityDescriptor -notmatch 'A;;0x1200a9;;;AU') {
		$GetSecurityDescriptor = $GetSecurityDescriptor + '(A;;GRGX;;;AU)'
		$GetTask.SetSecurityDescriptor($GetSecurityDescriptor, 0)
	}
}
$pacl = Get-Acl "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$pule = New-Object System.Security.AccessControl.RegistryAccessRule ("$env:USERNAME","FullControl",@("ObjectInherit","ContainerInherit"),"None","Allow")
$pacl.SetAccessRule($pule)
$pacl | Set-Acl -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"

# Pre-apply system restrictions (set restrictions but at disabled state)
Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Configuring BioniDKU Menus System and related services"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name DisallowRun -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoControlPanel -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoTrayContextMenu -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData" -Name AllowLockScreen -Value 0 -Type DWord
reg import "$env:SYSTEMDRIVE\Bionic\Hikaru\Hikarestrict.reg"
$cmd = Test-Path -Path "HKCU:\Software\Microsoft\Command Processor"
if ($cmd -eq $false) {
	New-Item -Path "HKCU:\Software\Microsoft" -Name "Command Processor"
}
reg import "$env:SYSTEMDRIVE\Bionic\Hikaru\ShellHikaru.reg"

# Create shortcut for HikaruQML
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$hkQML = "$env:SYSTEMDRIVE\Bionic\Hikaru\HikaruQMLh.exe"
$hkQMLS = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\BioniDKU Menus System Tray.lnk"
$hkQMLSh = $WscriptObj.CreateShortcut($hkQMLS)
$hkQMLSh.TargetPath = $hkQML
$hkQMLSh.Save()

$hkreg = Test-Path -Path 'HKCU:\SOFTWARE\Hikaru-chan'
if ($hkreg -eq $false) {
	New-Item -Path 'HKCU:\SOFTWARE' -Name Hikaru-chan
}
Set-ItemProperty -Path "HKCU:\Software\Hikaru-chan" -Name "ProductName" -Value "BioniDKU" -Type String -Force
Set-ItemProperty -Path "HKCU:\Software\Hikaru-chan" -Name "StartupSoundVariant" -Value 1 -Type DWord -Force
if ($customsounds) {$sar = 1} else {$sar = 3}
Set-ItemProperty -Path "HKCU:\Software\Hikaru-chan" -Name "SystemSoundVariant" -Value $sar -Type DWord -Force
if ($pwsh -eq 7) {
	$hkrbuildog = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").BuildLab
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "BuildLabOg" -Value $hkrbuildog -Type String -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "BuildLabOSE" -Value "1????.????_release.??????-????" -Type String -Force

# Hikarun on-demand customization section
if ($hidetaskbaricons -and $build -ge 18362) {
	$hkrdockico = 
@"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideSCAMeetNow /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v IsFeedsAvailable /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f
"@
} else {$hkrdockico = ""}

# Write the customized values to the on-demand batch file
@"
@echo off
rem ####### Hikaru-chan by Bionic Butter #######

$hkrdockico
"@ | Out-File -FilePath "$env:SYSTEMDRIVE\Bionic\Hikaru\Hikarun.bat" -Encoding ascii

# Lastly, reenable UAC if it's a GA build
if ($keepuac -and $ngawarn -ne 1) {Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -Value 1 -Force}
