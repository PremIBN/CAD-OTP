@echo off
cd /d "%~dp0"
echo Running flutter pub get to resolve file_picker...
flutter pub get
if %ERRORLEVEL% EQU 0 (
  echo.
  echo Packages resolved successfully. You can now build/run the app.
) else (
  echo.
  echo If this failed, try: flutter clean
  echo Then run this script again, or run: flutter pub get
)
pause
