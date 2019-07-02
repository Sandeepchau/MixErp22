@echo off
bundler\SqlBundler.exe ..\..\..\ "db/SQL Server/2.1.update" false
copy inventory-2.1.update.sql ..\inventory-2.1.update.sql