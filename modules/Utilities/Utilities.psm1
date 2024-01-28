# Sleep Progress Bar
function SleepProgress($TotalSeconds, [string]$Msg, $fcolor, $bcolor) {
    $Counter = 0;
    for ($i = 0; $i -lt $TotalSeconds; $i++) {
        $Progress = [math]::Round(100 - (($TotalSeconds - $Counter) / $TotalSeconds * 100));
        $Host.PrivateData.ProgressForegroundColor = $fcolor
        $Host.PrivateData.ProgressBackgroundColor = $bcolor 
        Write-Progress -Activity "$Msg ... " -Status "$Progress% Complete:" -SecondsRemaining ($TotalSeconds - $Counter) -PercentComplete $Progress;
        Start-Sleep 1
        $Counter++;
    }    
}

# Simple utility to stylize the output
function StyleOutput([string]$msg, $padamt, $newline, $fcolor, $bcolor){
    if($newline -eq "yes"){
        Write-Host $msg.PadLeft($padamt,' ') -NoNewline -ForegroundColor $fcolor -BackgroundColor $bcolor
    } else {
        Write-Host $msg.PadLeft($padamt,' ') -ForegroundColor $fcolor -BackgroundColor $bcolor
    }
}

# Pause for user input with custom message
function Pause($msg, $padamt, $newline, $fcolor, $bcolor) {
    # Check if running Powershell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show($msg)
    } else {
        StyleOutput $msg $padamt $newline $fcolor $bcolor
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Trouble-Shooting: Print host array output
function PrintHostArray() {
    $hosts.ForEach({ $PSItem.Action + " " + $PSItem.Name + " " + $PSItem.IP})
    break
}
Export-ModuleMember -Function 'SleepProgress'
Export-ModuleMember -Function 'StyleOutput'
Export-ModuleMember -Function 'Pause'