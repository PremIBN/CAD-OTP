import 'dart:typed_data';

/// Stub for web: saving to app documents is not available.
Future<String?> saveDocumentBytes(Uint8List bytes, String fileName) async =>
    null;

/// Stub for web: saving with path is not available.
Future<String?> saveDocumentBytesToPath(Uint8List bytes, String relativePath) async =>
    null;

/// Stub for web: base path not available.
Future<String> getDocumentsBasePath() async => '';

/// Stub for web: local file check not available.
Future<String?> getLocalDocumentPathIfExists(String fileName, {String? relativePathPrefix}) async =>
    null;

/// Stub for web: saving from path not available.
Future<String?> saveDocumentFromPath(String tempFilePath, String fileName) async => null;
