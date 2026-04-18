function GetWSLIP() {
    $wsl_ips = wsl.exe -d $config.WSLDist -- hostname -I | ForEach-Object { $_.Trim() }
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to query the WSL IP address for distro '$($config.WSLDist)'."
    }
    $wsl_ip = $wsl_ips -split "\s+" | Where-Object { $_ -match "^\d{1,3}(\.\d{1,3}){3}$" } | Select-Object -First 1
    if (-not $wsl_ip) {
        throw "Unable to determine the WSL IP address for distro '$($config.WSLDist)'."
    }
    return $wsl_ip
}

function AddPortProxy($listenAddress, $connectPort, $connectAddress) {
    $nativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        netsh.exe interface portproxy delete v4tov4 listenport=80 listenaddress=$listenAddress | Out-Null
    } finally {
        $PSNativeCommandUseErrorActionPreference = $nativeErrorPreference
    }

    netsh.exe interface portproxy add v4tov4 listenport=80 listenaddress=$listenAddress connectport=$connectPort connectaddress=$connectAddress | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to add portproxy rule $listenAddress`:80 -> $connectAddress`:$connectPort."
    }
}

function SetNetConfigs() {
    $wsl_ip = GetWSLIP

    # Give WSL Apache a static IP on port 80
    AddPortProxy $config.ApacheIP $config.ApachePort $wsl_ip
    # Give WSL Nginx a static IP on port 81
    AddPortProxy $config.NginxIP $config.NginxPort $wsl_ip
    # Give WSL MERN a static IP on port 82
    AddPortProxy $config.MERNIP $config.MERNPort $wsl_ip
    # Give WSL Rails a static IP on port 80
    AddPortProxy $config.RailsIP $config.RailsPort $wsl_ip

    WriteStepSuccess $config.NTCFGMsg $white $black $green $black
    SleepProgress 3 $config.NTCFGMsg $black $green
}
Export-ModuleMember -Function 'GetWSLIP'
Export-ModuleMember -Function 'AddPortProxy'
Export-ModuleMember -Function 'SetNetConfigs'
