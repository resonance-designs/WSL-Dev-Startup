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

function WriteStepSuccess([string]$msg, $msg_fclr, $msg_bclr, $ok_fclr, $ok_bclr) {
    $status = if ($global:config -and $global:config.OKMsg) { $global:config.OKMsg } else { "[ OK ]" }
    $statusColumn = 88

    try {
        $windowWidth = $Host.UI.RawUI.WindowSize.Width
        if ($windowWidth -gt 50) {
            $statusColumn = [Math]::Max(40, $windowWidth - $status.Length - 4)
        }
    } catch {
        $statusColumn = 88
    }

    $padding = [Math]::Max(1, $statusColumn - $msg.Length)
    Write-Host ($msg + (" " * $padding)) -NoNewline -ForegroundColor $msg_fclr -BackgroundColor $msg_bclr
    Write-Host $status -ForegroundColor $ok_fclr -BackgroundColor $ok_bclr
}

function WriteSuccessFrame([string]$msg, $fcolor, $bcolor) {
    $line = "=" * $msg.Length
    Write-Host $line -ForegroundColor $fcolor -BackgroundColor $bcolor
    Write-Host $msg -ForegroundColor $fcolor -BackgroundColor $bcolor
    Write-Host $line -ForegroundColor $fcolor -BackgroundColor $bcolor
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

function GetInstalledWSLDistros() {
    $distros = wsl.exe --list --quiet | ForEach-Object {
        ($_ -replace "`0", "").Trim()
    } | Where-Object {
        $_ -and ($_ -notmatch "^docker-desktop(-data)?$")
    }

    return @($distros)
}

function GetDefaultWSLDistro() {
    $defaultLine = wsl.exe --list --verbose | ForEach-Object {
        $_ -replace "`0", ""
    } | Where-Object {
        $_ -match "^\s*\*"
    } | Select-Object -First 1

    if (-not $defaultLine) {
        return $null
    }

    return (($defaultLine -replace "^\s*\*\s*", "") -split "\s{2,}")[0].Trim()
}

function ResolveWSLDistro([string]$ConfiguredDistro, [bool]$PromptForDistro) {
    $distros = GetInstalledWSLDistros
    if ($distros.Count -eq 0) {
        throw "No WSL distributions are installed."
    }

    if (-not [string]::IsNullOrWhiteSpace($ConfiguredDistro)) {
        if ($distros -contains $ConfiguredDistro) {
            return $ConfiguredDistro
        }

        throw "Configured WSL distro '$ConfiguredDistro' was not found. Installed distros: $($distros -join ', ')"
    }

    if ($PromptForDistro -and $Host.Name -ne "ServerRemoteHost") {
        Write-Host "Installed WSL distributions:"
        for ($i = 0; $i -lt $distros.Count; $i++) {
            Write-Host ("[{0}] {1}" -f ($i + 1), $distros[$i])
        }

        $selection = Read-Host "Select a distro number"
        $index = 0
        if ([int]::TryParse($selection, [ref]$index) -and $index -ge 1 -and $index -le $distros.Count) {
            return $distros[$index - 1]
        }

        throw "Invalid WSL distro selection '$selection'."
    }

    $defaultDistro = GetDefaultWSLDistro
    if ($defaultDistro -and ($distros -contains $defaultDistro)) {
        return $defaultDistro
    }

    return $distros[0]
}

# Trouble-Shooting: Print host array output
function PrintHostArray() {
    $hosts.ForEach({ $PSItem.Action + " " + $PSItem.Name + " " + $PSItem.IP})
    break
}
Export-ModuleMember -Function 'SleepProgress'
Export-ModuleMember -Function 'StyleOutput'
Export-ModuleMember -Function 'WriteStepSuccess'
Export-ModuleMember -Function 'WriteSuccessFrame'
Export-ModuleMember -Function 'Pause'
Export-ModuleMember -Function 'GetInstalledWSLDistros'
Export-ModuleMember -Function 'GetDefaultWSLDistro'
Export-ModuleMember -Function 'ResolveWSLDistro'
