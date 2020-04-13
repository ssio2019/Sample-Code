# This script is for Linux. See the chapter for more information about macOS.
#!/bin/bash
sudo docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=<YourStrong!Passw0rd>' \
   -p 1433:1433 --name sql2019 \
   -v /users/randolph/mssql:/mssql \
   -d mcr.microsoft.com/mssql/server:2019-latest
