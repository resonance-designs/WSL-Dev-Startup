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

Export-ModuleMember -Function 'ClearHosts'
Export-ModuleMember -Function 'AddHostPart'
Export-ModuleMember -Function 'AddWSLHost'
Export-ModuleMember -Function 'ImportHostsPart'
Export-ModuleMember -Function 'ImportHostsArray'
