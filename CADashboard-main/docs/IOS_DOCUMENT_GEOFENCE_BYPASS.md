## Purpose

This document records the iOS-only change to make the **Documents menu** load without failing geo-fence validation.

The goal is: **when the user opens Documents**, the app should fetch:
- folder list
- folder contents
- document view URLs

without calling `requestLocationPermission()` / geo-fence validation on iOS.

## What was changed

### File
- `lib/core/repository/document/document_repository.dart`

### Change
- iOS Documents read operations now call `getMethod(..., skipLocationCheck: true)` for:
  - `getFolderList`
  - `getFolderContents`
  - `getDocumentURL`

### What remains geo-fenced

This bypass is applied only to the “view/browse” read calls above.
Write/permission-sensitive actions like upload/move/lock/unlock/unshare were not changed.

## How it affects the `.ipa`

You need to build a new `.ipa` so the iOS binary includes this logic.
After installing the new build, opening Documents should no longer show:

`Login not allowed, you're currently outside the allowed location...`

