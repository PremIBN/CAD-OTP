# Document Upload Flow – End-to-End Investigation

## 1. Flow Summary

```
UI (Document Screen)
  → User taps "Upload files" / "Take Photo" / "Scan Document"
  → document_screen: _pickAndUploadFiles() or _captureImageAndUpload()
  → Reads file bytes (FilePicker / ImagePicker)
  → document_vm.uploadFiles(context, folderId, files)
  → For each file: document_repository.uploadDocument(docFolderId, fileName, fileBytes, success, failed)
  → Repository tries, in order:
      A. POST application/json (base64) to Document/UploadDocument, Document/AddDocument
      B. POST application/x-www-form-urlencoded (base64) to same URLs
      C. POST multipart/form-data to many URLs (see list below)
  → On success: success() → VM shows snackbar "Uploaded successfully", loadFolders(silent: true)
  → On failure: failed(message) → VM shows snackbar with message, loadFolders(silent: true)
```

## 2. API Base and Document Controller

- **Base URL:** `https://www.cadashboard.com/web/api/`
- **Document controller base:** `https://www.cadashboard.com/web/api/Document/`
- **Working Document endpoints (from CAD APIs.md):**  
  GetFolderList, GetDocumentURL, DownloadDocument, DeleteFolder, DeleteFile, ShareDocument, UnShareDocument, LockDocument, UnLockDocument, CheckIfFolderNameExist, AddFolder, MoveDocument, MoveFolder.  
  **No upload endpoint is documented.**

## 3. Exact Request Details

### A. Base64 JSON (first attempt)

- **URLs tried:**  
  `Document/UploadDocument`, `Document/AddDocument`  
  (plus override URL first if `Urls.documentUploadEndpointOverride` is set)
- **Method:** POST  
- **Headers:** `Content-Type: application/json`, `Accept: application/json`  
- **Body (JSON):**  
  `{ "TokenID": "<guid>", "DocFolderID": <int>, "FileName": "<name>", "FileContent": "<base64>" }`

### B. Form-urlencoded (second attempt)

- **URLs tried:** Same as A.  
- **Method:** POST  
- **Headers:** `Content-Type: application/x-www-form-urlencoded`, `Accept: application/json`  
- **Body:**  
  `TokenID=...&DocFolderID=...&FileName=...&FileContent=<base64>`

### C. Multipart (third attempt)

- **URLs tried (in order), with `?tokenID=...&docFolderID=...` when applicable:**
  1. Override URL (if set)
  2. `Document/SaveDocument`
  3. `Document/SaveDocument` (with query)
  4. `File/Upload`, `File/UploadFile` (with query)
  5. `File/Upload`, `File/UploadFile` (no query)
  6. `Document/UploadDocument`, `Document/Upload`, `Document/UploadFile` (with query)
  7. `Document/AddDocument`, `Document/Post` (with query)
  8. `Document/UploadDocument`, `Document/Upload`, `Document/UploadFile` (no query)
  9. `Document` (controller root, no action – POST with query)
- **Method:** POST  
- **Content-Type:** multipart/form-data (set by http.MultipartRequest)  
- **Form fields:**  
  `tokenID`, `docFolderID`, and one file part with name **file** / **File** / **document** / **upload** (each URL tried with each name until one succeeds).

## 4. Why “No action was found on the controller ‘Document…’” Occurs

- The request reaches the server and is routed to the **Document** controller (URL path matches).
- No **action** on that controller matches the request. In ASP.NET Web API this usually means:
  - There is **no method** named to match the path (e.g. no `UploadDocument`, `UploadFile`, `SaveDocument`, `Post`, etc.), or
  - The **HTTP method** does not match (e.g. action only allows GET), or
  - **Route/attribute** configuration uses a different path or constraint.
- **CAD APIs.md** does not describe any upload endpoint; only the endpoints in section 2 above are documented. So the backend currently does not expose a document upload action that the app can call.

## 5. Important Code Paths

| Layer        | File                         | What it does |
|-------------|------------------------------|--------------|
| UI          | document_screen.dart         | FAB → "Upload files" / "Take Photo" / "Scan Document"; calls VM with folderId and file list (name + bytes). |
| ViewModel   | document_vm.dart             | uploadFiles() loops over files, calls repository.uploadDocument(); on success/failure shows snackbar and loadFolders(silent: true). |
| Repository  | document_repository.dart     | uploadDocument() tries JSON → form-urlencoded → multipart; builds URLs from api_url.dart; uses raw http.post / http.MultipartRequest (no ApiClient.getMethod/postMethod). |
| API config  | api_url.dart                 | baseUrl, Document, File, all upload path constants and documentUploadEndpointOverride. |
| ApiClient   | api_client.dart              | getMethod/postMethod use requestLocationPermission(); **upload does not use these**, so upload is not gated by location. |

## 6. Checklist for Backend (to fix the error)

1. **Add one upload action** on the Document (or File) controller that:
   - Accepts **POST**.
   - Is reachable at one of the paths the app uses (e.g. `Document/UploadDocument`, `Document/UploadFile`, `Document/SaveDocument`, or `Document/Post`).
2. **Accept one of:**
   - **Multipart:** form fields `tokenID`, `docFolderID`, and one file (name `file`, `File`, `document`, or `upload`), or  
   - **JSON:** body with `TokenID`, `DocFolderID`, `FileName`, `FileContent` (base64).
3. **Return:** HTTP 200 or 201 (body can be e.g. `"Record inserted successfully."` or JSON with `Success` / `DocumentID`).
4. **After implementing:** Set `Urls.documentUploadEndpointOverride` in `lib/core/url/api_url.dart` to the exact upload URL so the app tries it first.

See **BACKEND_DOCUMENT_UPLOAD_SPEC.md** for a full contract and example.

## 7. Diagnostic Logging

- Repository logs each attempt with `log('DocumentRepository uploadDocument try: POST $urlString (field: $fieldName)')` (multipart) and similar for JSON/form.
- To see which URLs are tried: run the app in debug, trigger an upload, and check the console for `DocumentRepository uploadDocument` lines. Base URL is from `Urls.baseUrl` in `api_url.dart`.

## 8. Override URL (when backend is ready)

In `lib/core/url/api_url.dart`:

```dart
static const String documentUploadEndpointOverride = '';
```

Set to the **full** upload URL, e.g.:

```dart
static const String documentUploadEndpointOverride = 'https://www.cadashboard.com/web/api/Document/UploadFile';
```

The app will try this URL first for JSON, form-urlencoded, and multipart.
