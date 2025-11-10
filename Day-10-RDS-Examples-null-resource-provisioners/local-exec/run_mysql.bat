@echo off
REM %1 = RDS endpoint passed from Terraform
echo Running SQL script on RDS instance %1 ...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -h %1 -u admin -pAdmin1234 mydb < init.sql
