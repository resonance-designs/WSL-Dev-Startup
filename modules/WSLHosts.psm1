function add-host($filename) {
    Add-Content -Path $filename -Value $hosts.ForEach({$PSItem.IP + "`t`t`t" + $PSItem.Name})
}
function remove-host($filename) {
    Get-Content -Path $filename | -replace $hosts.ForEach({$PSItem.IP}),"" | -replace $hosts.ForEach({$PSItem.Name}),""
}

try {
    if ($hosts.($PSItem.Action -eq "add")) {
        add-host $host_file
    } elseif ($hosts.($PSItem.Action -eq "remove")) {
        remove-host $host_file
    } else {
        throw "Invalid operation '" + $hosts.($PSItem.Action) + "' - must be one of 'add', 'remove', 'show'."
    }
} catch  {
    Write-Host $error[0]
    Write-Host "`nUsage: hosts add <ip> <hostname>`n       hosts remove <hostname>`n       hosts show"
}

Write-Output $imp_wsl_msg
SleepProgress 10 $imp_wsl_msg