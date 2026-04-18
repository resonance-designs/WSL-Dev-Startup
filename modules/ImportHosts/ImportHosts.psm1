function BackupHosts($msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    if (-not (Test-Path -Path $config.WinHostsFile)) {
        throw "Windows hosts file was not found at '$($config.WinHostsFile)'."
    }

    $backup_dir = $PSScriptRoot + "\..\.." + $config.Backups
    $backup_dir = [System.IO.Path]::GetFullPath($backup_dir)
    New-Item -ItemType Directory -Path $backup_dir -Force | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup_file = Join-Path $backup_dir "hosts-$timestamp.bak"
    Copy-Item -Path $config.WinHostsFile -Destination $backup_file -Force

    StyleOutput $msg 0 "yes" $msg_fclr $msg_bclr
    StyleOutput $config.OKMsg $space "no" $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function ClearHosts($msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    # Clear out the hosts file
    Clear-Content $config.WinHostsFile
    StyleOutput $msg 0 "yes" $msg_fclr $msg_bclr
    StyleOutput $config.OKMsg $space "no" $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function AddHostPart($file) {
    $host_part = Get-Content -Path $host_parts"$file"
    Add-Content -Path $config.WinHostsFile -Value $host_part
}

function AddWSLHost($filename) {
    Add-Content -Path $filename -Value $hosts.ForEach({$PSItem.IP + "`t`t`t" + $PSItem.Name})
}

function GetApacheVHosts() {
    $raw_hosts = wsl.exe -d $config.WSLDist -- sh -lc "grep -hRE '^[[:space:]]*(ServerName|ServerAlias)[[:space:]]+' /etc/apache2/sites-enabled/* 2>/dev/null || true"
    $apache_hosts = @()

    foreach ($line in $raw_hosts) {
        $clean_line = ($line -split "#")[0].Trim()
        if (-not $clean_line) {
            continue
        }

        $parts = $clean_line -split "\s+"
        if ($parts.Count -lt 2) {
            continue
        }

        $directive = $parts[0]
        if ($directive -ne "ServerName" -and $directive -ne "ServerAlias") {
            continue
        }

        foreach ($host_name in $parts[1..($parts.Count - 1)]) {
            if ($host_name -and $host_name -notmatch "\*") {
                $apache_hosts += $host_name
            }
        }
    }

    return @($apache_hosts | Sort-Object -Unique)
}

function ImportApacheVHosts($msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    $apache_hosts = GetApacheVHosts
    if ($apache_hosts.Count -gt 0) {
        Add-Content -Path $config.WinHostsFile -Value "# Apache Virtual Hosts"
        Add-Content -Path $config.WinHostsFile -Value $apache_hosts.ForEach({$config.ApacheIP + "`t`t`t" + $PSItem})
    }

    StyleOutput $msg 0 "yes" $msg_fclr $msg_bclr
    StyleOutput $config.OKMsg $space "no" $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function ImportHostsPart($part, $msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    # Import the header and localhost definition
    AddHostPart $part
    StyleOutput $msg 0 "yes" $msg_fclr $msg_bclr
    StyleOutput $config.OKMsg $space "no" $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function ImportHostsArray($array, $msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    try {
        . $host_parts"$array"
        $invalidHosts = $hosts | Where-Object { $_.Action -ne "add" }
        if (-not $invalidHosts) {
            AddWSLHost $config.WinHostsFile
        } else {
            throw "Invalid operation in hosts array - only 'add' is currently supported."
        }
    } catch  {
        Write-Host $error[0]
        Write-Host "`nUsage: hosts add <ip> <hostname>`n       hosts remove <hostname>`n       hosts show"
    }
    StyleOutput $msg 0 "yes" $msg_fclr $msg_bclr
    StyleOutput $config.OKMsg $space "no" $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

Export-ModuleMember -Function 'BackupHosts'
Export-ModuleMember -Function 'ClearHosts'
Export-ModuleMember -Function 'AddHostPart'
Export-ModuleMember -Function 'AddWSLHost'
Export-ModuleMember -Function 'GetApacheVHosts'
Export-ModuleMember -Function 'ImportApacheVHosts'
Export-ModuleMember -Function 'ImportHostsPart'
Export-ModuleMember -Function 'ImportHostsArray'
