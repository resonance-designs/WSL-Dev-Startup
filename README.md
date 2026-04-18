# WSL-Dev-Startup

A PowerShell startup script for a Windows + WSL local development environment. It starts WSL services, rebuilds the Windows hosts file from configured source blocks, imports enabled Apache virtual hosts, and refreshes Windows `netsh interface portproxy` mappings so stable local IPs can forward traffic into WSL.

## What It Does

Each run performs this sequence:

1. Resolve the target WSL distro.
2. Restart Apache and MySQL inside that distro.
3. Back up the current Windows hosts file.
4. Rebuild the Windows hosts file from configured host-part files.
5. Optionally import enabled Apache `ServerName` and `ServerAlias` values from WSL.
6. Refresh portproxy rules for Apache, Nginx, MERN, and Rails.

The hosts file is rebuilt from scratch, but the script now creates a timestamped backup first:

```text
data\backups\hosts-YYYYMMDD-HHMMSS.bak
```

Generated backups are ignored by Git.

## Prerequisites

This project assumes:

* Windows with WSL2 installed.
* A Debian-based WSL distribution. The default config auto-selects your default WSL distro.
* Apache and MySQL installed in that WSL distribution.
* An elevated Windows PowerShell session, or a Scheduled Task configured to run with highest privileges.

The script must run elevated because it writes to:

```text
C:\Windows\System32\drivers\etc\hosts
```

and updates Windows portproxy rules with:

```powershell
netsh interface portproxy
```

The script starts WSL services as WSL `root`, so `/etc/sudoers` `NOPASSWD` entries are not required for the default Apache/MySQL restart commands.

## Manual Run

Open Windows PowerShell or Command Prompt as Administrator, then run:

```powershell
& "C:\Scripts\WSL-Dev-Startup\WSL-Dev-Startup.cmd"
```

The `.cmd` launcher runs:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File WSL-Dev-Startup.ps1 -PauseOnExit
```

Manual runs pause at the end. On success, the script shows a green framed message. On failure, it shows red unframed error text with possible causes and fixes.

## Scheduled Startup

For scheduled startup, call the PowerShell script directly so the task can finish without waiting for a keypress:

```powershell
$action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\WSL-Dev-Startup\WSL-Dev-Startup.ps1"' `
  -WorkingDirectory "C:\Scripts\WSL-Dev-Startup"

$trigger = New-ScheduledTaskTrigger -AtLogOn

$principal = New-ScheduledTaskPrincipal `
  -UserId $env:USERNAME `
  -LogonType Interactive `
  -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet `
  -AllowStartIfOnBatteries `
  -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask `
  -TaskPath "\Scripts\" `
  -TaskName "WSL-Dev-Startup" `
  -Action $action `
  -Trigger $trigger `
  -Principal $principal `
  -Settings $settings `
  -Description "Start WSL development services, rebuild hosts, and refresh portproxy mappings." `
  -Force
```

To update an existing task action:

```powershell
Set-ScheduledTask -TaskPath "\Scripts\" -TaskName "WSL-Dev-Startup" -Action $action
```

To run the task manually:

```powershell
Start-ScheduledTask -TaskPath "\Scripts\" -TaskName "WSL-Dev-Startup"
```

## Configuration

The main config file is:

```text
data\Config.example.psd1
```

Important values:

* `WSLDist`: WSL distribution name. Leave empty to use the default WSL distro.
* `WSLDistPrompt`: set to `$true` to choose from installed distros each time the script runs.
* `WinHostsFile`: path to the Windows hosts file.
* `Backups`: folder where timestamped hosts-file backups are written.
* `PauseOnExit`: default pause behavior for direct `.ps1` runs. The `.cmd` launcher also passes `-PauseOnExit`.
* `ImportApacheVHosts`: set to `$true` to add enabled Apache `ServerName` and `ServerAlias` values from WSL.
* `ApacheIP`, `NginxIP`, `MERNIP`, `RailsIP`: stable local listen IPs for portproxy.
* `ApachePort`, `NginxPort`, `MERNPort`, `RailsPort`: WSL service ports to forward to.
* `HeaderLocalhost`, `HostsArray`, `SoftwareBlocks`, `AdBlocks`: host-part files used to rebuild the hosts file.

### WSL Distro Selection

The default configuration is:

```powershell
WSLDist = ""
WSLDistPrompt = $false
```

With those values, the script uses the default distro reported by WSL. This is the best setting for Scheduled Task startup because it does not wait for input.

To pin the script to a specific distro:

```powershell
WSLDist = "Ubuntu"
WSLDistPrompt = $false
```

To choose from installed distros during manual runs:

```powershell
WSLDist = ""
WSLDistPrompt = $true
```

Check installed distro names with:

```powershell
wsl -l -v
```

## File Layout

The project root contains:

* `WSL-Dev-Startup.cmd`: manual launcher that pauses on success/failure.
* `WSL-Dev-Startup.ps1`: main script.
* `README.md`: this documentation.

The `data` folder contains:

* `Config.example.psd1`: central configuration.
* `host-parts/`: files used to rebuild the Windows hosts file.
* `ui-elements/Colors.ps1`: terminal color variables.
* `backups/`: runtime hosts-file backups. This folder is ignored by Git.

The `modules` folder contains:

* `Utilities/Utilities.psm1`: output styling, progress display, distro selection, and pause handling.
* `WSLServices/WSLServices.psm1`: restarts Apache and MySQL inside the resolved WSL distro.
* `ImportHosts/ImportHosts.psm1`: backs up, clears, and rebuilds the Windows hosts file.
* `NetConfig/NetConfig.psm1`: detects the current WSL IP and refreshes portproxy mappings.

## Host Parts

The host-part files are written to the Windows hosts file in this order:

1. `HeaderLocalhost.example.txt`
2. `HostArray.example.ps1`
3. Enabled Apache vhosts, when `ImportApacheVHosts = $true`
4. `SoftwareBlocks.example.txt`
5. `AdBlocks.example.txt`

`HostArray.example.ps1` defines a `$hosts` array. Each object currently uses `Action = 'add'`, plus a `Name` and `IP`. Blank `Name` values can be used for comment/header lines.

When `ImportApacheVHosts` is enabled, the script reads:

```text
/etc/apache2/sites-enabled
```

Any enabled Apache `ServerName` or `ServerAlias` values are written to the Windows hosts file using `ApacheIP`. Keep `HostArray.example.ps1` for manual entries, non-Apache apps, blocked hosts, or names that do not appear in Apache vhost config.

## Network Behavior

`NetConfig.psm1` deletes and recreates the configured portproxy rules each time the script runs. This matters because WSL2 IP addresses can change between sessions.

The default mappings are:

```text
127.65.43.21:80 -> <current WSL IP>:80
127.65.43.22:80 -> <current WSL IP>:81
127.65.43.23:80 -> <current WSL IP>:3000
127.65.43.24:80 -> <current WSL IP>:10524
```

To inspect all portproxy rules:

```powershell
netsh interface portproxy show all
```

To remove all portproxy rules:

```powershell
netsh interface portproxy reset
```

Only use `reset` if you do not need any existing portproxy rules.

## Troubleshooting

If the script exits immediately with an Administrator error, reopen PowerShell or Command Prompt using **Run as administrator**.

If service startup fails, confirm the configured distro exists:

```powershell
wsl -l -v
```

Then check services inside WSL:

```powershell
wsl -d <distro> -- service apache2 status
wsl -d <distro> -- service mysql status
```

If host writes fail, close editors or security tools that may temporarily lock:

```text
C:\Windows\System32\drivers\etc\hosts
```

If DNS resolution seems stale after a host rebuild:

```powershell
ipconfig /flushdns
```

If portproxy output contains old malformed values such as `System.Collections.Hashtable.ApacheIP`, remove those rules or reset portproxy, then rerun the script.

## Notes

The example files are intentionally editable. Update the config and host-part files to match your WSL distro name, local domains, service ports, and desired host blocks.
