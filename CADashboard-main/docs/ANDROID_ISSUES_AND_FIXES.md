# Android Issues & Fixes – CADashboard

This document summarizes the issues encountered when running the Flutter app on real Android devices (and related build/API problems) and how they were addressed.

---

## 1. Generic “Something went wrong” on login (real device)

**Issue:** On a real Android device, after entering valid credentials and tapping Login, the app showed a generic red error: **“Something went wrong”** instead of the backend’s actual message (e.g. geo-fence, device, or IP rejection).

**Causes:**
- **Backend message not parsed:** The app only looked for `Message` / `message` in the response. Many APIs use `detail`, `reason`, `msg`, or `error`. When those keys weren’t checked, the code fell back to the generic string.
- **Failed responses parsed as LoginModel:** When the backend returned `Success: 0` with a minimal body, the code still called `LoginModel.fromJson(result)`. That threw (missing fields), and the catch block used the generic message instead of reading the backend’s error text.
- **Network/HTTP exceptions:** `withOutTokenPostMethod` only caught `TimeoutException`, `SocketException`, and `Error`. Any other `Exception` (e.g. connection errors) was uncaught and led to the generic message or crash.

**Fixes applied:**
- **Login repository:** Check success from the raw map **before** calling `LoginModel.fromJson`. On failure, read the message from the map and pass it to `failedResponse`. Never parse a failure response as `LoginModel`.
- **Message extraction:** `_getMessage()` now checks many keys: `Message`, `message`, `msg`, `error`, `errorMessage`, `detail`, `reason`, `statusMessage`, etc. If the value is a JSON string, it is parsed and the inner message is extracted.
- **API client:** For HTTP 400/401/403, `handleResponse` parses the response body as JSON and puts the extracted message (from those same keys) into the returned map’s `Message` so the UI shows the real backend reason.
- **Exception handling:** `withOutTokenPostMethod` now catches `Exception` and uses `e.toString()` as the message when possible, so connection/handshake errors are visible instead of “Something went wrong”.

---

## 2. Location validation blocking requests before backend

**Issue:** Client-side location checks in `ApiClient` (e.g. in `getMethod` / `postMethod`) could block requests before they reached the server. The backend never got a chance to return its own validation result, so users saw generic or location-related messages instead of the real API error.

**Fixes applied:**
- **Optional location check:** `getMethod` (and related flows) support a `skipLocationCheck` parameter so lightweight or post-login calls (e.g. notifications) can skip the geo-fence check and let the backend enforce rules.
- **Backend-driven validation:** Login uses `withOutTokenPostMethod` (no pre-call location gate). The server can reject by device/location/IP and return a proper message, which is then shown thanks to the improved error parsing above.

---

## 3. Location check API success flag not read correctly

**Issue:** After calling the location-check API, the code did `if (result == true)`. The API returns a **JSON object** (e.g. `{"Success": 1}`), not a boolean. So the condition was never true and location “allowed” was never recognized.

**Fix:** In `ApiClient.checkLocation()`, the result is treated as a map and the success flag is read from the response, e.g. `result['Success'] == 1` or `result['success'] == true`, and that value is returned so geo-fence allow/deny is correct.

---

## 4. Check-token repository: wrong API usage and syntax

**Issue:** Build failed with:
- `No named parameter with the name 'contentType'` – `withOutTokenGetMethod` does not have a `contentType` parameter.
- `Expected ',' before this` / malformed try-catch – Extra `}` and a broken `} } catch` block.

**Fix:** Removed the invalid `contentType` argument from the GET call (token is sent via `queryParam`). Fixed the try-catch block to a single `} catch (e) { ... }` with correct braces and removed commented-out duplicate catch.

---

## 5. Duplicate `postMethod` in ApiClient

**Issue:** Build error: `'postMethod' is already declared in this scope` – two `postMethod` implementations existed (one with location gating, one with `skipLocationCheck`).

**Fix:** Removed the older duplicate and kept the single implementation that supports `skipLocationCheck` and proper error handling.

---

## 6. Release APK crashes on real device (immediate or after login)

**Issue:** App ran in Android Studio and on the emulator but crashed when the release APK was installed on a real device—either on startup or after login.

**Causes:**
- **Null context:** Code used `navigatorKey.currentContext!` in async callbacks (e.g. after login or location check). On a real device, timing can mean the context is null or disposed when the callback runs, causing a crash.
- **Crashlytics in error handler:** If `recordFlutterFatalError` / `recordError` threw (e.g. Firebase not ready or network issue), the error handler itself could crash the app.
- **R8/minification:** With minification enabled, R8 could strip or rename code used by reflection (e.g. JSON, plugins), causing release-only crashes.

**Fixes applied:**
- **Null-safe context:** Before showing dialogs or snackbars, the code now uses `final ctx = navigatorKey.currentContext` and only proceeds if `ctx != null && ctx.mounted`. In the login VM, the existing `context` is used with `context.mounted` checks before showing the location dialog, navigating, or showing the snackbar.
- **Crashlytics:** The Crashlytics recording calls in `FlutterError.onError` and `PlatformDispatcher.instance.onError` are wrapped in try/catch so a failure to record does not crash the app.
- **Release build:** In `android/app/build.gradle.kts`, release is built with `isMinifyEnabled = false` and `isShrinkResources = false` to avoid R8-induced crashes. A `proguard-rules.pro` was added for future use if minification is re-enabled.

---

## 7. HandshakeException: CERTIFICATE_VERIFY_FAILED (real device)

**Issue:** On a real Android device, login failed with a red banner:

**HandshakeException: Handshake error in client (OS Error: CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate)**

**Cause:** The device could not verify the server’s HTTPS certificate. Common reasons:
- Server uses a certificate from a CA not in the device’s trust store (e.g. internal or enterprise CA).
- Incomplete certificate chain (missing intermediate).
- Self-signed or custom certificate.

**Fix:** In `main.dart`, a custom `HttpOverrides` (`_ApiHttpOverrides`) is set globally. It creates an `HttpClient` with a `badCertificateCallback` that **only** allows the app’s API host(s) (`www.cadashboard.com`, `cadashboard.com`). Other HTTPS hosts still use normal verification. This allows the login (and other API) requests to complete when the server cert would otherwise be rejected.

**Recommendation:** For production, prefer fixing the server: use a certificate from a public CA (e.g. Let’s Encrypt) or serve the full chain and ensure the CA is trusted on target devices.

---

## Summary table

| # | Issue | Symptom | Fix |
|---|--------|---------|-----|
| 1 | Generic login error | “Something went wrong” on device | Parse backend message from multiple keys; check success before parsing as LoginModel; catch Exception and use its message |
| 2 | Location blocking requests | Backend never reached; generic/blocking message | Optional skipLocationCheck; login uses tokenless POST so backend can respond |
| 3 | Location API result wrong | Geo-fence always treated as deny | Read Success/success from response map instead of `result == true` |
| 4 | Check-token build error | contentType / syntax errors | Remove invalid parameter; fix try-catch structure |
| 5 | Duplicate postMethod | Build: “already declared” | Remove duplicate; keep single postMethod with skipLocationCheck |
| 6 | Release APK crash | Crash on device at start or after login | Null-safe context; safe Crashlytics; disable minify/shrink for release |
| 7 | Certificate verify failed | HandshakeException on device | HttpOverrides with badCertificateCallback for API host only |

---

*Document generated from the Android real-device and build fixes applied to the CADashboard Flutter app.*
