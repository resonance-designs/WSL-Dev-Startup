# WSL-Dev-Startup
A PowerShell script to start WSL services, build the Windows hosts file using various sources (including the WSL host IP), and run network configuration tasks.

## Prerequisites
In order for this script to work, there a few things that we need to make sure are configured correctly in WSL and native Windows.

*   Remove password requirement for specific service commands in WSL. This lets WSL services start when Windows boots without waiting for a password from the user. You definitely wouldn't want that in a production server, but it's perfectly fine in your local WSL dev environment.<br>
    To achieve this you need to edit your **<code>/etc/sudoers</code>** file in your WSL distro by adding the following lines at the bottom:

        %sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service apache2 restart
        %sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service mysql restart

*   Enable script execution with a policy to allow all scripts in the group policy editor. <br>
    To achieve this you need to:
	1.	Run (**<code>Win + R</code>**) **<code>gpedit.msc</code>** and nagivate to:

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

	1. Run (**<code>Win + R</code>**) **<code>shell:startup</code>** to open up the Windows startup folder.
	2. Right-click in the startup folder and select New->Shortcut
	3. Click "Browse"
	4. Locate and select the **<code>wsl\_dev\_startup.cmd</code>** file from this repo.
	5. Click "Next"
	6. Give the shortcut a name and click "Finish"
	7. Right-click on the newly created shortcut and select "Properties"
	8. Under the "Shortcut" tab, click on the "Advanced..." button
	9. Check the "Run as administrator" check-box and then click "OK"
	10. Click "Apply" and the click "OK"

	Now you can copy this shortcut to wherever you like, such as your desktop, to easily launch the script.

## Explanation of Files and Folders
Let's briefly go over the purpose of the folders and files the script utilizes.

### <code>root</code>
The root contains the two main script files that launch the script (**<code>wsl\_dev\_startup.cmd</code>**) and run it's commands (**<code>wsl\_dev\_startup.ps1</code>**).

### <code>\host-parts</code>
The **<code>\host-parts</code>** folder contains all the "parts" or "blocks" used to build the Windows hosts file, which is typically located at **<code>C:\Windows\System32\drivers\etc\hosts</code>**. These parts are injected into the Windows hosts file in sequence. These files can be whatever you want so long as they match what is defined in the **<code>\includes\variable-definitions.ps1</code>** file which we will get to soon.
In this repo you will find a few examples included in this folder:

*	**<code>ad-blocks.example.txt</code>**
*	**<code>header-localhost.example.txt</code>**
*	**<code>host-array.example.ps1</code>**
*	**<code>software-blocks.example.txt</code>**

### <code>\includes</code>
The **<code>\includes</code>** folder contains various functions, utilities, configurations, and services. We'll go through the purpose of each of them:

#### <code>import-hosts.ps1</code>
This file runs the commands necessary to build the Windows host file. Certain parameters of these commands need to match your configurations and variable values. You can use this file as a guide and remove or add commands to fit your needs.

#### <code>network-config.ps1</code>
This file serves to add network configurations to the environment. I currently have two commands in this file that uses **<code>netsh</code>** to assign static IP's for the Apache and Nginx servers in the WSL distro via proxy service. This is useful for running multiple apps using different services over different IP's.

#### <code>utilities.ps1</code>
This file contains a small collection of utilities used throughout the script. The included functions so far include:

*	**<code>SleepProgress</code>**: Displays a progress bar which can be set to a time in seconds.
*	**<code>Pause</code>**: Creates a "pause" that waits for a user key-press before continuing to the next line of the script, similar to that found in MSDOS, with customizable output message.
*	**<code>PrintHostArray</code>**: A trouble-shooting utility to display the values of the **<code>host-array.example.ps1</code>** file. 

#### <code>variable-definitions.ps1</code>
This file contains variables for paths, files, arrays, and string used in various configurations and functions that are frequently used throughout the script. There is only one variable that is defined outside of this script, and that is the $inc_path variable which is required by the root **<code>wsl\_dev\_startup.ps1</code>** file before we can import this **<code>variable-definitions.ps1</code>** file.

#### <code>wsl-hosts.ps1</code>
This contains functions for adding and removing hosts to the Windows hosts file that are mapped to either the native WSL distro IP or to the static IP's defined in the **<code>network-config.ps1</code>** file mentioned earlier. The host values used by these functions are stored in an object array defined in the  **<code>\host-parts\host-array.example.ps1</code>** file.

#### <code>wsl-services.ps1</code>
This file contains the commands to start the needed WSL services. Currently the only services included in this file are Apache and MySQL. 

## Customizing Script Files
### Coming soon...

## Usage
### Coming soon...

## Planned Features/Updates
*	Replacing "dot sourced" include files with custom PowerShell modules that include additional functions. 