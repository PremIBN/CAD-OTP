# Backend upload endpoint – stream/resource handling (verification)

This note is for **backend** implementers. The Flutter app may log an Android warning **"A resource failed to call close"** if response streams are not fully consumed on the client. The app has been updated to always drain response streams. On the server, defensive handling of request streams and response bodies helps avoid similar issues and ensures resources are released.

## Server-side best practices (verification only)

- **Request body (multipart)**
  - Use **try-with-resources** (Java/Kotlin) or **using** (C#) for any `InputStream` / `MultipartFile` stream used to read the uploaded file.
  - Close or fully read the request body stream in a `finally` block (or equivalent) so it is always released even when validation or business logic throws.

- **Response body**
  - Ensure the response output stream or writer is closed after writing the JSON (or error) so the client can finish reading and the connection can be cleaned up.

- **Logging**
  - Log upload attempts and outcomes (e.g. success/failure, file size, folder ID) only; avoid logging full file contents or raw request bodies. Use safe, bounded logging for errors (e.g. truncate long messages).

No database schema, business logic, or new permissions are required; this is defensive coding and verification only.
