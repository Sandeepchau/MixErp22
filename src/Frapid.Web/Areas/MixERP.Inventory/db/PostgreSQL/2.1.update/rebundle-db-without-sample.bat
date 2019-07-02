@echo off
bundler\SqlBundler.exe ..\..\..\ "db/PostgreSQL/2.1.update" false
copy inventory-2.1.update.sql ..\inventory-2.1.update.sql