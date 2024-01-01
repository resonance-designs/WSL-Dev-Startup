# Start Apache Service
wsl -d $wsl_dist sudo service apache2 restart
# Start MySQL Service
wsl -d $wsl_dist sudo service mysql restart
Write-Output $four_lines
Write-Output $srvs_start_msg
SleepProgress 3 $srvs_start_msg