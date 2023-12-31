function add-host($filename) {
    Add-Content -Path $filename -Value $data.ForEach({$PSItem.IP + "`t`t`t" + $PSItem.Name}) | Wait-Process
}
function remove-host($filename) {
    Get-Content -Path $filename | -replace $data.ForEach({$PSItem.IP}),"" | -replace $data.ForEach({$PSItem.Name}),"" | Wait-Process
}

try {
    if ($data.($PSItem.Action -eq "add")) {
        add-host $host_file
    } elseif ($data.($PSItem.Action -eq "remove")) {
        remove-host $host_file
    } else {
        throw "Invalid operation '" + $data.($PSItem.Action) + "' - must be one of 'add', 'remove', 'show'."
    }
} catch  {
    Write-Host $error[0]
    Write-Host "`nUsage: hosts add <ip> <hostname>`n       hosts remove <hostname>`n       hosts show"
}

Write-Output $imp_wsl_msg
SleepProgress 5 $imp_wsl_msg
#Pause $cont_msg