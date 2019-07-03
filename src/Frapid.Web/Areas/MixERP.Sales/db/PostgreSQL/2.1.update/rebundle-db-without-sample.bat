@echo off
bundler\SqlBundler.exe ..\..\..\ "db/PostgreSQL/2.1.update" false
copy sales-2.1.update.sql ..\sales-2.1.update.sql