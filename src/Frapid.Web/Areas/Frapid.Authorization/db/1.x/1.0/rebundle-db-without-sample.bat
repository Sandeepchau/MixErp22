@echo off
bundler\SqlBundler.exe ..\..\..\ "db/1.x/1.0" false
copy auth.sql auth-blank.sql
del auth.sql
copy auth-blank.sql ..\..\auth-blank.sql
pause