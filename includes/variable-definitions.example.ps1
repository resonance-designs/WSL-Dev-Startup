# Define the variables
## Host Source Files
### Target Windows Host File
$host_file = ".\drivers\etc\hosts"
### Import WSL Hosts Array
. $hosts_path"\host-array.example.ps1"
### Import Plain Text Blacks
$header_localhost = Get-Content -Path $hosts_path"\header-localhost.example.txt"
$software_blocks = Get-Content -Path $hosts_path"\software-blocks.example.txt"
$ad_blocks = Get-Content -Path $hosts_path"\ad-blocks.example.txt"
## Messaging
### Colors
#### Import Color Array
. $inc_path"\colors.ps1"
#### Map Color Array to variables
$black = $color_array[0]
$darkblue = $color_array[1]
$darkgreen = $color_array[2]
$darkcyan = $color_array[3]
$darkred = $color_array[4]
$darkmagenta = $color_array[5]
$darkyellow = $color_array[6]
$gray = $color_array[7]
$darkgrey = $color_array[8]
$blue = $color_array[9]
$green = $color_array[10]
$cyan = $color_array[11]
$red = $color_array[12]
$magenta = $color_array[13]
$yellow = $color_array[14]
$white = $color_array[15]
### Decorative
$one_line = "`n"
$two_lines = "`n `n"
$four_lines = "`n `n `n `n"
$cont_dec = " ============================="
$exit_dec = " ================================================================="
### Language
$cont_msg = " = Press any key to continue ="
$exit_msg = " = Script execution finished successfully. Press any key to exit ="
$srvs_start_msg = " * All WSL services were started. Resuming script in 3 seconds..."
$ntcfg_msg = " * Applied network configuration changes. Resuming script in 3 seconds..."
$clr_host_msg = " * Cleared out the contents of the Windows host file. Resuming script in 3 seconds..."
$imp_head_msg = " * Imported header-localhost.example.txt to Windows host file. Resuming script in 3 seconds..."
$imp_soft_msg = " * Imported sofware-blocks.example.txt to Windows host file. Resuming script in 3 seconds..."
$imp_ads_msg = " * Imported ad-blocks.example.txt to Windows host file. Resuming script in 3 seconds..."
$imp_wsl_msg = " * Imported the WSL virtual hosts. Resuming script in 3 seconds..."
## Configuration Params
$wsl_dist = "Ubuntu-22.04"
$wsl_ip = (wsl -d $wsl_dist hostname -I).trim()
$apache_ip = "127.65.43.21"
$nginx_ip = "127.65.43.22"
$rails_ip = "0.0.0.0"
$mern_ip = $wsl_ip
$apache_port = "80"
$nginx_port = "81"
$rails_port = "10524"
$mern_port = "3000"