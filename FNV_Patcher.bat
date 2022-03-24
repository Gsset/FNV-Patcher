@echo off
setlocal EnableDelayedExpansion
title Fallout New Vegas Patcher

if exist !PROGRAMFILES(X86)! set bitness=64 || set bitness=32

:Admin_permissions
>nul 2>&1 %SYSTEMROOT%\system32\icacls.exe %SYSTEMROOT%\system32\WDI
if %errorlevel% EQU 0 cd /d %~dp0 && goto :Variables
echo.Запрос прав администратора...
echo.Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo.UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %bitness:"=""%", "", "runas", 1 >> %temp%\getadmin.vbs
%temp%\getadmin.vbs
del /f /q %temp%\getadmin.vbs
exit

:Variables
for /f "delims=" %%a in ('powershell -Command "& {Get-ItemProperty -Path '"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"' -Name Personal | Select-Object -ExpandProperty Personal}"') do set docs=%%a
if %bitness%==64 (set 7z_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/7za_64.exe
set curl_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/curl_64.zip)
if %bitness%==32 (set 7z_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/7za_32.exe
set curl_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/curl_32.zip)
if exist Tools\ok.txt (set first_run=0) else (set first_run=1)
set "echo=echo.&&echo."
set zip="%~dp0Tools\7z.exe"
set curl="%~dp0Tools\curl.exe"
set error_download=echo.Ошибка скачивания
set error_unpack=echo.Ошибка распаковки

if %first_run%==0 goto :Main

:Tools
CLS
if exist Tools rmdir /s /q Tools
mkdir Tools
if exist Mods rmdir /s /q Mods
mkdir Mods
%echo%Скачивание утилит и модов...
echo.
powershell -Command "& {Invoke-WebRequest !curl_link! -outfile Tools\curl.zip}" || %error_download% curl && pause>nul && goto Tools
powershell -Command "& {Invoke-WebRequest !7z_link! -outfile Tools\7z.exe}"     || %error_download% 7zip && pause>nul && goto :Tools
%zip% e "Tools\curl.zip" -o"Tools\">nul || %error_unpack% curl && pause>nul && goto :Tools
%curl% -L -o %~dp0Mods\Mods.7z https://github.com/Gsset/FNV-Patcher/releases/download/mods_v2/Mods.7z || %error_download% модов && pause>nul && goto Tools
%zip% x "%~dp0Mods\Mods.7z" -o"Mods\"
del /f /q Mods\Mods.7z
del /f /q Tools\curl.zip
echo Che smotrish?>Tools\ok.txt
%echo%Успешно.

:Main
CLS
%echo%Введите полный путь до папки с игрой:
echo.
set /p fnv_path=
(setx fnv_path "%fnv_path%")>nul
CLS
%echo%Копирование файлов...
(robocopy Mods "%fnv_path%" /s)>nul
>nul move "%fnv_path%\Fallout.ini" "%docs%\My Games\FalloutNV"
%echo%Правка ini-файлов...
powershell -Command "& {Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Gsset/FNV-Patcher/main/threading.ps1' | Invoke-Expression}"
%echo%Установка порядка загрузки файлов...
>nul move "%fnv_path%\plugins.txt" "%userprofile%\appdata\Local\FalloutNV\plugins.txt"
powershell -Command "& {Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Gsset/FNV-Patcher/main/load_order.ps1' | Invoke-Expression}"
%echo%Применение модов... (нажмите пробел дважды)
cd /d !fnv_path!
>nul FNVpatch.exe
cd /d %~dp0
powershell -Command "& {Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Gsset/FNV-Patcher/main/nvhr.ps1' -outfile %~dp0\nvhr.ps1}"
powershell -file %~dp0\nvhr.ps1
%echo%Декомпрессия ресурсов игры... (выполните операцию и дождитесь ее окончания)
"%fnv_path%\FNV BSA Decompressor.exe"
(copy Mods\libvorbisfile.dll "%fnv_path%"
copy Mods\libvorbis.dll "%fnv_path%")>nul
%echo%Удаление лишних файлов...
cd /d !fnv_path!
if exist "Data\*_lang.esp" (del /f /q Data\*_lang.esp)>nul
(del /f /q FNVpatch.exe
del /f /q bass*.dll
del /f /q "FNV BSA Decompressor.*"
del /f /q xdelta3.dll
del /f /q FalloutNV_backup.exe
del /f /q cpu_info.exe
del /f /q %~dp0\nvhr.ps1
rmdir /s /q AVX
rmdir /s /q AVX2
rmdir /s /q AVX512
rmdir /s /q IA32
rmdir /s /q SSE
rmdir /s /q SSE2
REG delete "HKCU\Environment" /F /V "fnv_path")>nul
%echo%Завершено.
pause>nul&&exit
