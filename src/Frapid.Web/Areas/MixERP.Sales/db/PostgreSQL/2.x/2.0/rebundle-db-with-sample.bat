@echo off
bundler\SqlBundler.exe ..\..\..\..\ "db/PostgreSQL/2.x/2.0" true
copy sales.sql sales-sample.sql
del sales.sql
copy sales-sample.sql ..\..\sales-sample.sql