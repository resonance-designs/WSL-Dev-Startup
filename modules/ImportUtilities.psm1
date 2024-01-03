# Sleep Progress Bar
function SleepProgress($TotalSeconds, [string]$Msg) {
    $Counter = 0;
    for ($i = 0; $i -lt $TotalSeconds; $i++) {
        $Progress = [math]::Round(100 - (($TotalSeconds - $Counter) / $TotalSeconds * 100));
        Write-Progress -Activity "$Msg ... " -Status "$Progress% Complete:" -SecondsRemaining ($TotalSeconds - $Counter) -PercentComplete $Progress;
        Start-Sleep 1
        $Counter++;
    }    
}

# Trouble-Shooting: Print host array output
function PrintHostArray() {
    $hosts.ForEach({ $PSItem.Action + " " + $PSItem.Name + " " + $PSItem.IP})
    break
}