REM /** batch programiranje: backup **/
REM /** ================================================ **/
REM /** Avtor: Samuel Perovsek **/
REM /** Skripta batch za ustvarjanje varostne kopije **/
REM /** Namen: Koncni izdelek za PUD **/
REM /** ================================================ **/
@echo off

REM Izvedemo powershell skript za šifriranje gesla
start /wait c:\backup\sifriranje.exe

set DB_USER=admsamuel
set DB_NAME=cvetlicarnadb

REM Preberemo pass.txt file
for /f "tokens=1,* delims==" %%i in (c:\backup\pass.txt) do (
    if /I "%%i"=="DB_PASSWORD" set DB_PASS=%%j
)

REM Dešifriramo Base64 šifrirano geslo
set "sifrirano_geslo=%DB_PASS%"
for /f "delims=" %%a in ('powershell -command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%sifrirano_geslo%'))"') do set "DB_PASS=%%a"

REM Direktori kjer bo backup shranjen
set BACKUP_DIR="C:\backup"

REM Generiramo časovni žig v formatu YYYYMMDD_HHMMSS
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set datetime=%%a
set timestamp=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%

REM poimenujemo backup file z časovnim žigom
set BACKUP_FILE=%BACKUP_DIR%\%DB_NAME%_backup_%timestamp%.sql

REM pot do mysqldump.exe 
set MYSQLDUMP_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"

REM prepričamo se da direktori obstaja
if not exist %BACKUP_DIR% mkdir %BACKUP_DIR%

REM Ustvarimo datoteko za log
set LOG_FILE=%BACKUP_DIR%\ukm_backup_log.txt

REM Logiramo začetek backupa
echo %date% %time% - Začetek backupa >> %LOG_FILE%

REM dump se izvede
%MYSQLDUMP_PATH% -u%DB_USER% -p%DB_PASS% %DB_NAME% > %BACKUP_FILE%

REM preverimo konec skripte
if %errorlevel% neq 0 (
    echo %date% %time% - Napaka: Backup se ni izvedel uspešno. >> %LOG_FILE%
pause
) else (
    echo %date% %time% - Backup se je izvedel uspešno. Datoteka je shranjena v %BACKUP_FILE% >> %LOG_FILE%
)

type nul > "c:\backup\pass.txt"