@echo off
setlocal enabledelayedexpansion

echo.
echo ==========================================
echo  Project Timestamping Utility
echo ==========================================
echo.

:: Prompt for project folder name
set "PROJECT_NAME="
set /p "PROJECT_NAME=Enter project folder name (blank = auto-select most recent): "

:: If blank, find most recently modified folder
if "!PROJECT_NAME!"=="" (
    echo Scanning for most recently modified folder...
    for /f "delims=" %%D in ('dir /b /ad /o-d 2^>nul') do (
        set "PROJECT_NAME=%%D"
        goto :found_project
    )
    echo ERROR: No folders found in current directory.
    exit /b 1
    :found_project
    echo Auto-selected: !PROJECT_NAME!
)

:: Verify project folder exists
if not exist "!PROJECT_NAME!\" (
    echo ERROR: Project folder "!PROJECT_NAME!" does not exist.
    exit /b 1
)

:: Prompt for version
set "VERSION=1.0"
set /p "VERSION=Enter project version (default = 1.0): "
if "!VERSION!"=="" set "VERSION=1.0"

:: Prompt for node_modules inclusion
set "INCLUDE_NODE=N"
set /p "INCLUDE_NODE=Include node_modules? (Y/N, default = N): "
if /i "!INCLUDE_NODE!"=="" set "INCLUDE_NODE=N"

:: Get stable timestamps using PowerShell (single call for speed)
echo.
echo Generating timestamps...
for /f "tokens=1,2 delims=|" %%A in ('powershell -NoProfile -Command "$d = Get-Date; Write-Output ($d.ToString('yyyy-MM-dd_HH-mm-ss') + '|' + $d.ToString('yyyy-MM-dd HH:mm:ss'))"') do (
    set "TIMESTAMP_FILE=%%A"
    set "TIMESTAMP_DISPLAY=%%B"
)

if "!TIMESTAMP_FILE!"=="" (
    echo ERROR: Failed to generate timestamp.
    exit /b 1
)

:: Create unique temp folder
set "TEMP_FOLDER=%TEMP%\project_staging_!TIMESTAMP_FILE!_!RANDOM!"
echo Creating staging folder: !TEMP_FOLDER!
mkdir "!TEMP_FOLDER!" 2>nul
if errorlevel 1 (
    echo ERROR: Failed to create temp folder.
    exit /b 1
)

:: Prepare robocopy exclusions
set "ROBOCOPY_EXCLUDE="
if /i "!INCLUDE_NODE!"=="N" (
    set "ROBOCOPY_EXCLUDE=/XD node_modules"
    echo Excluding node_modules from copy...
) else (
    echo Including node_modules in copy...
)

:: Stage project using robocopy
echo.
echo Copying project files...
robocopy "!PROJECT_NAME!" "!TEMP_FOLDER!\!PROJECT_NAME!" /E /NFL /NDL /NJH /NJS /nc /ns /np !ROBOCOPY_EXCLUDE! >nul
if errorlevel 8 (
    echo ERROR: Robocopy failed with critical error.
    rd /s /q "!TEMP_FOLDER!" 2>nul
    exit /b 1
)

:: Create INFO.md in staged root
echo Creating INFO.md...
set "INFO_FILE=!TEMP_FOLDER!\INFO.md"
(
    echo # 📦 Project Export Information
    echo.
    echo ## Project Details
    echo.
    echo - **Project Name:** !PROJECT_NAME!
    echo - **Version:** !VERSION!
    echo - **Timestamp:** !TIMESTAMP_DISPLAY!
    echo - **Node Modules Included:** !INCLUDE_NODE!
    echo.
    echo ## 📝 Notes
    echo.
    echo This archive was created using the Project Timestamping Utility.
    echo All files are preserved with their original structure and timestamps.
    echo.
    echo ---
    echo.
    echo 🚀 Ready to deploy or archive!
) > "!INFO_FILE!"

if not exist "!INFO_FILE!" (
    echo ERROR: Failed to create INFO.md
    rd /s /q "!TEMP_FOLDER!" 2>nul
    exit /b 1
)

:: Create exports directory if it doesn't exist
if not exist "exports\" (
    echo Creating exports directory...
    mkdir "exports" 2>nul
    if errorlevel 1 (
        echo ERROR: Failed to create exports directory.
        rd /s /q "!TEMP_FOLDER!" 2>nul
        exit /b 1
    )
)

:: Create ZIP archive
set "ZIP_FILE=exports\!PROJECT_NAME!_v!VERSION!.zip"
echo.
echo Compressing to: !ZIP_FILE!

:: Remove existing ZIP if present
if exist "!ZIP_FILE!" (
    echo Removing existing archive...
    del "!ZIP_FILE!" 2>nul
)

:: Use PowerShell to compress with Optimal compression
powershell -NoProfile -Command "Compress-Archive -Path '!TEMP_FOLDER!\*' -DestinationPath '!ZIP_FILE!' -CompressionLevel Optimal -Force" 2>nul
if errorlevel 1 (
    echo ERROR: Failed to create ZIP archive.
    rd /s /q "!TEMP_FOLDER!" 2>nul
    exit /b 1
)

:: Verify ZIP was created and has size
if not exist "!ZIP_FILE!" (
    echo ERROR: ZIP file was not created.
    rd /s /q "!TEMP_FOLDER!" 2>nul
    exit /b 1
)

for %%F in ("!ZIP_FILE!") do set "ZIP_SIZE=%%~zF"
if "!ZIP_SIZE!"=="0" (
    echo ERROR: ZIP file is empty.
    rd /s /q "!TEMP_FOLDER!" 2>nul
    exit /b 1
)

:: Calculate size in KB/MB  
set /a "ZIP_SIZE_KB=!ZIP_SIZE! / 1024"
set /a "ZIP_SIZE_MB=!ZIP_SIZE_KB! / 1024"

:: Clean up temp folder
echo.
echo Cleaning up staging folder...
rd /s /q "!TEMP_FOLDER!" 2>nul
if exist "!TEMP_FOLDER!" (
    echo WARNING: Failed to fully remove temp folder: !TEMP_FOLDER!
    echo Please manually delete if needed.
)

:: Success message
echo.
echo ==========================================
echo  ✅ SUCCESS!
echo ==========================================
echo.
echo Project:     !PROJECT_NAME!
echo Version:     !VERSION!
echo Archive:     !ZIP_FILE!
if !ZIP_SIZE_MB! gtr 0 (
    echo Size:        !ZIP_SIZE_MB! MB
) else (
    echo Size:        !ZIP_SIZE_KB! KB
)
echo Timestamp:   !TIMESTAMP_DISPLAY!
echo.
echo Archive created successfully!
echo ==========================================
echo.

exit /b 0