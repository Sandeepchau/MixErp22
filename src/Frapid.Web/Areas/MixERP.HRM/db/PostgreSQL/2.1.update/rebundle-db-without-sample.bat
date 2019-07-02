@echo off
bundler\SqlBundler.exe ..\..\..\ "db/PostgreSQL/2.1.update" false
copy hrm-2.1.update.sql ..\hrm-2.1.update.sql