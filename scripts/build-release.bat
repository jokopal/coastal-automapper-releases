@echo off
REM Build and Deploy Script for BlueMap Releases (Windows)
REM Usage: build-release.bat [version]

setlocal enabledelayedexpansion

REM Configuration
set COASTAL_DIR=..\CoastalAutoMapper
set RELEASE_DIR=.
set UPDATE_SERVER_DIR=update-server
set VERSION=%1
if "%VERSION%"=="" set VERSION=1.0.1

echo 🔨 Building BlueMap Release v%VERSION%

REM Step 1: Build the application
echo 📦 Building application...
cd "%COASTAL_DIR%\electron"
call npm run release

REM Step 2: Copy files to release repository
echo 📋 Copying release files...
set INSTALLER=BlueMap-Setup-%VERSION%.exe
set SHA512_FILE=%INSTALLER%.sha512

copy "..\release\%INSTALLER%" "..\..\coastal-automapper-releases\%UPDATE_SERVER_DIR%\updates\"
copy "..\release\%SHA512_FILE%" "..\..\coastal-automapper-releases\%UPDATE_SERVER_DIR%\updates\"

REM Step 3: Update version.json
echo 📝 Updating version.json...
cd "..\..\coastal-automapper-releases"
(
echo {
echo   "version": "%VERSION%",
echo   "latest": "%VERSION%", 
echo   "releaseDate": "%date:~6,4%-%date:~3,2%-%date:~0,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%Z",
echo   "changelog": "Auto-generated release v%VERSION%"
echo }
) > version.json

REM Step 4: Git operations
echo 🔄 Git operations...
git add .
git commit -m "Release v%VERSION%"
git push origin main

echo ✅ Release v%VERSION% completed successfully!
echo 📦 Download URL: http://your-server.com/updates/%INSTALLER%
echo 🔗 Update API: http://your-server.com/update/win32/previous-version

pause
