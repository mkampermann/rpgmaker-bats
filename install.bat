@echo off

set PROJECT_FOLDER_NAME=project
set PROPERTIES_NAME=install.properties
set REGKEY=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam
set REGVALUE=InstallPath
set HELP_PAGE_URL=https://aerosys.blog/minimal-rpg-maker-projects

For /F "eol=# tokens=1* delims==" %%A IN (%PROPERTIES_NAME%) DO (
    if %%A==supported_engines   set SUPPORTED_ENGINES=%%B
    if %%A==mv.version          set MV_VERSION=%%B
    if %%A==mz.version          set MZ_VERSION=%%B
    if %%A==project.name        set OUTPUT_FOLDER_NAME=%%B
)

if  "%OUTPUT_FOLDER_NAME%"=="" (echo The developer did not provided a project name in properties & start "" %HELP_PAGE_URL% & pause & exit /b 1)

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
set RTP_PATH_RIGHT=\steamapps\common\RPG Maker MV\NewData
set OUTPUT_FOLDER_NAME=%OUTPUT_FOLDER_NAME% RMMV
set PROJECT_FILE_NAME=Game.rpgproject
set PROJECT_FILE_CONTENT=RPGMV %MV_VERSION%
goto Step2

:MZ
set RTP_PATH_RIGHT=\steamapps\common\RPG Maker MZ\newdata
set OUTPUT_FOLDER_NAME=%OUTPUT_FOLDER_NAME% RMMZ
set PROJECT_FILE_NAME=game.rmmzproject
set PROJECT_FILE_CONTENT=RPGMZ %MZ_VERSION%
goto Step2

:Step2
reg query %REGKEY% /v %REGVALUE% 2>nul || (echo Steam not found & start "" %HELP_PAGE_URL% & pause & exit /b 1)

set RTP_PATH=
for /f "tokens=2,*" %%a in ('reg query %REGKEY% /v %REGVALUE% ^| findstr %REGVALUE%') do (
    set RTP_PATH=%%b%RTP_PATH_RIGHT%
)

if not exist "%RTP_PATH%" (echo Default Resources not found, checked here: "%RTP_PATH%" & start "" %HELP_PAGE_URL% & pause & exit /b 1)

xcopy "%RTP_PATH%" "%OUTPUT_FOLDER_NAME%" /i /s /y
xcopy "%PROJECT_FOLDER_NAME%" "%OUTPUT_FOLDER_NAME%" /i /s /y

echo Create %PROJECT_FILE_NAME%
@echo %PROJECT_FILE_CONTENT% > "%OUTPUT_FOLDER_NAME%/%PROJECT_FILE_NAME%"

echo finished successfully!
pause