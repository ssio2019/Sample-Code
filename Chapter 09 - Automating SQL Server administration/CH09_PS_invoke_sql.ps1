################################################################################
##
## SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
##
## © 2019 MICROSOFT PRESS
##
################################################################################
##
## CHAPTER 9: AUTOMATING SQL SERVER ADMINISTRATION
## POWERSHELL SAMPLE 4

#1
Invoke-Sqlcmd -Database master -ServerInstance .\sql2k19 `
	-Query "SELECT * FROM sys.dm_exec_sessions" | `
	Format-Table | Out-File -FilePath "C:\Temp\Sessions.txt" -Append 

#2
Invoke-Sqlcmd -Database master -ServerInstance azure-databasename.database.windows.net `
    -Username user -Password 'strongpassword' `
    -Query "SELECT * FROM sys.dm_exec_sessions" | `
    Format-Table | Out-File -FilePath "C:\Temp\Sessions.txt" -Append

#3
Invoke-Sqlcmd -Database master -ServerInstance .\sql2k19 `
	-Query "SELECT * FROM sys.dm_exec_sessions" | `
	Out-GridView
