## Problem

On a real iPhone (`.ipa` build), tapping **Documents** shows a loader continuously and nothing appears.

## Root cause (in this codebase)

`DocumentScreen` triggers `DocumentVM.loadFolders()` on init, which calls:

- `DocumentRepository.getFolderList()`
  - uses `ApiClient.getMethod()`
    - calls `ApiClient.requestLocationPermission()` (geo-fence access control)

Inside `requestLocationPermission()` we call:

- `Geolocator.getCurrentPosition()`

On real iOS devices this can take a long time (no GPS fix, weak signal, Location Services issues). Without a timeout, the Future never completes quickly, so the Documents UI stays in `ViewState.loading` and looks like it is stuck.

## Fix applied

File: `lib/core/api_client/api_client.dart`

- Added `_geoTimeout = Duration(seconds: 20)`
- Wrapped `Geolocator.getCurrentPosition()` with `.timeout(_geoTimeout)`
- On timeout:
  - show Snackbar: `"Unable to get location. Please enable GPS and try again."`
  - return `false` so the API call fails fast instead of hanging
- Also guarded `navigatorKey.currentContext` usage so iOS dialogs/snackbars don’t crash when context is null/unmounted.

### Extra improvement (reduce false “outside geofence”)

- Updated iOS GPS retrieval to request a higher-accuracy fix when validating the geo-fence (reduces cases where iOS returns imprecise coordinates).

## What to verify on the iPhone

- iOS Settings → **Privacy & Security** → **Location Services** → ON
- iOS Settings → your app → **Location** → Allow (When In Use is usually enough)
- Try with stronger GPS: open Apple Maps once, then retry Documents

After installing a build that includes this change, Documents should either load normally or show a clear message instead of infinite loading.

