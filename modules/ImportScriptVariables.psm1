# Define the variables
function ImportScriptVariables() {
    $hosts_path = "C:\Dev\Scripts\PS\WSL-Dev-Startup\host-parts"
    $modules_path = "C:\Dev\Scripts\PS\WSL-Dev-Startup\modules"
    $header_localhost = Get-Content -Path $hosts_path"\header-localhost.txt"
    $software_blocks = Get-Content -Path $hosts_path"\software-blocks.txt"
    $ad_blocks = Get-Content -Path $hosts_path"\ad-blocks.txt"
    $host_array = $hosts_path + "\host-array.ps1"
    $host_file = ".\drivers\etc\hosts"
    $cont_msg = "Press any key to continue..."
    $exit_msg = "Script execution finished successfully. Press any key to exit..."
    $new_lines = "`n `n `n `n"
    $clr_host_msg = "Cleared out the contents of the Windows host file. Resuming script in 5 seconds"
    $imp_head_msg = "Imported header-localhost.txt to Windows host file. Resuming script in 5 seconds"
    $imp_soft_msg = "Imported sofware-blocks.txt to Windows host file. Resuming script in 5 seconds"
    $imp_ads_msg = "Imported ad-blocks.txt to Windows host file. Resuming script in 5 seconds"
    $imp_wsl_msg = "Imported the WSL virtual hosts. Resuming script in 5"
    $wsl_dist = "Ubuntu-22.04"
    $wsl_ip = (wsl -d $wsl_dist hostname -I).trim()
    $apache_ip = "127.65.43.21"
    $nginx_ip = "127.65.43.22"
    $apache_port = "80"
    $nginx_port = "81"

    # Define the array of WSL hosts
    $data = @(
        #Import-Module MyWSLHostsArray
        . $host_array
    )
}
