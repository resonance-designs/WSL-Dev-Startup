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

# Define Script Paths
$root_path = $PSScriptRoot
$inc_path = $root_path+"\includes"
$hosts_path = $root_path+"\host-parts"
$modules_path = $root_path+"\modules"

# Import the variable definitions file
<# TODO: Turn this into a module
Import-Module ImportScriptVariables
Import-Module $modules_path"\ImportScriptVariables.psm1"
ImportScriptVariables
#>
#. $inc_path"\variable-definitions.ps1"
. $inc_path"\variable-definitions.example.ps1"

# Import Utilities
<# TODO: Turn this into a module
Import-Module ImportUtilities
Import-Module $modules_path"ImportUtilities.psm1"
ImportUtilities
#>
. $inc_path"\utilities.ps1"

# Start WSL Services
<# TODO: Turn this into a module
Import-Module StartWSLServices
Import-Module $modules_path"StartWSLServices.psm1"
StartWSLServices
#>
. $inc_path"\wsl-services.ps1"

# Import Hosts
<# TODO: Turn this into a module
Import-Module ImportHostIncludes
Import-Module $modules_path"ImportHostIncludes.psm1"
ImportHostIncludes
#>
. $inc_path"\import-hosts.ps1"

# Network Configuration
<# TODO: Turn this into a module
Import-Module NetworkConfig
Import-Module $modules_path"NetworkConfig.psm1"
NetworkConfig
#>
. $inc_path"\network-config.ps1"

StyleOutput $exit_dec $yellow $black
StyleOutput $exit_msg $yellow $black
Pause $exit_dec $yellow $black