#######################################################################################
# WSL Dev Startup
# Description:
# A PowerShell script to start WSL services, build the Windows hosts file using 
# various sources (including the WSL host IP), and running network configurations.
#
# Known limitations:
# - Import of WSL hosts does not handle entries with comments afterwards, for example: 
#   ("<ip>    <host>    # comment")
#######################################################################################
# Import Script Config Params and Paths
$config = Import-PowerShellDataFile -Path $PSScriptRoot"\data\Config.example.psd1"
$mdls_path = $PSScriptRoot+$config.Modules
$host_parts = $PSScriptRoot+$config.HostParts
$data_path = $PSScriptRoot+$config.Data
$ui_path = $PSScriptRoot+$config.UI
$colors = $config.Colors
. $ui_path"$colors"
# Import Script Modules
Import-Module -Name $mdls_path\Utilities
Import-Module -Name $mdls_path\WSLServices
Import-Module -Name $mdls_path\ImportHosts
Import-Module -Name $mdls_path\NetConfig
# Execute Script Functions
Clear-Host
StyleOutput $config.StartMsg 0 "no" $green $black
# Start WSL Services
StartWSLServices # This function is defined in the WSLServices module
# Clear Windows Host File
ClearHosts $config.ClrHostMsg $white $black 16 $green $black 3 $config.ClrHostMsg $black $green # This function is define in the ImportHosts module
# Import Hosts
ImportHostsPart $config.HeaderLocalhost $config.ImpHeadMsg $white $black 8 $green $black 3 $config.ImpHeadMsg $black $green # This function is defined in the ImportHosts module
ImportHostsArray $config.HostsArray $config.ImpWSLMsg $white $black 35 $green $black 3 $config.ImpWSLMsg $black $green # This function is defined in the ImportHosts module
ImportHostsPart $config.SoftwareBlocks $config.ImpSoftMsg $white $black 10 $green $black 3 $config.ImpSoftMsg $black $green 
ImportHostsPart $config.AdBlocks $config.ImpAdsMsg $white $black 15 $green $black 3 $config.ImpAdsMsg $black $green 
# Set Network Configuration
SetNetConfigs # This function is defined in the NetConfig module
StyleOutput $config.ExitDec 0 "no" $green $black # This function is defined in the Utilities module
StyleOutput $config.ExitMsg 0 "no" $green $black # This function is defined in the Utilities module
Pause $config.ExitDec 0 "no" $green $black # This function is defined in the Utilities module