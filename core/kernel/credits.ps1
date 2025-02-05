# BioniDKU license notice & 3rd party credits file - (c) Bionic Butter

Show-Branding clear
function Write-Hhhh($name,$link) {
	Write-Host $name -ForegroundColor White -n; Write-Host $link
}

Write-Host "########## SECTION 1: BioniDKU License ##########" -ForegroundColor Black -BackgroundColor Cyan
Write-Host -ForegroundColor White @"
 
 Project BioniDKU - Copyright (c) 2022-2025 Bionic Butter

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 
 BioniDKU is made possible by the original AutoIDKU project and the
 following free software/solutions listed in sections 2 and 3 below.
 Each mentioned software may come with their own license either 
 included within the program packages, and/or through provided links.
 
"@ 

Write-Host "########### SECTION 2: BioniDKU Core ############" -ForegroundColor Black -BackgroundColor Cyan
Write-Host " "
Write-Hhhh " - Microsoft PowerShell platform" ": https://learn.microsoft.com/en-us/powershell"
Write-Host " - AutoIDKU" -ForegroundColor Green -n; Write-Host ": https://github.com/sunryze-git/AutoIDKU/tree/8f12315"
Write-Hhhh " - 7-Zip CLI standalone" " (7za.exe & 7zxa.dll): https://www.7-zip.org"
Write-Host " "
Write-Host "###### SECTION 3: BioniDKU User experience ######" -ForegroundColor Black -BackgroundColor Cyan
Write-Host " "
Write-Host " Programs included in the Utilities package:" -ForegroundColor Cyan
Write-Hhhh " - AutoHotKey" " (AddressBarRemover2, BioniDKU Menus Launcher tray app): https://www.autohotkey.com"
Write-Hhhh " - AdvancedRun" " (Hikaru-chan): https://www.nirsoft.net/utils/advanced_run.html"
Write-Hhhh " - PE Network Manager" ": https://www.penetworkmanager.de"
Write-Hhhh " - Paint.NET" ": https://www.getpaint.net"
Write-Hhhh " - Classic Task manager & System Configuration" ": https://win7games.com/#taskmgr7"
Write-Hhhh " - WinXShell" " (Windows Update mode shell): https://theoven.org/viewtopic.php?t=89"
Write-Hhhh " - Wu10Man" ": https://github.com/WereDev/Wu10Man"
Write-Hhhh " - ContextMenuNormalizer" ": https://github.com/krlvm/ContextMenuNormalizer"
Write-Host " Programs included in the Essential Apps kit:" -ForegroundColor Cyan
Write-Hhhh " - Winaero Tweaker" ": https://winaerotweaker.com"
Write-Hhhh " - Open-Shell" ": https://github.com/Open-Shell/Open-Shell-Menu"
Write-Hhhh " - T-Clock" ": https://github.com/White-Tiger/T-Clock"
Write-Hhhh " - Mozilla Firefox ESR" ": https://www.mozilla.org/en-US/firefox/enterprise"
Write-Hhhh " - ShareX" ": https://getsharex.com"
Write-Hhhh " - Notepad++" ": https://notepad-plus-plus.org"
Write-Hhhh " - DesktopInfo" ": https://www.glenn.delahoy.com/desktopinfo/"
Write-Hhhh " - VLC" ": https://www.videolan.org/"
Write-Host " Cosmetic elements:" -ForegroundColor Cyan
Write-Hhhh " - Desktop background" " (Normal mode): 
   https://www.reddit.com/r/Genshin_Impact/comments/sk74fe/chinju_forest_inazuma_viewpoint_art"
Write-Hhhh " - Desktop background" " (Dark Sakura mode):
   https://www.hoyolab.com/article/13736966"
Write-Hhhh " - Ambient sound package" " (Script sound effects and Hikaru startup sounds): 
   Extracted from Genshin Impact in-game sounds effects. (c) COGNOSPHERE PTE. LTD."
Write-Hhhh " - FFPlay" " (Hand-crafted music player):
   https://ffmpeg.org/ffplay.html#Description"
Write-Host " "
Write-Host "####### SECTION 4: BioniDKU Contributors ########" -ForegroundColor Black -BackgroundColor Cyan
Write-Host " "
Write-Host " I would also like to thank the following people for making this script possible:" -ForegroundColor Cyan
Write-Host " (All usernames listed below are Discord usernames)"
Write-Host " - AutoIDKU author" -ForegroundColor Green -n; Write-Host ": @sunryze"
Write-Hhhh " - Volunteered testers" ": @juliastechspot, @zippykool, @strawtech8"
Write-Host " "
Write-Host " "
Write-Host "Press Enter to return to main menu." -ForegroundColor Yellow
Read-Host
