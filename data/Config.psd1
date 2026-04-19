@{
    Modules = "\modules"
    WinHostsFile = "C:\Windows\System32\drivers\etc\hosts"
    # Leave WSLDist empty to use the default WSL distro.
    # Set WSLDistPrompt to $true to choose from installed distros each time the script runs.
    WSLDist = ""
    WSLDistPrompt = $false
    WSLServices = @(
        "apache2"
        "mysql"
    )
    Data = "\data\"
    Backups = "\data\backups\"
    UI = "\data\ui-elements\"
    Colors = "Colors.ps1"
    HostParts = "\data\host-parts\"
    ImportApacheVHosts = $true
    ApacheSitesEnabledPath = "/etc/apache2/sites-enabled"
    HeaderLocalhost = "HeaderLocalhost.txt"
    OneLine = "`n"
    TwoLines = "`n `n"
    FourLines = "`n `n `n `n"
    EightLines = "`n `n `n `n `n `n `n `n"
    ContDec = " ============================="
    ExitDec = " ================================================================="
    ContMsg = " = Press any key to continue ="
    ExitMsg = " = Script execution finished successfully. Press any key to exit ="
    PauseOnExit = $false
    StartMsg = " * Script Started!"
    SrvsStartMsg = " * All WSL services were started. Resuming script in 3 seconds..."
    BkpHostMsg = " * Backed up the Windows host file. Resuming script in 3 seconds..."
    NTCFGMsg = " * Applied network configuration changes. Resuming script in 3 seconds..."
    ClrHostMsg = " * Cleared out the contents of the Windows host file. Resuming script in 3 seconds..."
    ImpHeadMsg = " * Imported HeaderLocalhost.txt to Windows host file. Resuming script in 3 seconds..."
    ImpApacheVHostsMsg = " * Imported enabled Apache virtual hosts. Resuming script in 3 seconds..."
    OKMsg = "[ OK ]"
    ApacheIP = "127.65.43.21"
    NginxIP = "127.65.43.22"
    MERNIP = "127.65.43.23"
    RailsIP = "127.65.43.24"
    ApachePort = "80"
    NginxPort = "81"
    RailsPort = "10524"
    MERNPort = "3000"
    PortProxies = @(
        @{
            Name = "Apache"
            ListenAddress = "127.65.43.21"
            ListenPort = "80"
            ConnectPort = "80"
        }
        @{
            Name = "Nginx"
            ListenAddress = "127.65.43.22"
            ListenPort = "80"
            ConnectPort = "81"
        }
        @{
            Name = "MERN"
            ListenAddress = "127.65.43.23"
            ListenPort = "80"
            ConnectPort = "3000"
        }
        @{
            Name = "Rails"
            ListenAddress = "127.65.43.24"
            ListenPort = "80"
            ConnectPort = "10524"
        }
    )
} 
