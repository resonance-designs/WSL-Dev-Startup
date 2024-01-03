<# TODO: Turn this into a module
Import-Module WSLHosts
Import-Module $modules_path"WSLHosts.psm1"
WSLHosts
#>
function add-host($filename) {
    Add-Content -Path $filename -Value $hosts.ForEach({$PSItem.IP + "`t`t`t" + $PSItem.Name}) | Wait-Process
}
function remove-host($filename) {
    Get-Content -Path $filename | -replace $hosts.ForEach({$PSItem.IP}),"" | -replace $hosts.ForEach({$PSItem.Name}),"" | Wait-Process
}

try {
    if ($hosts.($PSItem.Action -eq "add")) {
        add-host $host_file
    } elseif ($hosts.($PSItem.Action -eq "remove")) {
        remove-host $host_file
    } else {
        throw "Invalid operation '" + $hosts.($PSItem.Action) + "' - must either 'add' or 'remove'."
    }
} catch  {
    Write-Host $error[0]
    Write-Host "`nUsage: hosts add <ip> <hostname>`n       hosts remove <hostname>"
}