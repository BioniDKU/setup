# BioniDKU utilities package fetcher - (c) Bionic Butter

$global:workdir = Split-Path(Split-Path "$PSScriptRoot")
$global:coredir = Split-Path "$PSScriptRoot"
$global:datadir = "$workdir\data"
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Support.psm1

$host.UI.RawUI.WindowTitle = "Project BioniDKU - (c) Bionic Butter | Utilites fetcher module | DO NOT CLOSE THIS WINDOW OR DISCONNECT INTERNET"
function Show-Branding {
	Clear-Host
	Write-Host 'Project BioniDKU - Next Generation AutoIDKU' -ForegroundColor White -BackgroundColor Blue
	Write-Host "Utilites fetcher module" -ForegroundColor Blue -BackgroundColor Gray
	Write-Host " "
}
$uexists = Test-Path -Path "$datadir\utils\WinXShell.zip" -PathType Leaf
if ($uexists) {exit}

Start-Logging DownloadMode_Utilsg
Show-Branding
Import-Module BitsTransfer

. $coredir\7boot\versioninfo.ps1
if (-not (Test-Path -Path "$datadir\utils")) {New-Item -Path $datadir -Name "utils" -itemType Directory | Out-Null}

$utilscdn = "https://github.com/BioniDKU/resources/releases/download/$utag"
while ($true) {
	Start-BitsTransfer -DisplayName "Getting the Utilites package" -Description " " -Source "$utilscdn/utils.7z" -Destination $datadir\utils -RetryInterval 60 -RetryTimeout 70 -ErrorAction SilentlyContinue
	if (Test-Path -Path "$datadir\utils\utils.7z" -PathType Leaf) {break} else {
		Write-Host " "
		Write-Host -ForegroundColor Black -BackgroundColor Red "Uhhhhhhh"
		Write-Host -ForegroundColor Red "Did the transfer fail?" -n; Write-Host " Retrying..."
		Start-Sleep -Seconds 1
	}
}

Start-Process $coredir\7z\7za.exe -Wait -NoNewWindow -ArgumentList "e $datadir\utils\utils.7z -o$datadir\utils -pBioniDKU -y"
