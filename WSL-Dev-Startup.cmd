::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: WSL Dev Startup
:: Description:
:: A PowerShell script to start WSL services, build the Windows hosts file using
:: various sources (including the WSL host IP), and running network configurations.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Powershell -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0\WSL-Dev-Startup.ps1" -PauseOnExit
exit /b %ERRORLEVEL%
