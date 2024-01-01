# Clear out the hosts file
Clear-Content $host_file | Wait-Process
Write-Output $clr_host_msg
SleepProgress 3 $clr_host_msg
#Pause $cont_msg

# Import the header and localhost definition
Add-Content -Path $host_file -Value $header_localhost | Wait-Process
Write-Output $imp_head_msg
SleepProgress 3 $imp_head_msg
#Pause $cont_msg

# Import WSL Hosts
. $inc_path"\wsl-hosts.ps1"
Write-Output $imp_wsl_msg
SleepProgress 3 $imp_wsl_msg
#Pause $cont_msg

# Import the software vendor host definitions to block traffic to
Add-Content -Path $host_file -Value $software_blocks | Wait-Process
Write-Output $imp_soft_msg
SleepProgress 3 $imp_soft_msg
#Pause $cont_msg

# Import the ads and "shady" host definitions to block traffic to
Add-Content -Path $host_file -Value $ad_blocks | Wait-Process
Write-Output $imp_ads_msg
SleepProgress 3 $imp_ads_msg
#Pause $cont_msg