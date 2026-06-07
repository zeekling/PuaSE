@echo off
cd /d "%~dp0.."

echo [1/3] Cleaning old packages...
del /q *.tgz 2>nul
echo done
echo.

echo [2/3] Running npm pack (using latest for package name and version)...
npm pack --package-name "@zeekling/puse" --package-version "latest"
echo done
echo.

echo [3/3] Result:
dir /b *.tgz
echo.
pause
