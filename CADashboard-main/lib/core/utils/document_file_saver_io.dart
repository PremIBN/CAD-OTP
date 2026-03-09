import 'dart:io';
import 'dart:typed_data';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:path_provider/path_provider.dart';

/// Sanitizes [fileName] for use in a path: removes invalid chars, preserves extension and format.
String sanitizeDocumentFileName(String fileName) {
  if (fileName.trim().isEmpty) return 'document';
  final sanitized = fileName
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return sanitized.isEmpty ? 'document' : sanitized;
}

/// Fixed subfolder name under Downloads (or fallback) so all documents are in one place.
const String _downloadsSubfolder = 'CADashboard';

/// Standard public Downloads path on Android (Environment.DIRECTORY_DOWNLOADS).
/// Used so files appear in File Manager under Download/CADashboard.
String get _androidDownloadsPath {
  final external = Platform.environment['EXTERNAL_STORAGE'];
  if (external != null && external.isNotEmpty) {
    return '$external${Platform.pathSeparator}Download';
  }
  return '/storage/emulated/0/Download';
}

/// Resolves the fixed base directory for downloaded documents. Prefers user-visible locations:
/// Android: public Download/CADashboard; then app-specific external root; then external downloads; then path_provider downloads; then app temp. Never throws.
Future<Directory> _getDocumentsBaseDir() async {
  if (Platform.isAndroid) {
    try {
      final downloadDir = Directory(_androidDownloadsPath);
      final base = Directory('${downloadDir.path}${Platform.pathSeparator}$_downloadsSubfolder');
      await base.create(recursive: true);
      return base;
    } catch (_) {}
    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final base = Directory('${extDir.path}${Platform.pathSeparator}$_downloadsSubfolder');
        await base.create(recursive: true);
        return base;
      }
    } catch (_) {}
    try {
      final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (dirs != null && dirs.isNotEmpty) {
        final base = Directory('${dirs.first.path}${Platform.pathSeparator}$_downloadsSubfolder');
        await base.create(recursive: true);
        return base;
      }
    } catch (_) {}
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) {
        final base = Directory('${dir.path}${Platform.pathSeparator}$_downloadsSubfolder');
        await base.create(recursive: true);
        return base;
      }
    } catch (_) {}
  }

  try {
    final temp = await getTemporaryDirectory();
    final base = Directory('${temp.path}${Platform.pathSeparator}CADashboard_Documents');
    if (!await base.exists()) await base.create(recursive: true);
    return base;
  } catch (_) {
    final base = Directory('${Directory.systemTemp.path}${Platform.pathSeparator}CADashboard_Documents');
    if (!await base.exists()) await base.create(recursive: true);
    return base;
  }
}

/// Returns the base path where documents are saved (for user-facing messages).
Future<String> getDocumentsBasePath() async {
  final dir = await _getDocumentsBaseDir();
  return dir.path;
}

/// Returns the full path if a document with [fileName] already exists in the download folder; otherwise null.
/// [relativePathPrefix] is the folder path under the base (e.g. "FolderName" or "FolderA/FolderB") so files saved during folder download are found.
Future<String?> getLocalDocumentPathIfExists(String fileName, {String? relativePathPrefix}) async {
  try {
    final base = await _getDocumentsBaseDir();
    final safeName = sanitizeDocumentFileName(fileName);
    final relative = (relativePathPrefix != null && relativePathPrefix.trim().isNotEmpty)
        ? '${relativePathPrefix.replaceAll('\\', '/').trim()}/$safeName'
        : safeName;
    final path = relative.replaceAll('/', Platform.pathSeparator);
    final file = File('${base.path}${Platform.pathSeparator}$path');
    if (await file.exists()) return file.path;
  } catch (_) {}
  return null;
}

/// Saves [bytes] to the fixed download location under [relativePath] (e.g. "FolderName/sub/file.pdf").
/// Creates parent directories as needed. Returns saved file path or null.
Future<String?> saveDocumentBytesToPath(Uint8List bytes, String relativePath) async {
  try {
    final base = await _getDocumentsBaseDir();
    final path = relativePath.replaceAll('/', Platform.pathSeparator);
    final segments = path.split(Platform.pathSeparator);
    final sanitizedPath = segments.map(sanitizeDocumentFileName).join(Platform.pathSeparator);
    final file = File('${base.path}${Platform.pathSeparator}$sanitizedPath');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file.path;
  } catch (_) {
    return null;
  }
}

/// Saves [bytes] as [fileName]. On Android/iOS tries public Downloads (File Manager) first via downloadsfolder; falls back to app folder so file is always saved without crashing.
Future<String?> saveDocumentBytes(Uint8List bytes, String fileName) async {
  final safeName = sanitizeDocumentFileName(fileName);
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}${Platform.pathSeparator}cad_$safeName');
      await tempFile.writeAsBytes(bytes);
      final success = await copyFileIntoDownloadFolder(tempFile.path, safeName);
      try {
        await tempFile.delete();
      } catch (_) {}
      if (success == true) {
        final dir = await getDownloadDirectory();
        return '${dir.path}${Platform.pathSeparator}$safeName';
      }
    } catch (_) {}
  }
  try {
    return await saveDocumentBytesToPath(bytes, safeName);
  } catch (_) {
    return null;
  }
}

/// Copies an existing file from [tempFilePath] into the download folder as [fileName].
/// Returns the final path on success, null otherwise. Use after streaming download to temp file.
Future<String?> saveDocumentFromPath(String tempFilePath, String fileName) async {
  final safeName = sanitizeDocumentFileName(fileName);
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final success = await copyFileIntoDownloadFolder(tempFilePath, safeName);
      if (success == true) {
        final dir = await getDownloadDirectory();
        return '${dir.path}${Platform.pathSeparator}$safeName';
      }
    }
    final base = await _getDocumentsBaseDir();
    final dest = File('${base.path}${Platform.pathSeparator}$safeName');
    await dest.parent.create(recursive: true);
    await File(tempFilePath).copy(dest.path);
    return dest.path;
  } catch (_) {
    return null;
  }
}
