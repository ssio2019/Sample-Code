REM To check the file unit allocation size for an NT File System (NTFS) volume, 
REM run the following from the Administrator: Command Prompt, repeating for each volume:

Fsutil fsinfo ntfsinfo d:

REM The file unit allocation size is returned with the Bytes Per Cluster; thus the desired 64 KB would be displayed as 65,536 (bytes). 
REM If formatted as the default, this will display 4096. 
REM Correcting the file unit allocation size requires formatting the drive, so it is important to check this setting prior to installation.