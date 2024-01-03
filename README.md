# WSL-Dev-Startup
A PowerShell script to start WSL services, build the Windows hosts file using various sources (including the WSL host IP), and run network configuration tasks.

[!WARNING]\

This script builds the Windows host file from scratch, clearing out anything currently in it before building it, it does not append to it. Please backup your Windows hosts file somewhere safe and make sure to fully read this documentation before attempting to run this script. You can inject what is currently in your hosts file as part of the build process. You will learn more on how that works later, in the <strong>"Explanation of Files and Folders"</strong> section.

<!-- 
<div style="background: #FCC; padding: 2%; margin-top: 2%; border-radius: 5px;"><strong>Warning:</strong> This script builds the Windows host file from scratch, clearing out anything currently in it before building it, it does not append to it. Please backup your Windows hosts file somewhere safe and make sure to fully read this documentation before attempting to run this script. You can inject what is currently in your hosts file as part of the build process. You will learn more on how that works later, in the <strong>"Explanation of Files and Folders"</strong> section.</div>
-->

## Prerequisites
These instructions and the script itself assumes you have WSL2 installed on your Windows machine and the out-of-the-box configuration and examples contained in the script assume a Debian-based distribution for WSL, specifically Ubuntu 22.04, with a LAMP stack installed in that distribution. That won't be covered here but you can check out my thorough [WSL (Ubuntu 22.04.2 LTS) Local Development Environment Setup Guide](#) for instructions on that. 

In order for this script to work, there a few things that we need to make sure are configured correctly in WSL and Windows.

*   Remove password requirement for specific service commands in WSL. This lets WSL services start when Windows boots without waiting for a password from the user. You definitely wouldn't want that in a production server, but it's perfectly fine in your local WSL dev environment.<br>
    To achieve this you need to edit your **<code>/etc/sudoers</code>** file in your WSL distro by adding the following lines at the bottom:

        %sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service apache2 restart
        %sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service mysql restart

*   Enable script execution with a policy to allow all scripts in the Windows Group Policy Editor:

	1.	Run (**<code>Win + R</code>**) **<code>gpedit.msc</code>** and navigate to:

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
    
## Installation
1.	Clone this repository to a location of your choosing (e.g C:\Dev\Scripts\PS\WSL-Dev-Startup) using the git command: 

		git clone https://github.com/resonance-designs/WSL-Dev-Startup

2.	Create a new task using Windows Task Scheduler <br>
	1.	Run (**<code>Win + R</code>**) **<code>taskschd.msc</code>**.
	2.	Right-click on "Task Scheduler Library" then click "New Folder..." and name it whatever you like (e.g Scripts).
	3.	Right-click on the folder you just created and click "Create Task..." (**not** "Create Basic Task...").
	4.	Under the "General" tab enter a name (e.g WSL-Dev-Startup) and description of your choosing.
	5.	Click the check-box "Run with highest privileges".
	6.	Select your target operating system on the "Configure for:" drop-down (e.g Windows 10).
	7.	Switch over to the "Triggers" tab and click "New..."
	8.	Select "At log on" from the "Begin the task:" drop-down.
	9.	Select the user you want this task to run under or select "Any user" if you intend to run this script as any user.
	10.	Click "OK".
	11.	Switch over to the "Actions" tab and click "New..."
	12.	The "Action:" should be "Start a program" in the drop-down.
	13.	Click "Browse..." to navigate to the folder where you cloned the repository and select the **<code>wsl\_dev\_startup.cmd</code>** file.
	14.	Click "OK".
	15.	Swith over to the "Conditions" tab and uncheck "Stop if the computer switches to battery power" and then "Start the task only if the computer is on AC power"
	16.	Click "OK".
	
	You have successfully created the startup task for the script. 

3.	Create a shortcut to manually start the task. This is optional but is recommended if you want to make it easily accessible to run the script again in a current session. <br>
	To achieve this, you need to:

	1. Right-click on an empty section of your desktop and select New->Shortcut
	2. Enter the following into the item location, making sure to replace **Scripts** and **WSL-Dev-Startup** with the folder name and task name you used when creating the task earlier:

			schtasks /run /tn "Scripts\WSL-Dev-Startup"
	3. Click "Next"
	4. Give the shortcut a name and click "Finish"

	Now you can copy or pin this shortcut to wherever you like, such as your start menu or task bar, to easily launch the script.

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

The text files contain chunks of a hosts file that you want copied over to the Windows hosts file. The **<code>host-array.example.ps1</code>** contains an object array consisting of hosts (typically virtual hosts/sites configured in your Apache and/or Nginx web servers) that you want to map to the WSL IP. You can use this array to specify comment lines as well. 

### <code>\includes</code>
The **<code>\includes</code>** folder contains various functions, utilities, configurations, and services. We'll go through the purpose of each of them:

#### <code>colors.ps1</code>
This file runs the commands necessary to build the Windows host file. Certain parameters of these commands need to match your configurations and variable values. You can use this file as a guide and remove or add commands to fit your needs.

#### <code>import-hosts.ps1</code>
This file runs the commands necessary to build the Windows host file. Certain parameters of these commands need to match your configurations and variable values. You can use this file as a guide and remove or add commands to fit your needs.

#### <code>network-config.ps1</code>
This file serves to add network configurations to the environment. I currently have two commands in this file that uses **<code>netsh</code>** to assign static IP's for the Apache and Nginx servers in the WSL distro via proxy service. This is useful for running multiple apps using different services over different IP's.

#### <code>utilities.ps1</code>
This file contains a small collection of utilities used throughout the script. The included functions so far include:

*	**<code>SleepProgress</code>**: Displays a progress bar which can be set to a time in seconds.
*	**<code>StyleOutput</code>**: Specify styling of the terminal output.
*	**<code>Pause</code>**: Creates a "pause" that waits for a user key-press before continuing to the next line of the script, similar to that found in MSDOS, with customizable output message.
*	**<code>PrintHostArray</code>**: A trouble-shooting utility to display the values of the **<code>host-array.example.ps1</code>** file. 

#### <code>variable-definitions.ps1</code>
This file contains variables for paths, files, arrays, and string used in various configurations and functions that are frequently used throughout the script. There is only one variable that is defined outside of this script, and that is the $inc_path variable which is required by the root **<code>wsl\_dev\_startup.ps1</code>** file before we can import this **<code>variable-definitions.ps1</code>** file.

#### <code>wsl-hosts.ps1</code>
This contains functions for adding and removing hosts to the Windows hosts file that are mapped to either the native WSL distro IP or to the static IP's defined in the **<code>network-config.ps1</code>** file mentioned earlier. The host values used by these functions are stored in an object array defined in the  **<code>\host-parts\host-array.example.ps1</code>** file.

#### <code>wsl-services.ps1</code>
This file contains the commands to start the needed WSL services. Currently the only services included in this file are Apache and MySQL. 

---

#### Notes
*	Use the example files and the comments found throughout the source-code to better understand how these files work together.

## Planned Features/Updates
*	Replacing "dot sourced" include files with custom PowerShell modules that include additional functions. 
*	Improving upon the source-code comments.
