@echo off
bundler\SqlBundler.exe ..\..\..\..\ "db/SQL Server/2.x/2.0" false
copy sales.sql sales-blank.sql
del sales.sql
copy sales-blank.sql ..\..\sales-blank.sql