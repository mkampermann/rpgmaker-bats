@echo off

set PROJECT_FOLDER_NAME=project
set PROPERTIES_NAME=install.properties
set REGKEY_STEAM=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam
set REGVALUE_STEAM=InstallPath
set REGKEY_KADOKAWA_MZ=HKEY_LOCAL_MACHINE\SOFTWARE\KADOKAWA\RPGMZ
set REGKEY_KADOKAWA_MV=HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\KADOKAWA\RPGMV
set REGVALUE_KADOKAWA=ApplicationPath
set HELP_PAGE_URL=https://aerosys.blog/minimal-rpg-maker-projects

For /F "eol=# tokens=1* delims==" %%A IN (%PROPERTIES_NAME%) DO (
    if %%A==supported_engines   set SUPPORTED_ENGINES=%%B
    if %%A==mv.version          set MV_VERSION=%%B
    if %%A==mz.version          set MZ_VERSION=%%B
    if %%A==project.name        set OUTPUT_FOLDER_NAME=%%B
)

if "%OUTPUT_FOLDER_NAME%"=="" (echo The developer did not provided a project name in properties & start "" %HELP_PAGE_URL% & pause & exit /b 1)

if /I "%SUPPORTED_ENGINES%"=="both" goto ask
if /I "%SUPPORTED_ENGINES%"=="mv"   goto MV
if /I "%SUPPORTED_ENGINES%"=="mz"   goto MZ
(echo The developer enabled neither MV nor MZ & start "" %HELP_PAGE_URL% & pause & exit /b 1)

:ask
set /p RPG_MAKER_LETTER=What is your RPG Maker Engine? Choose from M[V] or M[Z]:
if /I "%RPG_MAKER_LETTER%"=="v" goto MV
if /I "%RPG_MAKER_LETTER%"=="z" goto MZ
echo Please type only the letter V or Z & goto ask

:MV
set ENGINE=MV
set RTP_PATH_RIGHT=\steamapps\common\RPG Maker MV\NewData
set OUTPUT_FOLDER_NAME=%OUTPUT_FOLDER_NAME% RMMV
set PROJECT_FILE_NAME=Game.rpgproject
set PROJECT_FILE_CONTENT=RPGMV %MV_VERSION%
goto get_rtp_from_steam

:MZ
set ENGINE=MZ
set RTP_PATH_RIGHT=\steamapps\common\RPG Maker MZ\newdata
set OUTPUT_FOLDER_NAME=%OUTPUT_FOLDER_NAME% RMMZ
set PROJECT_FILE_NAME=game.rmmzproject
set PROJECT_FILE_CONTENT=RPGMZ %MZ_VERSION%
goto get_rtp_from_steam

:get_rtp_from_steam
reg query %REGKEY_STEAM% /v %REGVALUE_STEAM% 2>nul || goto get_rtp_from_kadokawa

set RTP_PATH=
for /f "tokens=2,*" %%a in ('reg query %REGKEY_STEAM% /v %REGVALUE_STEAM% ^| findstr %REGVALUE_STEAM%') do (
    set RTP_PATH=%%b%RTP_PATH_RIGHT%
)
if exist "%RTP_PATH%" goto copy_files

:get_rtp_from_kadokawa
if %ENGINE%==MV goto kadokawa_mv
if %ENGINE%==MZ goto kadokawa_mz

:kadokawa_mv
reg query %REGKEY_KADOKAWA_MV% /v %REGVALUE_KADOKAWA% 2>nul || (echo RPG Maker not found & start "" %HELP_PAGE_URL% & pause & exit /b 1)
set RTP_PATH=
for /f "tokens=2,*" %%a in ('reg query %REGKEY_KADOKAWA_MV% /v %REGVALUE_KADOKAWA% ^| findstr %REGVALUE_KADOKAWA%') do (
    set RTP_PATH=%%b\NewData
)
if exist "%RTP_PATH%" goto copy_files
if not exist "%RTP_PATH%" (echo RPG Maker not found & start "" %HELP_PAGE_URL% & pause & exit /b 1)

:kadokawa_mz
reg query %REGKEY_KADOKAWA_MZ% /v %REGVALUE_KADOKAWA% 2>nul || (echo RPG Maker not found & start "" %HELP_PAGE_URL% & pause & exit /b 1)
set RTP_PATH=
for /f "tokens=2,*" %%a in ('reg query %REGKEY_KADOKAWA_MZ% /v %REGVALUE_KADOKAWA% ^| findstr %REGVALUE_KADOKAWA%') do (
    set RTP_PATH=%%b\newdata
)
if exist "%RTP_PATH%" goto copy_files
if not exist "%RTP_PATH%" (echo RPG Maker not found & start "" %HELP_PAGE_URL% & pause & exit /b 1)


:copy_files
xcopy "%RTP_PATH%" "%OUTPUT_FOLDER_NAME%" /i /s /y
xcopy "%PROJECT_FOLDER_NAME%" "%OUTPUT_FOLDER_NAME%" /i /s /y

echo Create %PROJECT_FILE_NAME%
@echo %PROJECT_FILE_CONTENT% > "%OUTPUT_FOLDER_NAME%/%PROJECT_FILE_NAME%"

echo finished successfully!
pause