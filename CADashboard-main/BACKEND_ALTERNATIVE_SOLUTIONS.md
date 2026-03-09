# Alternative Backend Solutions: Enable Document Uploads

The app shows **"Document upload is not available on this server"** because no upload endpoint is reachable. Client-side changes are complete; the fix must be on the server. This document gives **alternative backend solutions and configurations** when standard implementation is blocked.

---

## 1. Activate the document module / set document.upload.enabled=true

Many backends use a **config key** such as **`document.upload.enabled=true`** (or `DocumentUpload:Enabled`, `Modules:Document:Enabled`) to enable document uploads and grant permission for users to upload. The **backend** reads this; the Flutter app does not.

### Where to put document.upload.enabled=true (on the backend)

| Location | How to set | Notes |
|----------|------------|--------|
| **appsettings.json** (ASP.NET Core) | Add under `AppSettings` or root: `"DocumentUpload": { "Enabled": true }` or `"document.upload.enabled": "true"`. | Redeploy after change. |
| **web.config** (ASP.NET / IIS) | In `<appSettings>` add: `<add key="document.upload.enabled" value="true" />`. | Redeploy or restart app pool. |
| **Environment variable** | Set `document.upload.enabled=true` (or `DocumentUpload__Enabled=true` for ASP.NET Core) in the server environment or hosting panel. | Restart the app after change. |
| **Database** | In a settings table (e.g. `AppSetting`, `SystemConfig`), add or update a row: key = `document.upload.enabled`, value = `true`. Backend must read this and enable the upload action. | Ensure the API reads this and allows upload when true. |
| **Admin / config UI** | If your system has a “Settings” or “Features” screen, enable “Document upload” or set “document.upload.enabled” to true for the environment/tenant. | Saves to config or database; backend must respect it. |

After setting it, the **backend** must:

- Expose the upload endpoint (Document/UploadDocument or equivalent) when enabled.
- Allow the user role to call that action (role permission for “Document upload”).
- Redeploy or restart if the config is in a file or environment.

The **Flutter app** does not read `document.upload.enabled`; it only calls the upload URL. If the server has the endpoint enabled and the user’s role has permission, uploads will work.

---

### Other places to activate (if your backend uses different names)

| System | Where to activate |
|--------|-------------------|
| **Admin / config UI** | Look for "Modules", "Features", "Document management", or "Document upload". Enable "Document" or "Document upload" for the environment (e.g. production/staging) and for the roles that use the mobile app. |
| **Database** | Tables such as `Module`, `Feature`, `RolePermission`, or `AppSetting`. Ensure the document upload module/action is enabled (e.g. `IsActive = 1`) and linked to the mobile user role. |
| **IIS / Application** | Some apps use an application setting or virtual directory switch to enable modules. Check the application’s configuration in IIS or the hosting panel. |

### What to request from IT / backend

- **“Enable the document module”** (or “document upload feature”) for the API that serves the mobile app.
- **“Ensure the Document controller and upload action are included in the build and routing”** (not excluded by feature flags or environment config).

---

## 2. Expose a supported upload endpoint

The app calls **POST** to URLs like:

- `https://www.cadashboard.com/web/api/Document/UploadDocument`
- `https://www.cadashboard.com/web/api/Document/SaveDocument`
- `https://www.cadashboard.com/web/api/Document/UploadFile`

The server must **expose one of these** (or an equivalent) and **route** it to an action that accepts multipart uploads.

### Option A: Add a minimal upload action (ASP.NET Web API 2)

1. **Open or create** `DocumentController` in the backend project (e.g. `Controllers/DocumentController.cs`).
2. **Add** an action that accepts multipart and returns 200:

```csharp
[HttpPost]
[Route("api/Document/UploadDocument")]
public async Task<IHttpActionResult> UploadDocument()
{
    if (!Request.Content.IsMimeMultipartContent())
        return BadRequest("Expected multipart/form-data");
    var provider = await Request.Content.ReadAsMultipartAsync();
    string tokenID = null, docFolderIDStr = null;
    byte[] fileBytes = null;
    foreach (var part in provider.Contents)
    {
        var name = part.Headers?.ContentDisposition?.Name?.Trim('"');
        if (name == null) continue;
        if (name.Equals("tokenID", StringComparison.OrdinalIgnoreCase))
            tokenID = await part.ReadAsStringAsync();
        else if (name.Equals("docFolderID", StringComparison.OrdinalIgnoreCase))
            docFolderIDStr = await part.ReadAsStringAsync();
        else if (name.Equals("file", StringComparison.OrdinalIgnoreCase) || name.Equals("File", StringComparison.OrdinalIgnoreCase))
            fileBytes = await part.ReadAsByteArrayAsync();
    }
    if (string.IsNullOrEmpty(tokenID) || fileBytes == null || fileBytes.Length == 0)
        return BadRequest("tokenID and file required");
    // TODO: Validate token, save file and document record, link to docFolderID
    return Ok(new { Success = 1, DocumentID = 0 });
}
```

3. **Enable attribute routing** in `WebApiConfig.cs`: `config.MapHttpAttributeRoutes();`
4. **Increase max request size** in `web.config` (see section 4 below).

### Option B: ASP.NET Core

1. **Add** a controller with a POST action:

```csharp
[ApiController]
[Route("api/[controller]")]
public class DocumentController : ControllerBase
{
    [HttpPost("UploadDocument")]
    public async Task<IActionResult> UploadDocument()
    {
        if (!Request.HasFormContentType) return BadRequest("Expected multipart/form-data");
        var form = await Request.ReadFormAsync();
        var tokenID = form["tokenID"].ToString();
        var docFolderIDStr = form["docFolderID"].ToString();
        var file = form.Files.GetFile("file") ?? form.Files.GetFile("File");
        if (string.IsNullOrEmpty(tokenID) || file == null || file.Length == 0)
            return BadRequest("tokenID and file required");
        // TODO: Validate token, save file and document record
        return Ok(new { Success = 1, DocumentID = 0 });
    }
}
```

2. **Ensure** controllers are mapped (`app.MapControllers()` or `endpoints.MapControllers()`).
3. **Set** `MultipartBodyLengthLimit` and, if using Kestrel, `MaxRequestBodySize` (see section 4).

### Option C: Use an existing endpoint

If the backend **already has** an upload action under a different path (e.g. `File/Upload`, `Documents/Post`):

1. **Confirm** the exact URL (e.g. with Postman: POST multipart with `tokenID`, `docFolderID`, and `file`).
2. **In the Flutter app**, set **`documentUploadEndpointOverride`** in `lib/core/url/api_url.dart` to that full URL. The app will call that URL first.

---

## 3. Approved workaround: temporary stub endpoint

If a **full document storage implementation** is not ready, the backend can expose a **stub** that:

- Accepts **POST** with **multipart/form-data** (`tokenID`, `docFolderID`, and file).
- **Validates the token** (same as other APIs).
- Returns **200** with `{ "Success": 1 }` (and optionally `DocumentID`).
- Optionally **saves the file** to a temporary or staging location and logs it for later processing.

This removes the “Document upload is not available” message and allows the app to work; storage and business rules can be completed later.

---

## 4. Required server configuration

Regardless of which option is used:

| Item | Purpose |
|------|--------|
| **Max request size** | Allow file uploads (e.g. 10–50 MB). **IIS** `web.config`: `<requestLimits maxAllowedContentLength="52428800" />` (50 MB). **ASP.NET Core**: `MultipartBodyLengthLimit` and, if applicable, Kestrel `MaxRequestBodySize`. |
| **Multipart** | Do not disable multipart handling for the Document (or File) API. |
| **Route** | The chosen URL (e.g. `.../Document/UploadDocument`) must be routed to the controller action; attribute routing or convention-based routing must include it. |
| **Permissions** | The user role used by the mobile app must have permission to call the upload action (see BACKEND_DOCUMENT_UPLOAD_SPEC.md → “Grant user role permission”). |

---

## 5. Camera and file uploads (same endpoint)

The app sends **camera** (Take Photo / Scan Document) and **file picker** uploads to the **same** endpoint:

- **Content-Type:** `multipart/form-data`
- **Fields:** `tokenID`, `docFolderID`, and one file part (name `file`, `File`, `document`, or `upload`).
- **Camera:** Same format with `image/jpeg` and filenames like `photo_*.jpg`, `scan_*.jpg`.

No separate URL or action is required for camera vs file uploads.

---

## 6. After the backend is ready

1. **Verify** the upload URL with Postman (POST multipart → 200/201).
2. **In the Flutter app**, set **`documentUploadEndpointOverride`** in `lib/core/url/api_url.dart` to that URL (e.g. `https://www.cadashboard.com/web/api/Document/UploadDocument`).
3. **Test** from the app: Upload files, Take Photo, Scan Document.

---

## 7. Escalation / what to send to backend or IT

You can send the following to the team that owns the API:

- **“Please enable document uploads by doing one of the following:**
  1. **Activate the document module** (or document upload feature) in config/admin/database so the Document API is enabled.
  2. **Expose a supported upload endpoint**: e.g. `POST .../api/Document/UploadDocument` (or `SaveDocument` / `UploadFile`) that accepts multipart/form-data with `tokenID`, `docFolderID`, and a file. Use the code samples in **BACKEND_ALTERNATIVE_SOLUTIONS.md** or **BACKEND_DOCUMENT_UPLOAD_SPEC.md**.
  3. **If a full implementation is not ready**, add a **stub** that validates the token and returns `{ "Success": 1 }` so the app can proceed; storage can be completed later.
- **Ensure** max request size allows uploads (e.g. 50 MB), **routes** are registered, and the **mobile user role** has permission to call the upload action.”

Attach or link: **BACKEND_DOCUMENT_UPLOAD_SPEC.md**, **BACKEND_ALTERNATIVE_SOLUTIONS.md**, and, if present, **BACKEND_IMPLEMENTATION_GUIDE.md** and **backend_sample/**.
