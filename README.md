User Migration Tool Wrapper 3.4 

Overview 

This script facilitates backing up and restoring user profiles remotely using USMT and PsExec. It includes privilege escalation handling, error checking, and automated retries. 

Prerequisites 

  *  Ensure C:/tmp/PsExec.exe is present, or the script will not function. [https://learn.microsoft.com/en-us/sysinternals/downloads/psexec](url)
  *  PsKill.exe should be in C:/tmp for remote process termination. 
  *  USMT tools should be accessible on the network. [https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install](url)

Features 

  *  Elevates privileges via UAC prompt. 
  *  Backs up user profiles from a remote machine. 
  *  Restores user profiles to a new machine. 
  *  Closes remote migration processes. 

Usage 

Running the Script 

    Run the batch script as an administrator. 
    Choose an option: 
    (1) Backup Profile 
    (2) Restore Profile 
    (3) Close a Remote Migration Process 

Backup Process 

  *  Enter the name or IP address of the PC to back up. 
  *  Select the user profiles to back up. 
  *  The script will: 
  *  Check connectivity. 
  *  Generate a remote backup script. 
  *  Execute scanstate.exe remotely. 
  *  Clean up temporary files. 

Restore Process 

  *  Enter the name or IP address of the destination PC. 
  *  Select the user profiles to restore. 
  *  The script will: 
  *  Check connectivity. 
  *  Generate a remote restore script. 
  *  Execute loadstate.exe remotely. 
  *  Clean up temporary files. 

Closing Remote Migration Processes 

  *  Enter the name or IP address of the target PC. 
  *  The script will terminate scanstate and loadstate processes remotely. 

Error Handling 

  *  The script checks for network availability before proceeding. 
  *  If authentication fails, it retries automatically. 
  *  Logs are generated in the profile save location for debugging. 

Notes 
 
  *  Modify the domain name and paths as needed before running the script. 

Author 

RedneckGamer88 

    Last updated: 02/26/2025 
 
