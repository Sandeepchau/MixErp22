@echo off
bundler\SqlBundler.exe ..\..\..\ "db/SQL Server/2.1.update" false
copy hrm-2.1.update.sql ..\hrm-2.1.update.sql