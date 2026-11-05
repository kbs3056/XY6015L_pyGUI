@echo off
setlocal

set "ROOT_DIR=%~dp0"
set "PYTHON_EXE="
cd /d "%ROOT_DIR%"

call :find_python
if not defined PYTHON_EXE goto :python_not_found

echo Using Python:
echo %PYTHON_EXE%

call "%PYTHON_EXE%" -m ensurepip --upgrade >nul 2>nul
call "%PYTHON_EXE%" -m pip install -r source_files\requirements.txt
if errorlevel 1 goto :build_failed

call "%PYTHON_EXE%" -m PyInstaller --version >nul 2>nul
if errorlevel 1 (
    echo PyInstaller not found. Installing it now...
    call "%PYTHON_EXE%" -m pip install pyinstaller
    if errorlevel 1 goto :pyinstaller_install_failed
)

call "%PYTHON_EXE%" -m PyInstaller --clean --noconfirm XYGUI.spec
if errorlevel 1 goto :build_failed

echo.
echo Build complete.
echo EXE folder:
echo %ROOT_DIR%dist\XYGUI
goto :end

:find_python
for /d %%D in ("%LocalAppData%\Programs\Python\Python*") do (
    if exist "%%~fD\python.exe" set "PYTHON_EXE=%%~fD\python.exe"
)
if defined PYTHON_EXE exit /b 0

for /d %%D in ("%ProgramFiles%\Python*") do (
    if exist "%%~fD\python.exe" set "PYTHON_EXE=%%~fD\python.exe"
)
if defined PYTHON_EXE exit /b 0

where python >nul 2>nul
if not errorlevel 1 (
    python -c "import sys; raise SystemExit(0 if sys.version_info[0] == 3 else 1)" >nul 2>nul
    if not errorlevel 1 (
        for /f "delims=" %%I in ('python -c "import sys; print(sys.executable)" 2^>nul') do set "PYTHON_EXE=%%I"
        exit /b 0
    )
)

where py >nul 2>nul
if not errorlevel 1 (
    for /f "delims=" %%I in ('py -3 -c "import sys; print(sys.executable)" 2^>nul') do set "PYTHON_EXE=%%I"
)
exit /b 0

:python_not_found
echo Python 3 not found.
echo Install any supported Python 3 version and then run this file again.
pause
goto :end

:pyinstaller_install_failed
echo.
echo Failed to install PyInstaller.
echo Check internet access or install it manually with:
echo "%PYTHON_EXE%" -m pip install pyinstaller
pause
goto :end

:build_failed
echo.
echo Build failed.
pause

:end
endlocal
