@echo off
echo Cleaning Flutter and Gradle caches...
echo.

echo Step 1: Flutter clean...
call flutter clean
echo.

echo Step 2: Cleaning Gradle cache...
cd android
call gradlew clean
cd ..
echo.

echo Step 3: Getting Flutter dependencies...
call flutter pub get
echo.

echo Step 4: Stopping Gradle daemon...
cd android
call gradlew --stop
cd ..
echo.

echo.
echo ========================================
echo Cleanup complete!
echo ========================================
echo.
echo If the error persists, you may need to:
echo 1. Close Android Studio completely
echo 2. Delete the Gradle cache folder manually:
echo    C:\Users\%USERNAME%\.gradle\caches\8.12
echo 3. Restart Android Studio
echo.
pause
