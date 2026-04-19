function BackupHosts($msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    if (-not (Test-Path -Path $config.WinHostsFile)) {
        throw "Windows hosts file was not found at '$($config.WinHostsFile)'."
    }

    $backup_dir = [System.IO.Path]::GetFullPath((Join-Path (Join-Path (Join-Path $PSScriptRoot '..') '..') $config.Backups))
    New-Item -ItemType Directory -Path $backup_dir -Force | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup_file = Join-Path $backup_dir "hosts-$timestamp.bak"
    Copy-Item -Path $config.WinHostsFile -Destination $backup_file -Force

    WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function WriteHostFile($content) {
    $text = ($content | Where-Object { $null -ne $_ }) -join [Environment]::NewLine
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($config.WinHostsFile, $text + [Environment]::NewLine, $utf8NoBom)
}

function AppendHostFile($content) {
    $text = ($content | Where-Object { $null -ne $_ }) -join [Environment]::NewLine
    if ([string]::IsNullOrEmpty($text)) {
        return
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::AppendAllText($config.WinHostsFile, $text + [Environment]::NewLine, $utf8NoBom)
}

function ClearHosts($msg, $msg_fclr, $msg_bclr, $space, $ok_fclr, $ok_bclr, $time, $sleep_msg, $sleep_fclr, $sleep_bclr) {
    # Clear out the hosts file
    WriteHostFile @()
    WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
    SleepProgress $time $sleep_msg $sleep_fclr $sleep_bclr
}

function GetHostPartPath($file) {
    return Join-Path $host_parts $file
}

function GetHostPartOrder($file) {
    $order_line = Get-Content -Path $file.FullName -ErrorAction Stop |
        Where-Object { $_ -match '^\s*#\s*HostPartOrder\s*:\s*(\d+)\s*$' } |
        Select-Object -First 1

    if (-not $order_line) {
        throw "Host part '$($file.Name)' is missing a numeric order flag. Add a line like '# HostPartOrder: 10'."
    }

    if ($order_line -notmatch '^\s*#\s*HostPartOrder\s*:\s*(\d+)\s*$') {
        throw "Host part '$($file.Name)' has an invalid order flag. Use a numeric line like '# HostPartOrder: 10'."
    }

    return [int]$Matches[1]
}

function GetHostPartContent($file) {
    return Get-Content -Path (GetHostPartPath $file) -ErrorAction Stop |
        Where-Object { $_ -notmatch '^\s*#\s*HostPartOrder\s*:\s*\d+\s*$' }
}

function AddHostPart($file) {
    $host_part = GetHostPartContent $file
    AppendHostFile $host_part
}

function AddWSLHost($hostEntries) {
    AppendHostFile $hostEntries.ForEach({$PSItem.IP + "`t`t`t" + $PSItem.Name})
}

function GetApacheSitesEnabledPath() {
    if ($config.ContainsKey("ApacheSitesEnabledPath") -and -not [string]::IsNullOrWhiteSpace($config.ApacheSitesEnabledPath)) {
        return $config.ApacheSitesEnabledPath
    }

    return "/etc/apache2/sites-enabled"
}

function GetApacheVHosts() {
    $sites_path = (GetApacheSitesEnabledPath).TrimEnd("/")
    $quoted_sites_path = "'" + ($sites_path -replace "'", "'\''") + "'"
    $raw_hosts = wsl.exe -d $config.WSLDist -- sh -lc "grep -hRE '^[[:space:]]*(ServerName|ServerAlias)[[:space:]]+' $quoted_sites_path/* 2>/dev/null || true"
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
                $tokens = $line -split "\s+"
                if ($tokens.Count -gt 1) {
                    Write-Output $tokens[1..($tokens.Count - 1)]
                }
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

function ImportDynamicHostParts($headerPart, $msg_fclr, $msg_bclr, $ok_fclr, $ok_bclr, $time, $sleep_fclr, $sleep_bclr) {
    if (-not (Test-Path -Path $host_parts -PathType Container)) {
        throw "Host parts directory was not found at '$host_parts'."
    }

    $host_part_files = @(Get-ChildItem -Path $host_parts -File |
        Where-Object { $_.Extension -in @(".ps1", ".txt") -and $_.Name -ne $headerPart } |
        ForEach-Object {
            [PSCustomObject]@{
                File = $_
                Order = GetHostPartOrder $_
            }
        })

    $duplicate_orders = @($host_part_files |
        Group-Object -Property Order |
        Where-Object { $_.Count -gt 1 })

    if ($duplicate_orders) {
        $duplicate_messages = $duplicate_orders | ForEach-Object {
            "order $($_.Name): $((@($_.Group) | ForEach-Object { $_.File.Name }) -join ', ')"
        }

        throw "Duplicate host part order flags found: $($duplicate_messages -join '; '). Each host-part file must use a unique HostPartOrder value."
    }

    $ordered_parts = @($host_part_files | Sort-Object Order)

    foreach ($part_info in $ordered_parts) {
        $part = $part_info.File
        if ($part.Extension -eq ".txt") {
            AddHostPart $part.Name
            $msg = " * Imported $($part.Name) to Windows host file. Resuming script in 3 seconds..."
            WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
            SleepProgress $time $msg $sleep_fclr $sleep_bclr
            continue
        }

        $hosts = @()
        . $part.FullName

        if (-not $hosts) {
            throw "Host array file '$($part.Name)' did not define any hosts."
        }

        $invalidHosts = $hosts | Where-Object { $_.Action -ne "add" }
        if ($invalidHosts) {
            throw "Invalid operation in '$($part.Name)' - only 'add' is currently supported."
        }

        AddWSLHost $hosts
        $msg = " * Imported $($part.Name) to Windows host file. Resuming script in 3 seconds..."
        WriteStepSuccess $msg $msg_fclr $msg_bclr $ok_fclr $ok_bclr
        SleepProgress $time $msg $sleep_fclr $sleep_bclr
    }
}

Export-ModuleMember -Function 'BackupHosts'
Export-ModuleMember -Function 'ClearHosts'
Export-ModuleMember -Function 'WriteHostFile'
Export-ModuleMember -Function 'AppendHostFile'
Export-ModuleMember -Function 'GetHostPartPath'
Export-ModuleMember -Function 'GetHostPartOrder'
Export-ModuleMember -Function 'GetHostPartContent'
Export-ModuleMember -Function 'AddHostPart'
Export-ModuleMember -Function 'AddWSLHost'
Export-ModuleMember -Function 'GetApacheSitesEnabledPath'
Export-ModuleMember -Function 'GetApacheVHosts'
Export-ModuleMember -Function 'ImportApacheVHosts'
Export-ModuleMember -Function 'ImportHostsPart'
Export-ModuleMember -Function 'ImportDynamicHostParts'
