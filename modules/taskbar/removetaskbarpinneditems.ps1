Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Removing pinned items from taskbar" -n; Write-Host ([char]0xA0)
Stop-Process -Name "explorer" -Force 
Remove-Item "$env:appdata\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Force -Recurse
Start-Process explorer.exe
