#Execute the below in PowerShell
Install-Module -Name SqlServer -AllowClobber -Force

Get-SqlInstance -ServerInstance . | Invoke-SqlAssessment | Out-GridView

Get-SqlInstance -ServerInstance servername | Invoke-SqlAssessment -Configuration "C:\toolbox\sqlassessment_api_config.json" | Out-GridView