function StartWSLServices() {
    Write-Output $config.OneLine
    # Start Apache Service
    wsl -d $config.WSLDist sudo service apache2 restart
    # Start MySQL Service
    wsl -d $config.WSLDist sudo service mysql restart
    Write-Output $config.TwoLines
    StyleOutput $config.SrvsStartMsg 0 "yes" $white $black
    StyleOutput $config.OKMsg 36 "no" $green $black
    SleepProgress 3 $config.SrvsStartMsg $black $green
}
Export-ModuleMember -Function 'StartWSLServices'
