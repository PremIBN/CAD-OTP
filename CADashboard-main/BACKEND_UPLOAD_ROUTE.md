# Document upload: fix "No action was found on the controller"

The mobile app uploads files with:

- **Method:** `POST`
- **URL (try one of these; app override is currently the second):**
  - `https://www.cadashboard.com/web/api/Document/UploadDocument`
  - `https://www.cadashboard.com/web/api/Documents/UploadDocument`
- **Query/form:** `tokenID`, `docFolderID`
- **Body:** `multipart/form-data` with a file part named **`file`**

If the server returns **"No action was found on the controller"**, the route or action is missing. Add one of the following on the backend.

---

## Option A: DocumentsController (plural) – recommended if your API uses `api/Documents/`

```csharp
[RoutePrefix("api/Documents")]
public class DocumentsController : ApiController
{
    [HttpPost]
    [Route("UploadDocument")]
    public async Task<IHttpActionResult> UploadDocument(string tokenID, int docFolderID)
    {
        if (!Request.Content.IsMimeMultipartContent())
            return BadRequest("Content-Type must be multipart/form-data");

        var provider = new MultipartMemoryStreamProvider();
        await Request.Content.ReadAsMultipartAsync(provider);

        var fileContent = provider.Contents.FirstOrDefault(c =>
            c.Headers.ContentDisposition?.Name?.Trim('"').Equals("file", StringComparison.OrdinalIgnoreCase) == true);
        if (fileContent == null)
            return BadRequest("No file part named 'file'.");

        var fileName = fileContent.Headers.ContentDisposition?.FileName?.Trim('"') ?? "upload";
        var bytes = await fileContent.ReadAsByteArrayAsync();

        // TODO: validate tokenID, check user can upload to docFolderID, save file and create document record.
        int newDocumentId = 1; // replace with real ID from your save logic

        return Ok(new { Success = 1, Message = "Uploaded successfully", DocumentID = newDocumentId });
    }
}
```

- **Route:** `POST api/Documents/UploadDocument`
- **Full URL:** `https://www.cadashboard.com/web/api/Documents/UploadDocument`

---

## Option B: DocumentController (singular)

If your API uses `api/Document/` (singular), add the same action there:

```csharp
[RoutePrefix("api/Document")]
public class DocumentController : ApiController
{
    [HttpPost]
    [Route("UploadDocument")]
    public async Task<IHttpActionResult> UploadDocument(string tokenID, int docFolderID)
    {
        // Same implementation as Option A.
    }
}
```

- **Route:** `POST api/Document/UploadDocument`

---

## Checklist

1. **Route prefix** matches your existing API (e.g. `api/` or `web/api/`).
2. **Action is POST** and named `UploadDocument` (or route explicitly set with `[Route("UploadDocument")]`).
3. **Parameters** `tokenID` (string) and `docFolderID` (int) are bound from query or form.
4. **Multipart** is read and the part named `file` is processed.
5. **User role** that the mobile app uses has permission to call this action.

After adding the action and redeploying, set the app’s override in `lib/core/url/api_url.dart` to the URL that matches your controller:

- Documents (plural): `.../Documents/UploadDocument`
- Document (singular): `.../Document/UploadDocument`

Then upload from the app again; the error should stop once the route exists and is allowed.
