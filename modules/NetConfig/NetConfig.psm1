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

function GetConfiguredPortProxies() {
    if ($config.ContainsKey("PortProxies") -and $config.PortProxies) {
        return @($config.PortProxies)
    }

    return @(
        @{ Name = "Apache"; ListenAddress = $config.ApacheIP; ListenPort = "80"; ConnectPort = $config.ApachePort }
        @{ Name = "Nginx"; ListenAddress = $config.NginxIP; ListenPort = "80"; ConnectPort = $config.NginxPort }
        @{ Name = "MERN"; ListenAddress = $config.MERNIP; ListenPort = "80"; ConnectPort = $config.MERNPort }
        @{ Name = "Rails"; ListenAddress = $config.RailsIP; ListenPort = "80"; ConnectPort = $config.RailsPort }
    ) | Where-Object { $_.ListenAddress -and $_.ConnectPort }
}

function AddPortProxy($listenAddress, $listenPort, $connectPort, $connectAddress, $name = "") {
    if ([string]::IsNullOrWhiteSpace($listenAddress)) {
        throw "Portproxy mapping '$name' is missing ListenAddress."
    }

    if ([string]::IsNullOrWhiteSpace($listenPort)) {
        throw "Portproxy mapping '$name' is missing ListenPort."
    }

    if ([string]::IsNullOrWhiteSpace($connectPort)) {
        throw "Portproxy mapping '$name' is missing ConnectPort."
    }

    $nativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        netsh.exe interface portproxy delete v4tov4 listenport=$listenPort listenaddress=$listenAddress | Out-Null

        netsh.exe interface portproxy add v4tov4 listenport=$listenPort listenaddress=$listenAddress connectport=$connectPort connectaddress=$connectAddress | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to add portproxy rule '$name' $listenAddress`:$listenPort -> $connectAddress`:$connectPort."
        }
    } finally {
        $PSNativeCommandUseErrorActionPreference = $nativeErrorPreference
    }
}

function SetNetConfigs() {
    $wsl_ip = GetWSLIP

    foreach ($proxy in GetConfiguredPortProxies) {
        AddPortProxy $proxy.ListenAddress $proxy.ListenPort $proxy.ConnectPort $wsl_ip $proxy.Name
    }

    WriteStepSuccess $config.NTCFGMsg $white $black $green $black
    SleepProgress 3 $config.NTCFGMsg $black $green
}
Export-ModuleMember -Function 'GetWSLIP'
Export-ModuleMember -Function 'GetConfiguredPortProxies'
Export-ModuleMember -Function 'AddPortProxy'
Export-ModuleMember -Function 'SetNetConfigs'
