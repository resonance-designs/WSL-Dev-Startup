# Define the variables
## Host Source Files
$header_localhost = Get-Content -Path $hosts_path"\header-localhost.example.txt"
$software_blocks = Get-Content -Path $hosts_path"\software-blocks.example.txt"
$ad_blocks = Get-Content -Path $hosts_path"\ad-blocks.example.txt"
$host_array = $hosts_path + "\host-array.example.ps1"
$host_file = ".\drivers\etc\hosts"
## Messaging
### Colors
#### Example as an array
$color_array = @(
    "Black",
    "DarkBlue",
    "DarkGreen",
    "DarkCyan",
    "DarkRed",
    "DarkMagenta",
    "DarkYellow",
    "Gray",
    "DarkGray",
    "Blue",
    "Green",
    "Cyan",
    "Red",
    "Magenta",
    "Yellow",
    "White"
)
#### Example as individual variables
$black = 'BLACK'
$darkblue = "DARKBLUE"
$darkgreen = "DARKGREEN"
$darkcyan = "DARKCYAN"
$darkred = "DARKRED"
$darkmagenta = "DARKMAGENTA"
$darkyellow = "DARKYELLOW"
$gray = "GRAY"
$darkgrey = "DARKGREY"
$blue = "BLUE"
$green = "GREEN"
$cyan = "CYAN"
$red = "RED"
$magenta = "MAGENTA"
$yellow = "YELLOW"
$white = "WHITE"
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
## Config Params
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
# Define the array of WSL hosts
$data = @(
    . $host_array
)