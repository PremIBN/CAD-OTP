# Android Studio Setup Instructions for CADashboard

## Required Android API Levels

Based on the project configuration, you need to install the following Android APIs in Android Studio:

### **Primary Requirements:**

1. **Android API 36 (Android 16)** - **REQUIRED**
   - Used as `compileSdk` and `targetSdk` in `build.gradle.kts`
   - Required by multiple Flutter plugins (device_info_plus, fluttertoast, geolocator_android, network_info_plus, package_info_plus, shared_preferences_android, speech_to_text, url_launcher_android, webview_flutter_android)
   - This is the primary API level your app targets

2. **Android NDK 28.2.13676358** - **REQUIRED**
   - Required by `speech_to_text` plugin
   - Must be installed via SDK Manager

3. **Android API 35 (Android 15)** - **RECOMMENDED**
   - Previous target SDK version (for compatibility testing)

4. **Android API 33 (Android 13)** - **REQUIRED**
   - Required for `POST_NOTIFICATIONS` permission (used in AndroidManifest.xml)
   - Minimum recommended for testing notification features

5. **Android API 31 (Android 12)** - **REQUIRED**
   - Required for `BLUETOOTH_CONNECT` permission (used in AndroidManifest.xml)
   - Minimum for Bluetooth features to work properly

6. **Android API 21 (Android 5.0 Lollipop)** - **OPTIONAL (for minimum compatibility testing)**
   - Flutter's default minimum SDK version
   - Install only if you need to test on older Android versions

---

## Step-by-Step Installation Instructions

### Step 1: Open Android Studio SDK Manager

1. Open **Android Studio**
2. Go to **Tools** → **SDK Manager** (or click the SDK Manager icon in the toolbar)
3. Alternatively: **File** → **Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**

### Step 2: Install Required SDK Platforms

1. In the SDK Manager, click on the **SDK Platforms** tab
2. Check the following boxes:
   - ✅ **Android 16.0 (API Level 36)** - **MUST HAVE** (if available)
   - ✅ **Android 15.0 (API Level 35)** - **RECOMMENDED**
   - ✅ **Android 13.0 (API Level 33)** - **MUST HAVE**
   - ✅ **Android 12.0 (API Level 31)** - **MUST HAVE**
   - ⚪ **Android 5.0 (API Level 21)** - Optional (for minimum compatibility testing)

3. Click **Apply** and then **OK** to download and install

### Step 3: Install Required SDK Tools

1. In the SDK Manager, click on the **SDK Tools** tab
2. Ensure the following are checked:
   - ✅ **Android SDK Build-Tools** (latest version)
   - ✅ **Android SDK Command-line Tools**
   - ✅ **Android SDK Platform-Tools**
   - ✅ **Android Emulator**
   - ✅ **NDK (Side by side)** - **IMPORTANT**: Check this and ensure version **28.2.13676358** is installed
   - ✅ **Google Play services**
   - ✅ **Google Play Store** (if available)

3. **For NDK Installation:**
   - Expand **NDK (Side by side)** if needed
   - Ensure **28.2.13676358** is checked (required by speech_to_text plugin)
   - If this version is not listed, you may need to update Android Studio or install it manually

4. Click **Apply** and then **OK**

### Step 4: Create an Android Virtual Device (AVD)

1. Go to **Tools** → **Device Manager** (or click the Device Manager icon)
2. Click **Create Device**
3. Select a device (e.g., **Pixel 7** or **Pixel 8**)
4. Click **Next**
5. **IMPORTANT**: Select **API Level 36** (Android 16) system image if available
   - If API 36 is not available, select **API Level 35** (Android 15) or **API Level 33** (Android 13) as minimum
   - Make sure to download the system image if prompted
6. Click **Next**
7. Review the AVD configuration and click **Finish**

### Step 5: Verify Installation

1. Open a terminal/command prompt
2. Navigate to your project directory
3. Run:
   ```bash
   flutter doctor
   ```
4. Ensure Android toolchain shows no errors
5. Run:
   ```bash
   flutter devices
   ```
6. Your emulator should appear in the list

---

## Project Configuration Summary

### Current Settings (from `android/app/build.gradle.kts`):
- **compileSdk**: 36 (Android 16)
- **targetSdk**: 36 (Android 16)
- **ndkVersion**: 28.2.13676358 (required by speech_to_text plugin)
- **minSdk**: 21 (Android 5.0) - Flutter default

### Build Tools (from `android/settings.gradle.kts`):
- **Android Gradle Plugin**: 8.9.1 (required by androidx dependencies)
- **Kotlin**: 2.1.0 (Flutter recommended version)
- **Gradle**: 8.12 (from gradle-wrapper.properties)

### Permissions Requiring Specific API Levels:
- `POST_NOTIFICATIONS` → Requires API 33+ (Android 13)
- `BLUETOOTH_CONNECT` → Requires API 31+ (Android 12)
- `FOREGROUND_SERVICE` → Requires API 14+ (Android 4.0)
- Location, Audio, Internet permissions → Available from API 1+

### Java Version:
- **Java 11** is required (configured in `build.gradle.kts`)

---

## Recommended Emulator Configuration

For best results, create an emulator with:
- **API Level 36** (Android 16) - matches your target SDK (or API 35/33 if 36 is not available)
- **RAM**: 2GB minimum (4GB recommended)
- **VM Heap**: 512MB
- **Internal Storage**: 2GB minimum
- **Enable**: Hardware acceleration (HAXM or Hyper-V on Windows)

---

## Troubleshooting

### If API 36 is not available:
- Update Android Studio to the latest version
- Check for Android Studio updates: **Help** → **Check for Updates**
- API 36 may require Android Studio Iguana (2024.1.1) or later
- If API 36 is not available, the project will work with API 35, but you may see warnings about plugin compatibility

### If NDK 28.2.13676358 is not available:
- Update Android Studio to the latest version
- In SDK Manager → SDK Tools, check "Show Package Details" to see all NDK versions
- If the specific version is not available, try installing the latest NDK version and update `ndkVersion` in `build.gradle.kts` accordingly
- Alternatively, you may need to install NDK manually from the Android developer website

### If build fails with Gradle/Plugin errors:
1. Ensure Android Gradle Plugin is 8.9.1 or higher (check `android/settings.gradle.kts`)
2. Ensure Kotlin version is 2.1.0 or higher (check `android/settings.gradle.kts`)
3. Ensure all required APIs are installed
4. Run `flutter clean`
5. Run `flutter pub get`
6. Invalidate caches: **File** → **Invalidate Caches** → **Invalidate and Restart**
7. Sync Gradle files: **File** → **Sync Project with Gradle Files**

### If build fails with "Could not move temporary workspace" (Gradle cache error):
This error occurs when Gradle cannot access its cache directory. Try these solutions in order:

1. **Close all Android Studio/Gradle processes:**
   - Close Android Studio completely
   - Check Task Manager for any Java/Gradle processes and end them
   - Wait a few seconds

2. **Clean Gradle cache:**
   ```bash
   # In PowerShell or Command Prompt:
   cd %USERPROFILE%\.gradle\caches
   # Delete the cache folder (or just the problematic version folder: 8.12)
   # Or use:
   flutter clean
   ```

3. **Clean Flutter and Gradle:**
   ```bash
   flutter clean
   cd android
   .\gradlew clean
   cd ..
   flutter pub get
   ```

4. **If still failing, delete Gradle cache manually:**
   - Close Android Studio
   - Navigate to `C:\Users\<YourUsername>\.gradle\caches\8.12\transforms\`
   - Delete the problematic folder (the one mentioned in the error)
   - Or delete the entire `8.12` folder if safe to do so
   - Restart Android Studio

5. **Check file permissions:**
   - Ensure you have full read/write permissions to `C:\Users\<YourUsername>\.gradle\`
   - Right-click the folder → Properties → Security → Ensure your user has full control

6. **Disable antivirus temporarily:**
   - Some antivirus software locks files during scanning
   - Temporarily disable real-time protection and try building again

### If emulator is slow:
- Enable hardware acceleration in AVD settings
- Increase RAM allocation
- Use x86_64 system images instead of ARM

---

## Quick Checklist

- [ ] Android Studio installed and updated
- [ ] Android API 36 (Android 16) installed (or API 35 if 36 not available)
- [ ] Android API 33 (Android 13) installed
- [ ] Android API 31 (Android 12) installed
- [ ] Android NDK 28.2.13676358 installed
- [ ] Android SDK Build-Tools installed
- [ ] Android Emulator installed
- [ ] AVD created with API 36 (or API 35/33 minimum)
- [ ] Flutter doctor shows no Android issues
- [ ] Emulator appears in `flutter devices`

---

## Additional Notes

- The project uses **Kotlin** and **Java 11**
- Firebase services are integrated (ensure Google Play services are installed)
- The app requires internet connectivity for Firebase and other services
- Location services require GPS hardware (emulator can simulate this)
