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

    WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function WriteHostFile($content) {
    $text = ($content | Where-Object { $null -ne $_ }) -join [Environment]::NewLine
    [System.IO.File]::WriteAllText($config.WinHostsFile, $text + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
}

function AppendHostFile($content) {
    $text = ($content | Where-Object { $null -ne $_ }) -join [Environment]::NewLine
    if ([string]::IsNullOrEmpty($text)) {
        return
    }

    [System.IO.File]::AppendAllText($config.WinHostsFile, $text + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
}

function ClearHosts($msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    # Clear out the hosts file
    WriteHostFile @()
    WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function AddHostPart($file) {
    $host_part = Get-Content -Path $host_parts"$file" -ErrorAction Stop
    AppendHostFile $host_part
}

function AddWSLHost($filename) {
    AppendHostFile $hosts.ForEach({$PSItem.IP + "`t`t`t" + $PSItem.Name})
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
    $existing_hosts = @()
    if (Test-Path -Path $config.WinHostsFile) {
        $existing_hosts = Get-Content -Path $config.WinHostsFile | ForEach-Object {
            $line = ($_ -split "#")[0].Trim()
            if ($line) {
                ($line -split "\s+")[-1]
            }
        }
    }

    $apache_hosts = @($apache_hosts | Where-Object { $existing_hosts -notcontains $_ })
    if ($apache_hosts.Count -gt 0) {
        AppendHostFile "# Apache Virtual Hosts"
        AppendHostFile $apache_hosts.ForEach({$config.ApacheIP + "`t`t`t" + $PSItem})
    }

    WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function ImportHostsPart($part, $msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    # Import the header and localhost definition
    AddHostPart $part
    WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function ImportHostsArray($array, $msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    . $host_parts"$array"
    $invalidHosts = $hosts | Where-Object { $_.Action -ne "add" }
    if (-not $invalidHosts) {
        AddWSLHost $config.WinHostsFile
    } else {
        throw "Invalid operation in hosts array - only 'add' is currently supported."
    }

    WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

Export-ModuleMember -Function 'BackupHosts'
Export-ModuleMember -Function 'ClearHosts'
Export-ModuleMember -Function 'WriteHostFile'
Export-ModuleMember -Function 'AppendHostFile'
Export-ModuleMember -Function 'AddHostPart'
Export-ModuleMember -Function 'AddWSLHost'
Export-ModuleMember -Function 'GetApacheVHosts'
Export-ModuleMember -Function 'ImportApacheVHosts'
Export-ModuleMember -Function 'ImportHostsPart'
Export-ModuleMember -Function 'ImportHostsArray'
