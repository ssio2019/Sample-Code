################################################################################
##
## SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
##
## © 2019 MICROSOFT PRESS
##
################################################################################
##
## CHAPTER 9: AUTOMATING SQL SERVER ADMINISTRATION
## POWERSHELL SAMPLE 1

#On an online machine:
Save-Module -Name SQLSERVER -LiteralPath "c:\temp\"

#On the offline machine:
$env:PSModulePath.replace(";","`n")

# Copy the folder

Import-Module SQLSERVER

# Verify
Get-Module -ListAvailable -Name '*SQL*' | Select-Object Name, Version, RootModule
