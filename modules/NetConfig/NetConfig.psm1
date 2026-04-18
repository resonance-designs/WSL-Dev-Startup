function GetWSLIP() {
    $wsl_ips = wsl.exe -d $config.WSLDist -- hostname -I | ForEach-Object { $_.Trim() }
    $wsl_ip = $wsl_ips -split "\s+" | Where-Object { $_ -match "^\d{1,3}(\.\d{1,3}){3}$" } | Select-Object -First 1
    if (-not $wsl_ip) {
        throw "Unable to determine the WSL IP address for distro '$($config.WSLDist)'."
    }
    return $wsl_ip
}

function SetNetConfigs() {
    $wsl_ip = GetWSLIP

    # Give WSL Apache a static IP on port 80
    netsh interface portproxy delete v4tov4 listenport=80 listenaddress=$($config.ApacheIP) | Out-Null
    netsh interface portproxy add v4tov4 listenport=80 listenaddress=$($config.ApacheIP) connectport=$($config.ApachePort) connectaddress=$wsl_ip
    # Give WSL Nginx a static IP on port 81
    netsh interface portproxy delete v4tov4 listenport=80 listenaddress=$($config.NginxIP) | Out-Null
    netsh interface portproxy add v4tov4 listenport=80 listenaddress=$($config.NginxIP) connectport=$($config.NginxPort) connectaddress=$wsl_ip
    # Give WSL MERN a static IP on port 82
    netsh interface portproxy delete v4tov4 listenport=80 listenaddress=$($config.MERNIP) | Out-Null
    netsh interface portproxy add v4tov4 listenport=80 listenaddress=$($config.MERNIP) connectport=$($config.MERNPort) connectaddress=$wsl_ip

    StyleOutput $config.NTCFGMsg 0 "yes" $white $black
    StyleOutput $config.OKMsg 28 "no" $green $black
    SleepProgress 3 $config.NTCFGMsg $black $green
}
Export-ModuleMember -Function 'GetWSLIP'
Export-ModuleMember -Function 'SetNetConfigs'
