# Upload Not Working – Analysis

## Where it goes wrong

**Root cause: the server does not expose a document upload endpoint.**

- The app sends valid requests (POST multipart/JSON with `tokenID`, `docFolderID`, file).
- The server responds with **"No action was found on the controller"** (or similar), meaning the request reaches the API but **no controller action** matches the URL + HTTP method.
- **CAD APIs.md** documents many Document endpoints (GetFolderList, AddFolder, DownloadDocument, etc.) but **no upload endpoint**. So the backend has not implemented (or not enabled) an upload action.

**Conclusion: the failure is on the backend.** The app cannot fix "no action was found"; the server must add an upload action and correct route mapping.

---

## What the app does (and where it lives)

| Step | Location | What it does |
|------|----------|--------------|
| 1. User taps "+" | `document_screen.dart` | Opens bottom sheet: New folder, Upload files, Check upload availability, Take Photo, Scan Document |
| 2. User taps "Upload files" or "Take Photo" / "Scan Document" | `document_screen.dart` | FilePicker or ImagePicker → reads bytes → `model.uploadFiles(context, folderId, files)` |
| 3. VM | `document_vm.dart` → `uploadFiles()` | Shows "Uploading…", for each file calls `documentRepo.uploadDocument(...)` |
| 4. Repository | `document_repository.dart` → `uploadDocument()` | Tries in order: (A) POST JSON base64, (B) POST form-urlencoded base64, (C) POST multipart to many URLs. Token from `SharedPreferences`, URLs from `api_url.dart`. |
| 5. HTTP | Raw `http.post` / `http.MultipartRequest` | **Does not** use `ApiClient.getMethod`/`postMethod` (so no location check). Sends token in URL/body. |
| 6. Response | Repository | If 200/201 → success, refresh list. If "no action was found" (or 404) → show "Document upload is not available on this server...". |

---

## What the app does correctly

- **Auth:** Sends `tokenID` in query (or body for JSON/form).
- **Target folder:** Sends `docFolderID`.
- **File:** Sends file bytes (multipart file part or base64 in JSON/form).
- **URLs:** Tries many patterns: Document/SaveDocument, UploadDocument, UploadFile, Documents/Upload, File/Upload, etc. (see `api_url.dart` and `document_repository.dart`).
- **Formats:** Tries JSON (base64), form-urlencoded (base64), and multipart with field names: file, File, document, upload.
- **Override:** If backend provides a URL, set `documentUploadEndpointOverride` in `api_url.dart` and the app tries it first.

---

## Optional app-side improvement

- **Multipart Content-Type:** The app currently sends all multipart files as `image/jpeg`. For file-picker uploads (PDF, Word, etc.) it is better to set Content-Type from the file extension (e.g. `application/pdf` for .pdf). This does not fix "no action was found" but ensures correct uploads once the backend adds the endpoint.

---

## What must change (backend)

1. **Implement** one document upload action (e.g. on Document or File controller) that accepts POST and multipart (or JSON per spec).
2. **Map the route** so it is reachable (e.g. `.../api/Document/UploadDocument` or `UploadFile`).
3. **Deploy** and give the app team the exact URL.
4. **App:** Set `documentUploadEndpointOverride` in `lib/core/url/api_url.dart` to that URL.

See **BACKEND_DOCUMENT_UPLOAD_SPEC.md** for the full contract.
