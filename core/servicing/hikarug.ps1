# BioniDKU Hikaru fetchter - (c) Bionic Butter
# This module gets the core components required for the script to start properly, part of Nana the bootloader

Param(
	[Parameter(Mandatory=$True,Position=0)]
	[int32]$action
)
function Start-DownloadLoop($link,$destfile,$name,$descr) {
	while ($true) {
		Start-BitsTransfer -DisplayName "$name" -Description "$descr" -Source $link -Destination $datadir\dls\$destfile -RetryInterval 60 -RetryTimeout 70 -ErrorAction SilentlyContinue
		if (Test-Path -Path "$datadir\dls\$destfile" -PathType Leaf) {break} else {
			Write-Host " "
			Write-Host -ForegroundColor Black -BackgroundColor Red "Ehhhhhhh"
			Write-Host -ForegroundColor Red "Did the transfer fail?" -n; Write-Host " Retrying..."
			Start-Sleep -Seconds 1
		}
	}
}
Import-Module BitsTransfer

switch ($action) {
	0 {
		$host.UI.RawUI.WindowTitle = "Project BioniDKU - (c) Bionic Butter | Getting critical components... | DO NOT CLOSE THIS WINDOW OR DISCONNECT INTERNET"
		Clear-Host
		Write-Host 'Project BioniDKU - Next Generation AutoIDKU' -ForegroundColor White -BackgroundColor Blue
		Write-Host "Getting critical components..." -ForegroundColor Blue -BackgroundColor Gray
		Write-Host " "
		
		$global:workdir = Split-Path(Split-Path "$PSScriptRoot")
		$global:coredir = Split-Path "$PSScriptRoot"
		$global:datadir = "$workdir\data"
		
		Start-DownloadLoop "https://github.com/BioniDKU/resources/raw/main/bootstrap/ambient.zip" "ambient.zip" "Getting ambient sounds package" " "
		Expand-Archive -Path $datadir\dls\ambient.zip -DestinationPath $datadir\ambient
	}
	1 {
		$hexists = Test-Path -Path "$datadir\dls\sakuraground.png" -PathType Leaf
		if ($hexists) {exit}

		$hikalink = "latest/download"
		
		Start-DownloadLoop "https://github.com/BioniDKU/hikaru/releases/${hikalink}/Scripts.7z" "Scripts.7z" "Getting BioniDKU Menus System files" "Downloading scripts layer"
		Start-DownloadLoop "https://github.com/BioniDKU/hikaru/releases/${hikalink}/Resources.7z" "Resources.7z" "Getting BioniDKU Menus System files" "Downloading resources layer"
		Start-DownloadLoop "https://github.com/BioniDKU/hikaru/releases/${hikalink}/Servicer.7z" "Servicer.7z" "Getting BioniDKU Menus System files" "Downloading servicing layer"
		Start-DownloadLoop "https://github.com/BioniDKU/hikaru/releases/${hikalink}/Versinfo.ps1" "VersinFOLD.ps1" "Getting BioniDKU Menus System files" "Downloading release information file"
		Start-DownloadLoop "https://github.com/BioniDKU/resources/raw/main/bootstrap/background.png" "background.png" "Getting desktop background image" " "
		Start-DownloadLoop "https://github.com/BioniDKU/resources/raw/main/bootstrap/sakuraground.png" "sakuraground.png" "Getting desktop background image" " "
		
		if ((Test-Path -Path "$env:SYSTEMDRIVE\Bionic") -eq $false) {New-Item -Path "$env:SYSTEMDRIVE\" -Name Bionic -itemType Directory | Out-Null}
		Start-Process $coredir\7z\7za.exe -Wait -NoNewWindow -ArgumentList "x $datadir\dls\Scripts.7z -pBioniDKU -o$env:SYSTEMDRIVE\Bionic"
		Start-Process $coredir\7z\7za.exe -Wait -NoNewWindow -ArgumentList "x $datadir\dls\Resources.7z -pBioniDKU -o$env:SYSTEMDRIVE\Bionic"
		Start-Process $coredir\7z\7za.exe -Wait -NoNewWindow -ArgumentList "x $datadir\dls\Servicer.7z -pBioniDKU -o$env:SYSTEMDRIVE\Bionic"
		Start-Process $env:SYSTEMDRIVE\Bionic\Hikarefresh\wget.exe -Wait -NoNewWindow -ArgumentList "https://github.com/BioniDKU/hikaru/releases/latest/download/Servicinfo.ps1 -O ServicinFOLD.ps1" -WorkingDirectory "$env:SYSTEMDRIVE\Bionic\Hikarefresh"
		Show-WindowTitle 1 "Getting ready" noclose
		. $datadir\dls\VersinFOLD.ps1
		New-Item -Path 'HKCU:\SOFTWARE' -Name Hikaru-chan
		Set-ItemProperty -Path "HKCU:\Software\Hikaru-chan" -Name "Version" -Value "22110.$version" -Force
	}
}
