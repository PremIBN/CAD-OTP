import 'dart:typed_data';

/// Stub for web: temp file path not available; upload uses bytes only.
Future<String?> saveBytesToTempUpload(Uint8List bytes, String fileName) async =>
    null;

/// Stub for web: no-op.
Future<void> deleteTempUploadFile(String path) async {}
