# Why "Document upload is not available on this server" Appears

## Summary

The message **"Document upload is not available on this server. Please ask your administrator to enable the document upload action"** is shown when the **server responds with an HTML or text error page** that contains one of these phrases (case-insensitive):

- `no action was found`
- `no http resource`
- `no action was found on the controller`

That response means the backend received the upload request at a URL that **has no matching controller action** (or route). The app then replaces the raw server message with this user-friendly text. The problem is **server-side**: the upload API is either not implemented, not routed, or not enabled for the app’s role.

---

## 1. Where the message is triggered (app code)

**File:** `lib/core/repository/document/document_repository.dart`

- **Constant:** `_uploadEndpointNotConfiguredMessage` (lines 529–531) is the exact string shown to the user.
- **When it’s used:** The repository checks the **response body** after each upload attempt. If the body (lowercased) contains any of the three phrases above, it calls `failed(_uploadEndpointNotConfiguredMessage)` instead of showing the raw HTML/error.

**Places that can show this message:**

| Location        | When it happens |
|----------------|------------------|
| Multipart loop | Server returns 200/201 but body contains "no action was found" (or similar), and no other URL/field name succeeds. |
| After multipart | All multipart attempts finished; last response body contains the action/resource error text. |
| Parse failure   | Server returns 200 with HTML error page; `handleResponse`/parsing fails and body contains the same phrases. |

So: the app only shows this message when the **server response body** indicates a missing action/route.

---

## 2. Upload flow (what the app does)

For **every** upload (camera, scan, or file picker), the app:

1. **Base64 JSON** – POSTs to a list of JSON upload URLs with `TokenID`, `DocFolderID`, `FileName`, `FileContent` (base64). If the server returns 200/201 and valid success, upload is done.
2. **Form-urlencoded** – Same payload as form fields. Same “try next URL on failure” behavior.
3. **Multipart** – POSTs `multipart/form-data` with `tokenID`, `docFolderID`, and the file under different field names (`file`, `File`, `document`, `upload`) to a long list of URLs.

For each multipart request, the app sends:

- **URL:** One of the built-in URLs (or the override URL first if set).
- **Query:** `tokenID`, `docFolderID` (also in form fields).
- **Body:** One file part (field name tried in order: `file`, `File`, `document`, `upload`).

If the **server responds with HTTP 200 (or 201)** but the **body** is an HTML error page containing “no action was found” (or “no http resource” / “no action was found on the controller”), the app treats that as “upload endpoint not configured” and shows the friendly message.

---

## 3. URLs the app tries (with current `baseUrl`)

**Base:** `https://www.cadashboard.com/web/api/`

**Override:** `Urls.documentUploadEndpointOverride` is currently **empty**, so the app uses only the built-in list below.

**Multipart (in order, with query `tokenID` and `docFolderID`):**

1. `Document/SaveDocument`
2. `Document/UploadDocument` (and variants)
3. `Document` (controller root)
4. `Documents/Upload`, `Documents/UploadFile`, `Documents/UploadDocument`, `Documents/SaveDocument`, `Documents/AddDocument`
5. `File/Upload`, `File/UploadFile`
6. `Document/Upload`, `Document/UploadFile`, `Document/AddDocument`, `Document/Post`
7. Plus path-only variants (e.g. without query when applicable)

**Base64 JSON / form-urlencoded:**

- `Document/UploadDocument`, `Document/AddDocument`
- `Documents/UploadDocument`, `Documents/AddDocument`
- If override is set, that URL is tried first.

So the app is already calling many possible upload endpoints. If **every** attempt returns a response whose body contains “no action was found” (or the other two phrases), the user sees the “Document upload is not available on this server” message.

---

## 4. Root cause

- The **server** is responding (often with **HTTP 200**) with an **HTML or text error page** that says something like “No action was found on the controller ‘Document’…” (or “No HTTP resource was found…”).
- In ASP.NET Web API style backends, that usually means:
  - **No route** matches the requested path/method, or
  - **No action** on the controller handles that verb/route, or
  - The **Document (or File) upload action** exists but is **not enabled** for the app’s user role (e.g. 403 or a custom error page that includes the same text).

So the **backend** is telling the client “this URL/action doesn’t exist or isn’t available.” The app correctly interprets that and shows the single, clear message: “Document upload is not available on this server. Please ask your administrator to enable the document upload action.”

---

## 5. What must be fixed (backend)

To remove this error and allow uploads (camera, scan, file picker):

1. **Implement** a document upload action (e.g. on a `Document` or `File` controller) that:
   - Accepts POST.
   - Accepts either:
     - **Multipart:** `tokenID`, `docFolderID`, and file (field name e.g. `file` or `File`), or
     - JSON/form body as per your API (TokenID, DocFolderID, FileName, FileContent base64 if you use that).
2. **Map the route** so one of the URLs the app uses (e.g. `.../api/Document/UploadDocument` or `.../api/Document/SaveDocument`) reaches that action.
3. **Enable permissions** for the mobile app’s user role so that the upload action is allowed (see `BACKEND_DOCUMENT_UPLOAD_SPEC.md`, “Grant user role permission”).
4. **Deploy** and, if needed, set **`documentUploadEndpointOverride`** in `lib/core/url/api_url.dart` to the exact working URL.

Until the backend exposes and allows an upload action at a URL the app calls, every attempt can still return the “no action was found” (or similar) response and the app will keep showing “Document upload is not available on this server. Please ask your administrator to enable the document upload action.”

---

## 6. References in this repo

- **Backend contract and permissions:** `BACKEND_DOCUMENT_UPLOAD_SPEC.md`
- **Implementation steps:** `BACKEND_IMPLEMENTATION_GUIDE.md` (if present)
- **Upload URLs and logic:** `lib/core/url/api_url.dart`, `lib/core/repository/document/document_repository.dart`
