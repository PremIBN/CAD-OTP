@echo off
REM Fix "Error waiting for a debug connection: The log reader stopped unexpectedly"
REM Run this from project root, then try: flutter run

echo Stopping ADB...
adb kill-server
timeout /t 2 /nobreak >nul
echo Starting ADB...
adb start-server
timeout /t 2 /nobreak >nul

echo Cleaning Flutter build...
call flutter clean
echo.
echo Done. Next steps:
echo 1. Close the emulator if it is running.
echo 2. In Android Studio: AVD Manager -^> your emulator -^> Cold Boot Now (or Wipe Data then start).
echo 3. Wait for emulator to fully boot, then run: flutter run
echo.
pause
