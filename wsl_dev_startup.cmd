::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: WSL Dev Startup
:: Description:
:: A PowerShell script to start WSL services, build the Windows hosts file using 
:: various sources (including the WSL host IP), and running network configurations.
::
:: Known limitations:
:: - Import of WSL hosts does not handle entries with comments afterwards, for example:
::   ("<ip>    <host>    # comment")
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Powershell -File C:\Dev\Scripts\PS\WSL-Dev-Startup\wsl_dev_startup.ps1