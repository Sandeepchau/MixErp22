@echo off
bundler\SqlBundler.exe ..\..\..\..\ "db/SQL Server/2.x/2.0" false
copy inventory.sql inventory-blank.sql
del inventory.sql
copy inventory-blank.sql ..\..\inventory-blank.sql