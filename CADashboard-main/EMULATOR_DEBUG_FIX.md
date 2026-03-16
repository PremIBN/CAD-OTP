# Fix: "Error waiting for a debug connection: The log reader stopped unexpectedly"

This error happens when the Android emulator’s log reader disconnects during app launch (APK often installs, but the debug connection fails).

## Steps (try in order)

### 1. Restart ADB and clean Flutter
- Run **`fix_emulator_debug.bat`** from this folder (it runs `adb kill-server`, `adb start-server`, then `flutter clean`),  
  **or** run manually:
  ```bash
  adb kill-server
  adb start-server
  flutter clean
  ```

### 2. Cold boot the emulator
- Close the emulator if it’s running.
- Open **Android Studio → Device Manager (AVD Manager)**.
- For **sdk gphone64 x86 64** (or your AVD): click the **▼** next to it.
- Choose **Cold Boot Now** (or **Wipe Data** then start the emulator).
- Wait until the emulator is fully booted (home screen visible).

### 3. Run the app again
```bash
flutter run
```
Or run/debug from your IDE after the emulator is up.

### 4. If it still fails
- **Update Android SDK**: Android Studio → SDK Manager → install latest **Android SDK Platform-Tools** and **Build-Tools**.
- **New AVD**: Create a new virtual device (e.g. Pixel 6, API 34) and use it instead.
- **Release run**: To confirm the app works without debug: `flutter run --release` (no debugger).

Cause is usually a flaky ADB/emulator connection or stale state; cold boot + clean + fresh ADB fixes it in most cases.
