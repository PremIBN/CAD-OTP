import 'dart:io';
import 'dart:typed_data';

const String _uploadSubdir = 'document_uploads';

/// Saves [bytes] to a temp location (system temp dir) for multipart upload.
/// Returns the file path, or null on error.
Future<String?> saveBytesToTempUpload(Uint8List bytes, String fileName) async {
  try {
    final dir = Directory.systemTemp;
    final subdir = Directory('${dir.path}${Platform.pathSeparator}$_uploadSubdir');
    if (!await subdir.exists()) await subdir.create(recursive: true);
    final safeName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final path = '${subdir.path}${Platform.pathSeparator}upload_${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  } catch (_) {
    return null;
  }
}

/// Deletes the temp upload file at [path]. No-op if path is empty or file missing.
Future<void> deleteTempUploadFile(String path) async {
  if (path.isEmpty) return;
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
