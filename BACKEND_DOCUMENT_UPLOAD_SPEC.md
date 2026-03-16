# Backend Document Upload API Specification

The mobile app shows **"Document upload is not available on this server. Please ask your administrator to enable the document upload action."** when the server does not expose or explicitly blocks document uploads. The Flutter client sends the upload request correctly; the issue cannot be resolved at the client level and requires backend configuration and API enablement. **The backend team must implement and enable the document upload API** as described below.

**Implementation steps (routes, config, permissions):** See **BACKEND_IMPLEMENTATION_GUIDE.md** (if present).  
**Alternative backend solutions (module activation, stub endpoint, workarounds):** See **BACKEND_ALTERNATIVE_SOLUTIONS.md**.  
**Sample controller code:** See **backend_sample/** (ASP.NET Web API 2).  
**Full flow and investigation:** See **UPLOAD_FLOW_INVESTIGATION.md** for end-to-end flow, exact URLs tried, and why the error occurs.

**If the upload API exists but the app still shows “Document upload is not available”:** The upload action is not fully enabled or mapped. See **BACKEND_IMPLEMENTATION_GUIDE.md** (if present) → section **“When the app still shows ‘Document upload is not available on this server’”** and ensure **routes**, **controller action**, **permissions**, and **upload configuration** are all properly enabled for the Document module. For **alternative solutions** (activating the document module, exposing a supported endpoint, or a stub workaround), see **BACKEND_ALTERNATIVE_SOLUTIONS.md**.

---

## Backend checklist (enable upload API)

- [ ] **Implement** one document upload action (multipart or JSON per Option A/B below).
- [ ] **Map routes** so the chosen action is reachable at e.g. `.../api/Document/UploadDocument` (or UploadFile, SaveDocument, Post).
- [ ] **Grant the user role permission** to call the Document upload action (see **“Grant user role permission”** below).
- [ ] **Support camera-based uploads**: the same endpoint must accept **Take Photo** and **Scan Document** from the app (POST multipart with `image/jpeg` and filenames like `photo_*.jpg`, `scan_*.jpg`). Same contract as file-manager uploads.
- [ ] **Deploy** and confirm the exact upload URL, then set **`documentUploadEndpointOverride`** in the app (`lib/core/url/api_url.dart`).

**App-side:** Camera and storage permissions are already declared in the app (Android: `AndroidManifest.xml` CAMERA; iOS: `Info.plist` NSCameraUsageDescription). No backend configuration is needed for permissions.

---

## Grant user role permission to call the Document upload action

The **administrator** must grant the **user role** (the role used by mobile app users) permission to call the Document upload action. Otherwise the server may return 403 Forbidden or “upload not available,” and the app will show “Document upload is not available on this server.”

### What to do on the backend

1. **Identify the role** used by mobile app users (e.g. “Mobile User”, “Employee”, “Client”).
2. **Add a permission** that allows calling the Document upload action. Typical permission names (depending on your system):
   - **Document upload**
   - **Document.UploadDocument** (controller.action)
   - **Document.UploadFile** or **Document.SaveDocument** (if that is the action name)
   - Or whatever permission key your API uses to authorize the upload endpoint.
3. **Assign that permission to the role**:
   - **Role/permission admin UI:** Open the screen where roles and permissions are managed (e.g. “Roles”, “Permissions”, “Security”). Add the Document upload permission to the role(s) that mobile users have. Save.
   - **Database:** If permissions are stored in a table (e.g. `RolePermissions`, `AspNetRoleClaims`), insert a row linking the role to the Document upload permission.
   - **Config/code:** If permissions are defined in config or code (e.g. list of allowed actions per role), add the Document upload action to the list for the mobile user role.
4. **Folder-level access (if applicable):** If your API checks whether the user can add documents to a specific folder (DocFolderID), ensure the role has **write/add** access to the folders that mobile users need (e.g. same rules as for “Add folder” or “View folder” for that folder).
5. **Redeploy or restart** the backend if permission changes require it, then test from the app: upload a file or photo into a folder.

### Summary

| Step | Action |
|------|--------|
| 1 | Identify the user role used by the mobile app. |
| 2 | Add/define a permission for the Document upload action (e.g. “Document upload” or “Document.UploadDocument”). |
| 3 | Assign that permission to the role (admin UI, database, or config). |
| 4 | If you check folder access, ensure the role can add documents to the target folder. |
| 5 | Redeploy if needed and test upload from the app. |

This is done **on the server** (admin panel, database, or backend config). The Flutter app does not configure permissions; it only sends the upload request with the user’s token.

---

## Required: One upload endpoint

The server **must** expose **one** of these (or an equivalent that matches the contract below).

### Option A: Multipart form (recommended)

- **URL:** `https://www.cadashboard.com/web/api/Document/<ActionName>`
  - Replace `<ActionName>` with your controller action, e.g. `UploadDocument`, `UploadFile`, `SaveDocument`, or `Post`.
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Form fields:**
  - `tokenID` (string) – auth token
  - `docFolderID` (string/int) – target folder ID
  - One file part with name **`file`**, **`File`**, **`document`**, or **`upload`** (the app tries these)
- **Camera uploads:** Take Photo and Scan Document use this same endpoint: POST multipart with the image bytes, `Content-Type: image/jpeg`, and filenames like `photo_<timestamp>.jpg` or `scan_<timestamp>.jpg`. The controller must accept these like any other file upload.

**Example ASP.NET Web API action:**

```csharp
[HttpPost]
[Route("api/Document/UploadDocument")]  // or UploadFile, SaveDocument, etc.
public async Task<IHttpActionResult> UploadDocument()
{
    if (!Request.Content.IsMimeMultipartContent())
        return BadRequest("Expected multipart/form-data");
    var provider = await Request.Content.ReadAsMultipartAsync();
    // Read tokenID, docFolderID from provider.Contents (form fields)
    // Read file from provider.Contents (part with Content-Disposition: form-data; name="file" or "File" etc.)
    // Save file, create document record, associate with DocFolderID
    return Ok(new { Success = 1, DocumentID = 12345 }); // or "Record inserted successfully."
}
```

- **Success response:** HTTP 200 or 201. Body can be:
  - `"Record inserted successfully."` or
  - JSON e.g. `{ "Success": 1 }` or `{ "DocumentID": 12345 }` (optional; app uses DocumentID for MoveDocument if using a separate File controller).

---

### Option B: JSON with base64 file

- **URL:** Same base, e.g. `.../Document/UploadDocument` or `.../Document/AddDocument`
- **Method:** `POST`
- **Content-Type:** `application/json`
- **Body:**
```json
{
  "TokenID": "<guid>",
  "DocFolderID": 588307,
  "FileName": "photo_123.jpg",
  "FileContent": "<base64-encoded file bytes>"
}
```
- **Success:** HTTP 200/201; body not required to include DocumentID if document is already linked to folder.

---

## Route configuration

- **Controller name:** Must be `Document` (or the app’s base URL must point to the controller that handles document upload).
- **Action name:** Must match the URL path. The app tries (in order):
  - `SaveDocument`
  - `UploadDocument`
  - `Upload`
  - `UploadFile`
  - `AddDocument`
  - `Post`
- **HTTP method:** Must be **POST** for upload. GET will not be used for file upload.

---

## After backend implements the endpoint

1. Confirm the **exact URL** (e.g. `.../Document/UploadDocument`).
2. In the app, open **`lib/core/url/api_url.dart`**.
3. Set **`documentUploadEndpointOverride`** to that full URL (see comment in file). The app will try this URL first for uploads.

---

## Summary

| Item              | Requirement                                      |
|-------------------|--------------------------------------------------|
| Controller        | `Document` (or equivalent via base URL)          |
| Action            | One of: UploadDocument, UploadFile, SaveDocument, Post, AddDocument, Upload |
| HTTP method       | POST                                             |
| Content-Type      | multipart/form-data (or application/json for Option B) |
| Required params   | tokenID, docFolderID, file (or FileContent in JSON) |
| Success response  | 200/201; optional JSON with Success or DocumentID |

If the server returns **"No action was found on the controller"** or the app shows **"Document upload is not available on this server"**, no upload action is configured. Use this spec to implement the upload action, map routes and controller actions correctly, ensure camera-based uploads (Take Photo / Scan Document) are supported by the same endpoint, and then set `documentUploadEndpointOverride` in the app.
