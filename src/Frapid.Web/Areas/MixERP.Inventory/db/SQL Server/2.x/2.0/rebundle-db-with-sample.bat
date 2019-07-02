@echo off
bundler\SqlBundler.exe ..\..\..\..\ "db/SQL Server/2.x/2.0" true
copy inventory.sql inventory-sample.sql
del inventory.sql
copy inventory-sample.sql ..\..\inventory-sample.sql