function GetConfiguredWSLServices() {
    if ($config.ContainsKey("WSLServices") -and $config.WSLServices) {
        return @($config.WSLServices)
    }

    return @("apache2", "mysql")
}

function StartWSLServices() {
    Write-Output $config.OneLine
    $nativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        foreach ($service in GetConfiguredWSLServices) {
            if ([string]::IsNullOrWhiteSpace($service)) {
                continue
            }

            wsl.exe -d $config.WSLDist -u root -- service $service restart
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to restart WSL service '$service' in distro '$($config.WSLDist)'."
            }
        }
    } finally {
        $PSNativeCommandUseErrorActionPreference = $nativeErrorPreference
    }
    Write-Output $config.TwoLines
    WriteStepSuccess $config.SrvsStartMsg $white $black $green $black
    SleepProgress 3 $config.SrvsStartMsg $black $green
}
Export-ModuleMember -Function 'GetConfiguredWSLServices'
Export-ModuleMember -Function 'StartWSLServices'
