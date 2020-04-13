################################################################################
#
# SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
#
# © 2019 MICROSOFT PRESS
#
################################################################################
#
# CHAPTER 5: PROVISIONING AZURE SQL DATABASE
# POWERSHELL CORE SAMPLE
#
# Change me
$subscriptionName = "Pay-As-You-Go"

# These next two lines are from Chapter 3B
Install-Module Az -AllowClobber
Update-Module Az

# Log in to your Azure account (using device login)
Login-AzAccount
# List your subscriptions
# Copy and paste the name of one subscription in line 13
Get-AzSubscription
Select-AzSubscription -SubscriptionName $subscriptionName

# Change me
$resourceGroupName = "SSIO2019"
$location = "southcentralus"

# Create a new resource group in the current subscription
New-AzResourceGroup -ResourceGroupName $resourceGroupName `
    -Location $location

################################################################################
# CREATING
################################################################################

$serverName = $resourceGroupName.ToLower()
$Cred = Get-Credential -UserName dbadmin -Message "Password for server admin"
# Create a logical SQL Server
New-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $location -SqlAdministratorCredentials $Cred

$databaseName = "Contoso"
# Create a database on the new server
New-AzSqlDatabase -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -DatabaseName $databaseName -Edition Standard `
    -RequestedServiceObjectiveName "S0" -CollationName Latin1_General_CI_AS

# Retrieve details of the new database
Get-AzSqlDatabase -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -DatabaseName $databaseName

# Create a new elastic pool
$poolName = "Contoso-Pool"
New-AzSqlElasticPool -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -ElasticPoolName $poolName `
    -Edition "Standard" -Dtu 50 `
    -DatabaseDtuMin 10 -DatabaseDtuMax 20
# Move the database to the new elastic pool
Set-AzSqlDatabase -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -DatabaseName $databaseName `
    -ElasticPoolName $poolName

# Move the database out of the elastic pool, back to its previous service tier
Set-AzSqlDatabase -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -DatabaseName $databaseName `
    -RequestedServiceObjectiveName "S0"

################################################################################
# AUDITING A SINGLE DATABASE
################################################################################

# Create your own globally unique storage account name
$storageAccountName = "azuresqldbaudit"
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName -Location $location -Kind Storage `
    -SkuName Standard_LRS -EnableHttpsTrafficOnly $true
$auditSettings = Set-AzSqlDatabaseAudit `
	-ResourceGroupName $resourceGroupName `
	-ServerName $serverName -DatabaseName $databaseName `
	-StorageAccountResourceId $storageAccount.Id -StorageKeyType Primary `
    -RetentionInDays 365 -BlobStorageTargetState Enabled

################################################################################
# EXPORTING
################################################################################
	
# Create a name for the database copy
$d = (Get-Date).ToUniversalTime()
$databaseCopyName = "$databaseName-Copy-" + ($d.ToString("yyyyMMddHHmmss"))
# The storage account name must be globally unique; replace it with your own name
$storageAccountName = "azuresqldbexport"
# Ask interactively for the server admin login username and password
$cred = Get-Credential -Message "Enter the database admin username and password"

# Create a new Azure storage account
$storAcct = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName -Location $location `
    -SkuName Standard_LRS
# Get the access keys for the newly created storage account
$storageKey = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName
# Create a database copy - this copy will have the same service tier as the original
# If your database is an elastic pool, add the -ElasticPoolName parameter
$newDB = New-AzSqlDatabaseCopy -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -DatabaseName $databaseName `
    -CopyDatabaseName $databaseCopyName

# Prepare additional variables to use as the storage location for the BACPAC
$containerName = "mydbbak"
$container = New-AzStorageContainer -Context $storAcct.Context -Name $containerName
$bacpacUri = $container.CloudBlobContainer.StorageUri.PrimaryUri.ToString() + "/" + `
    $databaseCopyName + ".bacpac"

# Create a new firewall rule to allow access from the export infrastructure
$fwRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -AllowAllAzureIPs

# Begin the database export to Azure blob storage
$exportRequest = New-AzSqlDatabaseExport –ResourceGroupName $resourceGroupName `
    –ServerName $NewDB.ServerName –DatabaseName $databaseCopyName `
    –StorageKeytype StorageAccessKey –StorageKey $storageKey[0].Value `
    -StorageUri $bacpacUri `
    –AdministratorLogin $cred.UserName –AdministratorLoginPassword $cred.Password

Do {
    $exportStatus = Get-AzSqlDatabaseImportExportStatus `
        -OperationStatusLink $ExportRequest.OperationStatusLink
    Write-Host "Exporting... sleeping for 5 seconds..."
    Start-Sleep -Seconds 5
} While ($exportStatus.Status -eq "InProgress")

# Delete the database copy to avoid further charges
Remove-AzSqlDatabase –ResourceGroupName $resourceGroupName `
    –ServerName $serverName –DatabaseName $databaseCopyName
# Delete the firewall rule
Remove-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $serverName -FirewallRuleName $fwRule.FirewallRuleName