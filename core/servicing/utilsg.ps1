# This module gets the utilities package of the script.

$global:workdir = Split-Path(Split-Path "$PSScriptRoot")
$global:coredir = Split-Path "$PSScriptRoot"
$global:datadir = "$workdir\data"
if (-not (Test-Path -Path "$datadir\utils")) {New-Item -Path $datadir -Name "utils" -itemType Directory | Out-Null}

$host.UI.RawUI.WindowTitle = "Project BioniDKU - (c) Bionic Butter | Utilites fetcher module - DO NOT CLOSE THIS WINDOW"
$uexists = Test-Path -Path "$datadir\utils\WinXShell.zip" -PathType Leaf
if ($uexists) {exit}

function Show-Branding {
	Clear-Host
	Write-Host 'Project BioniDKU - Next Generation AutoIDKU' -ForegroundColor White -BackgroundColor Blue
	Write-Host "Utilites fetcher module" -ForegroundColor Blue -BackgroundColor Gray
	Write-Host " "
}
Show-Branding
Import-Module BitsTransfer

# IMPORTANT SECTION
$utag = "301_b1"
$unum = 2

for ($u = 1; $u -le $unum; $u++) {
	while ($true) {
		Start-BitsTransfer -DisplayName "Getting the Utilites package" -Description "Downloading file $u out of $unum" -Source "https://github.com/Bionic-OSE/BioniDKU-utils/releases/download/$utag/utils.7z.00$u" -Destination $datadir\utils -RetryInterval 60 -RetryTimeout 70 -ErrorAction SilentlyContinue
		if (Test-Path -Path "$datadir\utils\utils.7z.00$u" -PathType Leaf) {break} else {
			Write-Host " "
			Write-Host -ForegroundColor Black -BackgroundColor Red "Uhhhhhhh"
			Write-Host -ForegroundColor Red "Did the transfer fail?" -n; Write-Host " Retrying..."
		}
	}
}
Start-Process $coredir\7z\7za.exe -Wait -NoNewWindow -ArgumentList "e $datadir\utils\utils.7z.001 -o$datadir\utils -y"