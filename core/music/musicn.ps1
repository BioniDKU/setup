# BioniDKU Music fetcher module - (c) Bionic Butter

$global:workdir = Split-Path(Split-Path "$PSScriptRoot")
$global:coredir = Split-Path "$PSScriptRoot"
$global:datadir = "$workdir\data"
Import-Module -DisableNameChecking $workdir\modules\lib\Dynamic-Support.psm1

$host.UI.RawUI.WindowTitle = "Project BioniDKU - (c) Bionic Butter | Music fetcher module"
function Show-Branding {
	Clear-Host
	Write-Host 'Project BioniDKU - Next Generation AutoIDKU' -ForegroundColor White -BackgroundColor Blue
	Write-Host "Music fetcher module" -ForegroundColor Blue -BackgroundColor Gray
	Write-Host " "
}
$mexists = Test-Path -Path "$datadir\music"
if ($mexists -eq $true) {exit} else {New-Item -Path $datadir -Name "music" -itemType Directory | Out-Null}

Start-Logging DownloadMode_Musicn
Show-Branding
Import-Module BitsTransfer
. $coredir\7boot\versioninfo.ps1

$musicdn = "https://github.com/BioniDKU/resources/releases/download/$utag"
for ($c = 1; $c -le 5; $c++) {
	$cv = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU\Music").$c
	if ($cv -eq 1) {
		Write-Host "Downloading category $c..." -ForegroundColor White
		Start-BitsTransfer -DisplayName "Downloading category $c" -Description " " -Source "$musicdn/music$c.7z" -Destination $datadir\dls -RetryInterval 60 -RetryTimeout 70 -ErrorAction SilentlyContinue
		Start-Process $coredir\7z\7za.exe -Wait -NoNewWindow -ArgumentList "x $datadir\dls\music$c.7z -pBioniDKU -o$datadir\music"
	}
}

Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor DarkGray "Extraction complete!" -n; Write-Host " (If you see warnings, ignore them. The files should be fine)"
Write-Host -ForegroundColor Yellow "Some of the songs featured in this (nearly infinite) collection might be copyrighted. If you are planning to record and upload this run to public platforms, please beware of that. You can view this collection in $datadir\music"
Write-Host -ForegroundColor Yellow "Continuing in 10 seconds" -n; Write-Host " (or you can skip by pressing Ctrl+C)"
Start-Sleep -Seconds 10
