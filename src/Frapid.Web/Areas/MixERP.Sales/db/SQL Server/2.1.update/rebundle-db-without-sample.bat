@echo off
bundler\SqlBundler.exe ..\..\..\ "db/SQL Server/2.1.update" false
copy sales-2.1.update.sql ..\sales-2.1.update.sql