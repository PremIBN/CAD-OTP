# Enable client file upload

## Root cause: backend blocks document uploads

**The issue is backend-related.** The Flutter app correctly sends the upload request, but the server explicitly blocks or does not expose document uploads. This **cannot be resolved at the client level** and requires **backend configuration and API enablement**. See **BACKEND_DOCUMENT_UPLOAD_SPEC.md** for what the backend team must implement.

---

## Permissions (document upload)

The app uses these permissions for document uploads; they are **requested at runtime**, **validated before** file pick / camera / scanner actions, and **handled gracefully on denial** (dialog with Open Settings).

| Permission | Purpose | When requested | Denial handling |
|------------|---------|----------------|-----------------|
| **Camera** | Take Photo, Scan Document | Before opening camera | Dialog: “Camera access needed” + Open Settings / Cancel |
| **Storage** (Android &lt; 33) | Select files from device (Upload files) | Before opening file picker | Dialog: “Storage access needed” + Open Settings / Cancel |
| **Internet** | Upload documents to server | Declared in manifest; upload fails with “No Internet” if offline | Shown by repository on network error |

- **Android:** INTERNET, CAMERA, READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE in `AndroidManifest.xml`. Storage is requested only on Android &lt; 33 (Android 13+ uses system picker).
- **iOS:** NSCameraUsageDescription, NSPhotoLibraryUsageDescription in `Info.plist`.

---

The app can compile without `file_picker`. To enable "Upload files" from the device on the client side:

## Step 1: Add the package

In **pubspec.yaml**, under `dependencies`, change:

```yaml
  # Required for "Upload files". Uncomment and run: flutter pub get
  # file_picker: 6.2.1
```

to:

```yaml
  file_picker: 6.2.1
```

## Step 2: Run

In a terminal, in the project folder, run:

```bash
flutter pub get
```

## Step 3: Replace the stub in document_screen.dart

1. Add these imports at the top (with other imports):

```dart
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
```

2. Replace the methods `_pickAndUploadFiles` and `_showUploadInstructions` with this single method:

```dart
  static Future<void> _pickAndUploadFiles(
    BuildContext context,
    DocumentVM model,
    int folderId,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final files = <MapEntry<String, Uint8List>>[];
    for (final pf in result.files) {
      if (pf.name.isEmpty) continue;
      final bytes = pf.bytes;
      if (bytes == null || bytes.isEmpty) continue;
      files.add(MapEntry(pf.name, bytes));
    }
    if (files.isEmpty) {
      if (!context.mounted) return;
      CommonFunction.showSnackBar(
        context: context,
        isError: true,
        message: 'Could not read file data. Try again.',
      );
      return;
    }
    if (!context.mounted) return;
    model.uploadFiles(context, folderId: folderId, files: files);
  }
```

3. **Delete** the `_showUploadInstructions` method entirely.

4. Restart the app. Use the + button and "Upload files" to pick and upload.
