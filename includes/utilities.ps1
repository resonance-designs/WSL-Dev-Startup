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

# Pause for user input with custom message
function Pauses($message) {
    # Check if running Powershell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    } else {
        Write-Host "$message" -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Trouble-Shooting: Print host array output
function PrintHostArray() {
    $data.ForEach({ $PSItem.Action + " " + $PSItem.Name + " " + $PSItem.IP})
    break
}