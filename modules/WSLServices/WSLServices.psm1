function StartWSLServices() {
    Write-Output $config.OneLine
    $nativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        # Start Apache Service
        wsl.exe -d $config.WSLDist -u root -- service apache2 restart
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to restart Apache in WSL distro '$($config.WSLDist)'."
        }
        # Start MySQL Service
        wsl.exe -d $config.WSLDist -u root -- service mysql restart
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to restart MySQL in WSL distro '$($config.WSLDist)'."
        }
    } finally {
        $PSNativeCommandUseErrorActionPreference = $nativeErrorPreference
    }
    Write-Output $config.TwoLines
    WriteStepSuccess $config.SrvsStartMsg $white $black $green $black
    SleepProgress 3 $config.SrvsStartMsg $black $green
}
Export-ModuleMember -Function 'StartWSLServices'
