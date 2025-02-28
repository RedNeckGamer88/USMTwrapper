@echo off
setlocal EnableDelayedExpansion

:init
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' (
    goto gotPrivileges
) else (
    goto getPrivileges
)

:getPrivileges
if '%1'=='ELEV' (
    echo ELEV
    shift /1
    goto gotPrivileges
)
echo.
echo **************************************
echo Invoking UAC for Privilege Escalation
echo **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (
    del "%vbsGetPrivileges%" 1>nul 2>nul
    shift /1
)
::********************************************************
:start
@echo off
timeout /T 2 /NOBREAK > nul

::Random text color script for fun :^)
@echo off
:generateColor
Set /a num=(%Random% %% 7) + 1
if %num% equ 7 goto generateColor
if %num% equ 8 goto generateColor
color 0%num%
::
echo """""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "               (        *                              "  
echo "              )\ )   (  `      *   )                   " 
echo "         (   (()/(   )\))(   ` )  /(                   " 
echo "         )\   /(_)) ((_)()\   ( )(_))                  " 
echo "       _ ((_) (_))   (_()((_) (_(_())                  "  
echo "     | | | | / __|  |  \/  | |_   _|                   "  
echo "     | |_| | \__ \  | |\/| |   | |                   	"  
echo "      (__(/  |___/  |_|  |_|   |_|                     " 
echo "  )\))(   ' (        )                     (    (    	"
echo " ((_)()\ )  )(    ( /(   `  )    `  )     ))\   )(   	"
echo " _(())\_)()(()\   )(_))  /(/(    /(/(    /((_) (()\  	"
echo " \ \((_)/ / ((_) ((_)_  ((_)_\  ((_)_\  (_))    ((_) 	"
echo "  \ \/\/ / | '_| / _` | | '_ \) | '_ \) / -_)  | '_| 	"
echo "   \_/\_/  |_|   \__,_| | .__/  | .__/  \___|  |_|   	"
echo "                      |_|     |_|                  	"
echo """"""""""""""""""""""""""""""""""""""""""""""""""""""""                                                                                                    
echo **********User Migration Tool Wrapper3.4*************
echo *****************By RedneckGamer88*******************
echo **************Last updated 02/26/2025****************
echo.
echo Make sure you have C:/tmp/PsExec.exe or this will not work
echo .
echo .
echo (1) Backup Profile?
echo (2) Restore Profile?
echo (3) Close a Remote Migration Process?

CHOICE /C:123

IF ERRORLEVEL 3 (
    GOTO CLOSE
) ELSE IF ERRORLEVEL 2 (
    GOTO RESTORE
) ELSE IF ERRORLEVEL 1 (
    GOTO BACKUP
)

:BACKUP
color 17

:: Domain Name
:: set mydomain=SH
set mydomain=md
:: User name( this is only needed if you are running in the "Terminal App"
::set USERNAME=gad12345

:: The network location of USMT tools.
:: example set networklocationUSMT=\\sh.locol\mydept\IT\profilemigrationUSMT\amd64, the pushd command will be using this to add a network drive
set networklocationUSMT=\\md.local\path\to\my\profilemigrationUSMT\amd64\

:: The network drive letter of where the profiles will be saved. This might be somewhat complex, but it is what you can see in cmd after you pushd a networklocation.
:: example set set profilesavelocation=Z:\IT\adminhome\profilemigrationUSMT\Profile
set profilesavelocation=Z:\mydrive\path\to\my\profilemigrationUSMT\Profile

::scanstate options and .xml
set "scanstateoptions=/efs:copyraw /i:MigUser_Including_Downloads.xml /i:MigApp.xml /i:ExcludeSystemFolders.xml /i:Win10StickyNotes.xml /i:printers.xml /i:AdobeSettings.xml /o /c /vsc"

cls
echo ********************************************
echo ********** BACKUP USER PROFILE! ************
echo ********************************************	

echo Name or IP addresss of the PC you are backing up?
set /p oldpc="oldpc:"

:: Check if the PC is reachable using ping
ping -n 1 %oldpc% >nul
if errorlevel 1 (
    echo The PC %oldpc% is not reachable.
    goto :start
)

:: Makes sure there is a tmp folder on the remote pc, then goes to it. Also deletes old bat if there is one
::pushd "\\%oldpc%\c$"
pushd \\%oldpc%\c$
md tmp 2>nul
cd tmp
del backupuser.bat 2>nul

echo Here are the users that are currently logged in.
query user /server:%oldpc%

echo Here are the users who have logged into this Computer.
dir /ad /b \\%oldpc%\c$\Users

echo The User Profile(s) you are backing up (comma-separated)? Leave blank to startover.
set /p userprofiles="userprofiles:"

:: Check if userprofiles is provided
if "%userprofiles%"=="" (
    echo No userprofiles provided. Returning to the beginning.
    timeout /t 1 /nobreak >nul
    goto :start
)
:: This generates the custom bat file in the tmp folder on the remote PC
(
    echo @echo off
    echo pushd %networklocationUSMT%
    echo mkdir %profilesavelocation%
    for %%u in (%userprofiles%) do (
        echo scanstate.exe %profilesavelocation%\%%u /v:13 /ue:*\* /ui:%mydomain%\%%u %scanstateoptions% /l:%profilesavelocation%\%%u\scanstate.log
    )
    echo exit
) > backupuser.bat

timeout /T 2 /NOBREAK

popd
cd /tmp
::login
@echo off
setlocal

:LOOP1
:: Execute the backupuser.bat remotely using PsExec
PsExec.exe -e \\%oldpc% -i -u %mydomain%\%USERNAME% -h -w C:\tmp cmd.exe /c "backupuser.bat"

:: Check the exit code of PsExec.exe
if %errorlevel% equ 0 (
    echo Backup Complete.
    goto :CLEANUP1
) else if %errorlevel% equ 3 (
    echo Backup Complete.
    goto :CLEANUP1
) else (
    echo Password verification failed. Retrying...
    timeout /t 5 >nul
    goto :LOOP1
)

:CLEANUP1
:: Cleanup bat file
pushd \\%oldpc%\c$\tmp
del backupuser.bat
popd
goto :END1

:END1

endlocal
:: Change screen color
color DF
:: Play chimes when complete  (sometimes working), does't work in my terminal app
set soundfile=C:\Windows\Media\chimes.wav
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "(New-Object Media.SoundPlayer '%soundfile%').PlaySync();"

pause
goto :start

:RESTORE
color C7
:: Domain Name
:: set mydomain=SH
set mydomain=md
:: User name( this is only needed if you are running in the "Terminal App".
::set USERNAME=xzx12345

:: The network location of USMT tools.
set networklocationUSMT=\\md.local\path\to\my\profilemigrationUSMT\amd64\

:: The nework location of USMT profiles (so you can see a list of profiles)
:: example set networklocationUSMT=\\sh.locol\mydept\IT\profilemigrationUSMT\Profile
set networkprofileloc=\\md.local\path\to\my\profilemigrationUSMT\Profile

:: The network drive letter of where the profiles will be saved. This might be somewhat complex, but it is what you can see in cmd after you pushd a networklocation.
set profilesavelocation=Z:\mydrive\path\to\my\profilemigrationUSMT\Profile

::loadstate options and xml
set "loadstateoptions=/i:MigUser_Including_Downloads.xml /i:MigApp.xml /i:ExcludeSystemFolders.xml /i:Win10StickyNotes.xml /i:printers.xml /i:AdobeSettings.xml /c"

cls
echo **********************************************
echo ********* RESTORE USER PROFILE!! *************
echo **********************************************
@echo off

set /p newpc="Name or IP address of the PC you are restoring to: "

:: Check if the PC is reachable using ping
ping -n 1 %newpc% >nul
if errorlevel 1 (
    echo The PC %newpc% is not reachable.
    goto :start
)

:: Makes sure there is a tmp folder on the remote pc, then goes to it. Also deletes old bat if there is one
pushd "\\%newpc%\c$"
md tmp 2>nul
cd tmp
del restoreuser.bat 2>nul

echo Here are the users that you can restore:
dir /ad /b %networkprofileloc%

echo The User Profile(s) you are restoring (comma-separated)? Leave blank to startover.
set /p userprofiles="userprofiles:"

:: Check if userprofiles is provided
if "%userprofiles%"=="" (
    echo No userprofiles provided. Returning to the beginning.
    timeout /t 1 /nobreak >nul
    goto :start
)
:: This generates the custom bat file in the tmp folder on the remote PC
(
    echo @echo off
    echo pushd %networklocationUSMT%
    for %%u in (%userprofiles%) do (
        echo loadstate.exe %profilesavelocation%\%%u %loadstateoptions% /l:%profilesavelocation%\%%u\loadstate.log
    )
    echo exit
) > restoreuser.bat

timeout /T 2 /NOBREAK
popd
cd /tmp

::login
:LOOP2
:: Execute the restoreuser.bat remotely using PsExec
PsExec.exe -e \\%newpc% -i -u %mydomain%\%USERNAME% -h -w C:\tmp cmd.exe /c "restoreuser.bat"

:: Check the exit code of PsExec.exe
if %errorlevel% equ 0 (
    echo Restore Complete.
    goto :CLEANUP2
) else if %errorlevel% equ 3 (
    echo Restore Complete.
    goto :CLEANUP2
) else if %errorlevel% equ 5 (
    echo Restore Complete.
    goto :CLEANUP2
) else (
    echo Password verification failed. Retrying...
    timeout /t 5 >nul
    goto :LOOP2
)

:CLEANUP2
:: Cleanup bat file
pushd \\%newpc%\c$\tmp
del restoreuser.bat
popd
goto :END2

:END2

endlocal

:: Change screen color
color 2F
:: Play chimes when complete  (sometimes working), does't work in my terminal app
set soundfile=C:\Windows\Media\chimes.wav
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "(New-Object Media.SoundPlayer '%soundfile%').PlaySync();"
pause
goto :start

:::closes remote scanstate and loadstate
::This part of the script only works if you have the PsKill.exe in your "C:\tmp" folder
:CLOSE
:: Domain Name
:: set mydomain=SH
set mydomain=md
:: User name( this is only needed if you are running in the "Terminal App"
::set USERNAME=xzx12345

cd /tmp
set /p pcname="pcname:"
PSkill \\%pcname% -u %mydomain%\%USERNAME% scanstate
PSkill \\%pcname% -u %mydomain%\%USERNAME% loadstate
pause
goto :start
