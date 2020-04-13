#Enable the TCPIP protocol for a local SQL Server instance.
Import-Module SqlServer
$wmi = new-object('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer')
#Path to the local server.
$path = "ManagedComputer[@Name='$env:COMPUTERNAME']/"
$path = $path+"ServerInstance[@Name='SQL2K19']/ServerProtocol[@Name='Tcp']"
#Enable the TCP protocol on the local server, on the named instance SQL2K19.
$TCPIP = $wmi.GetSmoObject($path)
$TCPIP.IsEnabled = $true  
$TCPIP.Alter()  
$TCPIP.IsEnabled
#Restart SQL Server Database Engine service to apply the change
