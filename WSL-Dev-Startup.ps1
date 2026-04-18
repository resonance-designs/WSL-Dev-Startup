param(
    [switch]$PauseOnExit
)

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

$ErrorActionPreference = "Stop"
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSNativeCommandUseErrorActionPreference = $true
}

function WaitForExit([string]$prompt = "", $color = "Yellow") {
    if (-not [string]::IsNullOrWhiteSpace($prompt)) {
        Write-Host ""
        Write-Host $prompt -ForegroundColor $color
    }
    try {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        Read-Host "Press Enter to close this window"
    }
}

function ShowFailureHelp($errorRecord) {
    Write-Host ""
    Write-Host "WSL Dev Startup failed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Error:" -ForegroundColor Yellow
    Write-Host $errorRecord.Exception.Message
    Write-Host ""
    Write-Host "Possible reasons and fixes:" -ForegroundColor Yellow
    Write-Host "- Run this script from an elevated PowerShell session or use Run as administrator."
    Write-Host "- Confirm the configured WSL distro exists with: wsl -l -v"
    Write-Host "- If you changed WSLDist, make sure it exactly matches the distro name."
    Write-Host "- Confirm Apache/MySQL exist in WSL and can restart."
    Write-Host "- Close editors or security tools that may temporarily lock the Windows hosts file."
    Write-Host "- Confirm host-part files exist under data\host-parts and contain valid PowerShell/text."
    Write-Host "- Check portproxy manually with: netsh interface portproxy show all"
}

try {
    # Import Script Config Params and Paths
    $config = Import-PowerShellDataFile -Path $PSScriptRoot"\data\Config.example.psd1"
    $effectivePauseOnExit = $PauseOnExit -or $config.PauseOnExit

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw "WSL Dev Startup must be run from an elevated PowerShell session because it updates the Windows hosts file and portproxy rules."
    }

    $mdls_path = $PSScriptRoot+$config.Modules
    $host_parts = $PSScriptRoot+$config.HostParts
    $data_path = $PSScriptRoot+$config.Data
    $ui_path = $PSScriptRoot+$config.UI
    $colors = $config.Colors
    . $ui_path"$colors"

    # Modules use these values at runtime; publish them so PowerShell 7 module scope can resolve them consistently.
    $global:config = $config
    $global:host_parts = $host_parts
    $global:black = $black
    $global:darkblue = $darkblue
    $global:darkgreen = $darkgreen
    $global:darkcyan = $darkcyan
    $global:darkred = $darkred
    $global:darkmagenta = $darkmagenta
    $global:darkyellow = $darkyellow
    $global:gray = $gray
    $global:darkgrey = $darkgrey
    $global:blue = $blue
    $global:green = $green
    $global:cyan = $cyan
    $global:red = $red
    $global:magenta = $magenta
    $global:yellow = $yellow
    $global:white = $white

    # Import Script Modules
    Import-Module -Name $mdls_path\Utilities -Force
    $config.WSLDist = ResolveWSLDistro $config.WSLDist $config.WSLDistPrompt
    $global:config = $config
    Import-Module -Name $mdls_path\WSLServices -Force
    Import-Module -Name $mdls_path\ImportHosts -Force
    Import-Module -Name $mdls_path\NetConfig -Force

    # Execute Script Functions
    Clear-Host
    StyleOutput $config.StartMsg 0 "no" $green $black
    StartWSLServices
    BackupHosts $config.BkpHostMsg $white $black 24 $green $black 3 $config.BkpHostMsg $black $green
    ClearHosts $config.ClrHostMsg $white $black 16 $green $black 3 $config.ClrHostMsg $black $green
    ImportHostsPart $config.HeaderLocalhost $config.ImpHeadMsg $white $black 8 $green $black 3 $config.ImpHeadMsg $black $green
    ImportHostsArray $config.HostsArray $config.ImpWSLMsg $white $black 35 $green $black 3 $config.ImpWSLMsg $black $green
    if ($config.ImportApacheVHosts) {
        ImportApacheVHosts $config.ImpApacheVHostsMsg $white $black 21 $green $black 3 $config.ImpApacheVHostsMsg $black $green
    }
    ImportHostsPart $config.SoftwareBlocks $config.ImpSoftMsg $white $black 10 $green $black 3 $config.ImpSoftMsg $black $green
    ImportHostsPart $config.AdBlocks $config.ImpAdsMsg $white $black 15 $green $black 3 $config.ImpAdsMsg $black $green
    SetNetConfigs

    WriteSuccessFrame " = Script completed successfully. Press any key to close this window =" $green $black
    if ($effectivePauseOnExit) {
        WaitForExit
    }
    exit 0
} catch {
    ShowFailureHelp $_
    if ($effectivePauseOnExit) {
        WaitForExit "Script failed. Press any key to close this window." "Red"
    }
    exit 1
}
