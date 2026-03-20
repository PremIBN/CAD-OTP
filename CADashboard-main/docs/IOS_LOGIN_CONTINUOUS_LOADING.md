## Problem

On the real iPhone (installed `.ipa`), after entering credentials the app shows a loader continuously and does not show any error.

## Root cause (in this codebase)

The login flow has a few awaited calls **before** your backend login response handlers (`successResponse` / `failedResponse`) run:

- Location: `Geolocator.getCurrentPosition()`
- IP lookup: `Ipify.ipv4()`
- Network calls: `http.get/post(...)`

If any of these operations hangs on a real device (no GPS fix, iOS location services off, slow network, blocked IPify request, server not responding), and there is **no timeout / catch**, then:

- `buttonLoader` stays `true`
- The UI keeps showing the loading spinner
- No error message is shown because the code never reaches your `failedResponse` callback

This can happen even if the backend is fine, because the app is waiting earlier (location/IP lookup).

## Fix applied

We added back **timeouts + user-facing error handling** so the loader can stop and the user gets a clear message.

### 1) Location timeout + message (`login_screen.dart`)

- Adds `static const Duration _locationTimeout = Duration(seconds: 20);`
- Wraps `Geolocator.getCurrentPosition()` with `.timeout(_locationTimeout)`
- Requests a higher-accuracy GPS fix (`desiredAccuracy: LocationAccuracy.high`) to reduce false geo-fence failures
- On error/timeout:
  - sets `model.buttonLoader.value = false`
  - shows Snackbar: `"Unable to get location. Please enable GPS and try again."`

File: `lib/ui/screen/login_screen.dart`

### 2) Prevent login bootstrap from hanging (`login_vm.dart`)

- Adds `static const Duration _loginBootstrapTimeout = Duration(seconds: 15);`
- Wraps:
  - `notification()` with timeout (and logs failure, but does not block login)
  - `Ipify.ipv4()` with timeout and fallback value (`0.0.0.0`)

File: `lib/core/View_Model/login_vm.dart`

### 3) Prevent HTTP requests from hanging (`api_client.dart`)

- Restores a default request timeout:
  - `static const Duration _defaultTimeout = Duration(seconds: 30);`
- Applies `.timeout(_defaultTimeout)` to:
  - `withOutTokenGetMethod`
  - `withOutTokenPostMethod`
  - `getMethod`
  - `postRawMethod`
  - `postJsonMethod`
  - `checkGetMethod`
- Wraps `postMethod` in try/catch to return a consistent `{Success:0, Message:...}` on timeout/network errors.

File: `lib/core/api_client/api_client.dart`

## What to check on the iPhone build

- **Location services**: iOS Settings → Privacy & Security → Location Services → enable + allow for this app.
- **Network**: test on a different Wi‑Fi / mobile data.
- **Server reachability**: if the server is slow/unresponsive, the new timeouts will surface `"Server Time out"` instead of infinite loading.

## How to verify quickly

After installing a build that includes these changes:

- If GPS fix is slow/unavailable → you should see the Snackbar and loader stops.
- If IPify fails → login still proceeds using `0.0.0.0` (no infinite loader).
- If server does not respond → after ~30 seconds you should get `"Server Time out"`.

