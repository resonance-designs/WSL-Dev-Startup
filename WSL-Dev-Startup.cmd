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

Powershell -File %~dp0\WSL-Dev-Startup.ps1