@echo off
bundler\SqlBundler.exe ..\..\..\..\..\ "db/SQL Server/2.x/2.0/db" false
copy hrm.sql hrm-blank.sql
del hrm.sql
copy hrm-blank.sql ..\..\hrm-blank.sql