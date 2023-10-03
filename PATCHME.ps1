# BioniDKU Download mode & Windows Update mode - Software versions information file

# The purpose of this file is so I can update the version number of apps and the UBRs every month without having to update the whole script package. The UBRs section takes effect starting with version 300_update1, and the software version section starting with version 300_update5.


# SECTION 1: Software version numbers:
	<#    VLC    #> $global:VLCver = "3.0.18"
	<# OpenShell #> $global:OShellDispver = "4.4.191"; $global:OShellExecver = "4_4_191"
	<# Notepad++ #> $global:NPPver = "8.5.7"

# SECTION 2: Windows Update UBRs
. $workdir\modules\lib\GetEdition.ps1
switch ($edition) {
	
	# Consumer and any other editions
	default {$latest = @(
		<# ======= EOL builds ======= #>
		<# 1507 #>          "10240.17446"
		<# 1511 #>          "10586.1177"
		<# 1607 #>          "14393.2214"
		<# 1703 #>          "15063.1418"
		<# 1709 #>          "16299.1087"
		<# 1803 #>          "17134.1304" # .1130?
		<# 1809 #>          "17763.1577"
		<# 1903 #>          "18362.1256"
		<# 1909 #>          "18363.1556"
		<# 2004 #>          "19041.1415"
		<# 20H2 #>          "19042.1706"
		<# 21H1 #>          "19043.2364"
  		<# 21H2 #>          "19044.3086"
		<# ====== Alive builds ====== #>
		<# 22H2 #>          "19045.3448"
	)}
	
	# Commerical editions
	{$_ -like "Enterprise*" -or $_ -like "Education"} {$latest = @(
		<# ======= EOL builds ======= #>
		<# 1511 #>          "10586.17446"
		<# 1511 #>          "10586.1540"
		<# 1607 #>          "14393.2906"
		<# 1703 #>          "15063.2108"
		<# 1709 #>          "16299.2166"
		<# 1803 #>          "17134.2208"
		<# 1809 #>          "17763.1935"
		<# 1903 #>          "18362.1256"
		<# 1909 #>          "18363.2274"
		<# 2004 #>          "19041.1415"
		<# 20H2 #>          "19042.2965"
		<# 21H1 #>          "19043.2364"
		<# ====== Alive builds ====== #>
		<# 21H2 #>          "19044.3448"
		<# 22H2 #>          "19045.3448"
	)}
	
	# Long-term servicing editions
	{$_ -like "EnterpriseS"} {$latest = @(
		<# ====== Alive builds ====== #>
		<# LTSB 2015 #>     "10240.20162"
		<# LTSB 2016 #>     "14393.6252"
		<# LTSC 2019 #>     "17763.4851"
		<# LTSC 2021 #>     "19044.3448"
	)}
	
	# Server editions (Why? Perhaps Nana can answer that question...)
	{$_ -like "Server*"} {$latest = @(
		<# ====== Alive builds ====== #>
		<# Server 2016 #>   "14393.6252"
		<# Server 2019 #>   "17763.4851"
		<# Server 2022 #>   "20348.1970"
	)}
	
}
