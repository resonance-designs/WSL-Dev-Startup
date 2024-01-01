# WSL-Dev-Startup
A PowerShell script to start WSL services, build the Windows hosts file using various sources (including the WSL host IP), and running network configurations.

## Prerequisites
In order for this script to work, there a few things that we need to make sure are configured correctly in WSL and native Windows.

*   Remove password requirement for specific service commands in WSL. This lets WSL services start when Windows boots without waiting for a password from the user. You definitely wouldn't want that in a production server, but it's perfectly fine in your local WSL dev environment.<br>
    To achieve this you need to edit your <code>/etc/sudoers</code> file in your WSL distro by adding the following lines at the bottom:

        %sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service apache2 restart
        %sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service mysql restart

*   Enable script execution with a policy to allow all scripts in the group policy editor. <br>
    To achieve this you need to:
	1.	Run (<code>Win + R</code>) <code>gpedit.msc</code> and nagivate to:

			Computer Configuration
	        |-- Administrative Templates
	            |-- Windows Components
	                |-- Windows PowerShell
	2.	Double-click on "Turn on Script Execution"
	3.	Select "Enabled"
	4.	Set "Allow all scripts" under Options->Execution Policy
	5.	Click "Apply"
	6.	Click "OK"

	For a more thorough examination of this process and why it may be required, see [this answer](https://stackoverflow.com/questions/27753917/how-do-you-successfully-change-execution-policy-and-enable-execution-of-powershe#answer-27755459) on [stackoverflow.com](https://stackoverflow.com).
    
*	Create shortcuts to start script. This is optional but highly recommended, especially if you want to run this script during startup and make it easily accessible in case you need to run it again in a current session. <br>
	To achieve this, you need to:

	1. Run (<code>Win + R</code>) <code>shell:startup</code> to open up the Windows startup folder.
	2. Right-click in the startup folder and select New->Shortcut
	3. Click "Browse"
	4. Locate and select the <code>wsl\_dev\_startup.cmd</code> file from this repo.
	5. Click "Next"
	6. Give the shortcut a name and click "Finish"
	7. Right-click on the newly created shortcut and select "Properties"
	8. Under the "Shortcut" tab, click on the "Advanced..." button
	9. Check the "Run as administrator" check-box and then click "OK"
	10. Click "Apply" and the click "OK"

	Now you can copy this shortcut to wherever you like, such as your desktop, to easily launch the script.

## Customizing Script Files
### Coming soon...

## Usage
### Coming soon...

## Planned Features/Updates
*	Replacing "dot sourced" include files with custom PowerShell modules that include additional functions. 