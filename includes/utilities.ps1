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

# Simple utility to stylize the output
function StyleOutput([string]$msg, $fcolor, $bcolor){
    Write-Host "$msg" -ForegroundColor "$fcolor" -BackgroundColor "$bcolor"
}

# Pause for user input with custom message
function Pause($msg, $fcolor, $bcolor) {
    # Check if running Powershell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$msg")
    } else {
        StyleOutput $msg $fcolor $bcolor
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Trouble-Shooting: Print host array output
function PrintHostArray() {
    $data.ForEach({ $PSItem.Action + " " + $PSItem.Name + " " + $PSItem.IP})
    break
}