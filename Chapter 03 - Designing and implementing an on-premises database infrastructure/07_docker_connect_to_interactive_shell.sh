#!/bin/bash
sudo docker exec -it sql1 "/bin/bash"

# once connected, run this from the connected shell
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourNewStrong!Passw0rd>'
