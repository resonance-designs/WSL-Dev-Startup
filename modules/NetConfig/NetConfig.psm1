function GetWSLIP() {
    $wsl_ip = Invoke-Expression $config.WSLCommand | ForEach-Object { $_.Trim() }
}

function SetNetConfigs() {
    StyleOutput $config.NTCFGMsg 0 "yes" $white $black
    StyleOutput $config.OKMsg 28 "no" $green $black
    SleepProgress 3 $config.NTCFGMsg $black $green
    # Give WSL Apache a static IP on port 80
    netsh interface portproxy add v4tov4 listenport=80 listenaddress=$config.ApacheIP connectport=$config.ApachePort connectaddress=GetWSLIP
    # Give WSL Nginx a static IP on port 81
    netsh interface portproxy add v4tov4 listenport=80 listenaddress=$config.NginxIP connectport=$config.NginxPort connectaddress=GetWSLIP
    # Give WSL MERN a static IP on port 82
    netsh interface portproxy add v4tov4 listenport=80 listenaddress=$config.MERNIP connectport=$config.MERNPort connectaddress=GetWSLIP
}
Export-ModuleMember -Function 'GetWSLIP'
Export-ModuleMember -Function 'SetNetConfigs'
