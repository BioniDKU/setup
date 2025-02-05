# BioniDKU music picker module, part of the main menu - (c) Bionic Butter

function Select-DisenabledCol($regvalue) {
	$regreturns = (Get-ItemProperty -Path "HKCU:\Software\AutoIDKU\Music").$regvalue
	if ($regreturns -eq 1) {
		if (Check-AtLeastOneCol) {
			Show-Branding clear
			Write-Host -ForegroundColor Red "At least one collection must be enabled. If you want to disable all, use option 5 in the Script configuration menu (main menu action 2)."
			Write-Host -ForegroundColor White "Press Enter to continue."
			Read-Host
			exit
		}
		Set-ItemProperty -Path "HKCU:\Software\AutoIDKU\Music" -Name $regvalue -Value 0 -Type DWord -Force
	} else {
		Set-ItemProperty -Path "HKCU:\Software\AutoIDKU\Music" -Name $regvalue -Value 1 -Type DWord -Force
	}
}
function Check-AtLeastOneCol {
	$values = $touhou, $genshin, $deltarune, $undertale, $featured
	$oneCount = ($values -eq 1).Count; $zeroCount = ($values -eq 0).Count
	if ($oneCount -eq 1 -and $zeroCount -eq ($values.Count - 1)) {return $true} else {return $false}
}
$hkm = "\Music"

while ($true) {
	Show-Branding clear
	
	Write-Host -ForegroundColor Yellow "One of the main selling points of BioniDKU is its HUGE library of music, with over 60+ songs. Customize your selection by selecting your desired collections."
	Write-Host -ForegroundColor Gray "The selected collections will be downloaded in Download mode, and all songs within them will be shuffled."
	Write-Host -ForegroundColor Gray "(FYI, categories from 1 to 4 are game sound tracks. You can look up on the internet about those games. As for category `r`n5, it features works from independent composers or artists groups that I hand-picked.)"
	Write-Host -ForegroundColor White " 1. Touhou OSTs" -n;         Show-Disenabled 1 $hkm
	Write-Host -ForegroundColor White " 2. Genshin Impact OSTs" -n; Show-Disenabled 2 $hkm
	Write-Host -ForegroundColor White " 3. Deltarune OSTs" -n;      Show-Disenabled 3 $hkm
	Write-Host -ForegroundColor White " 4. Undertale OSTs" -n;      Show-Disenabled 4 $hkm
	Write-Host -ForegroundColor White " 5. Featured Artists" -n;    Show-Disenabled 5 $hkm
	Write-Host -ForegroundColor White "Type R to return to the previous menu."
	Write-Host " "
	Write-Host "> " -n ; $colsel = Read-Host
	
	switch ($colsel) {
		"1" {Select-DisenabledCol 1}
		"2" {Select-DisenabledCol 2}
		"3" {Select-DisenabledCol 3}
		"4" {Select-DisenabledCol 4}
		"5" {Select-DisenabledCol 5}
		{$_ -like "r"} {exit}
	}
}
