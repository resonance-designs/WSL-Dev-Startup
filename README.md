# WSL-Dev-Startup

A PowerShell startup script for a Windows + WSL local development environment. It starts selected WSL services, rebuilds the Windows hosts file from configured source blocks, and refreshes Windows `netsh interface portproxy` mappings so stable local IPs can forward traffic into WSL.

> [!WARNING]
> This script rebuilds the Windows hosts file from scratch. It clears the existing file and then writes the configured blocks from `data/host-parts`. Back up `C:\Windows\System32\drivers\etc\hosts` before running the script if you have entries you have not already moved into the configured host-part files.

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

and because it updates Windows portproxy rules with:

```powershell
netsh interface portproxy
```

The script starts WSL services by running commands as WSL `root`. The service commands are effectively:

```powershell
wsl -d <distro> -u root -- service apache2 restart
wsl -d <distro> -u root -- service mysql restart
```

Because of that, the old `/etc/sudoers` `NOPASSWD` setup is no longer required for the default service startup commands.

## Running Manually

Open Windows PowerShell as Administrator, then run:

```powershell
& "C:\Dev\Projects\scripts\wsl-dev-startup\WSL-Dev-Startup.cmd"
```

The command launcher runs PowerShell with:

```powershell
-NoProfile -ExecutionPolicy Bypass
```

so a machine-wide Group Policy change is usually not required just to run this script manually.

After running, check the portproxy rules with:

```powershell
netsh interface portproxy show all
```

With the default config, the expected shape is:

```text
Listen Address  Listen Port  Connect Address  Connect Port
127.65.43.21    80           <current WSL IP>  80
127.65.43.22    80           <current WSL IP>  81
127.65.43.23    80           <current WSL IP>  3000
```

The WSL IP is detected at runtime from the resolved WSL distro.

## Scheduled Startup

To run this automatically at login:

1. Run `taskschd.msc`.
2. Right-click **Task Scheduler Library** and create or select a folder, such as `Scripts`.
3. Choose **Create Task**.
4. On **General**, set a name such as `WSL-Dev-Startup`.
5. Check **Run with highest privileges**.
6. On **Triggers**, add **At log on**.
7. On **Actions**, choose **Start a program**.
8. Browse to and select `WSL-Dev-Startup.cmd`.
9. On **Conditions**, adjust power settings as needed.
10. Save the task.

You can create a shortcut to trigger the task manually:

```powershell
schtasks /run /tn "Scripts\WSL-Dev-Startup"
```

Adjust the task path if you used a different Task Scheduler folder or task name.

## Configuration

The main config file is:

```text
data/Config.example.psd1
```

Important values:

* `WSLDist`: WSL distribution name. Leave empty to use the default WSL distro.
* `WSLDistPrompt`: set to `$true` to choose from installed distros each time the script runs.
* `WinHostsFile`: path to the Windows hosts file.
* `ApacheIP`, `NginxIP`, `MERNIP`: stable local listen IPs for portproxy.
* `ApachePort`, `NginxPort`, `MERNPort`: WSL service ports to forward to.
* `HeaderLocalhost`, `HostsArray`, `SoftwareBlocks`, `AdBlocks`: host-part files used to rebuild the hosts file.

### WSL Distro Selection

The default configuration is:

```powershell
WSLDist = ""
WSLDistPrompt = $false
```

With those values, the script uses the default distro reported by WSL. This is the best setting for Scheduled Task startup because it does not wait for input.

To pin the script to a specific distro, set `WSLDist` to an installed distro name:

```powershell
WSLDist = "Ubuntu"
WSLDistPrompt = $false
```

To choose from installed distros when the script runs manually:

```powershell
WSLDist = ""
WSLDistPrompt = $true
```

Check installed distro names with:

```powershell
wsl -l -v
```

## File Layout

### Root

The project root contains:

* `WSL-Dev-Startup.cmd`: launcher for the PowerShell script.
* `WSL-Dev-Startup.ps1`: main script. It loads config, checks for Administrator rights, imports modules, starts services, rebuilds hosts, and applies network config.
* `README.md`: this documentation.

### data

The `data` folder contains script configuration and source data.

* `Config.example.psd1`: central configuration.
* `host-parts/`: files used to rebuild the Windows hosts file.
* `ui-elements/Colors.ps1`: terminal color variables.

### data/host-parts

The host-part files are written to the Windows hosts file in this order:

1. `HeaderLocalhost.example.txt`
2. `HostArray.example.ps1`
3. `SoftwareBlocks.example.txt`
4. `AdBlocks.example.txt`

`HostArray.example.ps1` defines a `$hosts` array. Each object currently uses `Action = 'add'`, plus a `Name` and `IP`. Blank `Name` values can be used for comment/header lines.

### modules

The script logic is split into PowerShell modules:

* `Utilities/Utilities.psm1`: output styling, progress display, and pause handling.
* `WSLServices/WSLServices.psm1`: resolves the WSL distro and restarts Apache and MySQL inside it.
* `ImportHosts/ImportHosts.psm1`: clears and rebuilds the Windows hosts file from host-part files.
* `NetConfig/NetConfig.psm1`: detects the current IP for the resolved WSL distro and refreshes portproxy mappings.

## Network Behavior

`NetConfig.psm1` deletes and recreates the configured portproxy rules each time the script runs. This matters because WSL2 IP addresses can change between sessions.

The default mappings are:

* `127.65.43.21:80` -> WSL Apache on port `80`.
* `127.65.43.22:80` -> WSL Nginx on port `81`.
* `127.65.43.23:80` -> a MERN app on port `3000`.

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

If the script exits immediately with an Administrator error, reopen PowerShell using **Run as administrator**.

If service startup fails, confirm the configured distro exists:

```powershell
wsl -l -v
```

Then check the services inside WSL:

```powershell
wsl -d <distro> -- service apache2 status
wsl -d <distro> -- service mysql status
```

If portproxy output contains literal values such as `System.Collections.Hashtable.ApacheIP`, remove the bad rules and rerun the current script:

```powershell
netsh interface portproxy delete v4tov4 listenport=80 listenaddress=System.Collections.Hashtable.ApacheIP
netsh interface portproxy delete v4tov4 listenport=80 listenaddress=System.Collections.Hashtable.NginxIP
netsh interface portproxy delete v4tov4 listenport=80 listenaddress=System.Collections.Hashtable.MERNIP
```

Then rerun:

```powershell
& "C:\Dev\Projects\scripts\wsl-dev-startup\WSL-Dev-Startup.cmd"
```

## Notes

The example files are intentionally editable. Update the config and host-part files to match your own WSL distro name, local domains, service ports, and desired host blocks.
