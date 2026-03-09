import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/document/document_folder_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/services/document_upload_service.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Raw GET for binary response (e.g. file download). Does not use handleResponse.
Future<http.Response> _rawGet(Uri url) async {
  return http.get(url);
}

/// Reads [response] body and ensures the stream is drained on error so the underlying
/// resource is released (avoids Android "A resource failed to call close").
Future<String> _readResponseBodySafely(http.StreamedResponse response) async {
  try {
    return await response.stream.bytesToString();
  } catch (_) {
    try {
      await response.stream.drain();
    } catch (_) {
      // Stream may already be consumed or cancelled; ignore.
    }
    return '';
  }
}

/// Document API access is subject to location-based access control. When the user is
/// outside the assigned geo-fenced zone, getMethod (e.g. getFolderList, getDocumentURL)
/// returns a location-denied error and documents/images cannot be loaded from the server,
/// which can result in blank views. Resolution: correct device location or backend
/// location validation—not viewer or repository changes.
class DocumentRepository extends ApiClient {
  Future<void> getFolderList({
    String clientOrgID = '0',
    String? financialYearID,
    required Function(List<DocumentFolderModel> response) success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.getFolderList(
      tokenID: tokenID,
      clientOrgID: clientOrgID,
      financialYearID: financialYearID,
    );

    final result = await getMethod(url: Uri.parse(url));

    try {
      if (result is Map) {
        final successFlag = result['Success'];
        final message = result['Message']?.toString() ?? '';
        final data = result['Data'];
        if (successFlag == 0 || (message.isNotEmpty && successFlag != 1)) {
          final lower = message.toLowerCase();
          final isNoDataResponse = data is List && data.isEmpty ||
              lower.contains('no data') ||
              lower.contains('no record') ||
              lower.contains('no document') ||
              lower.contains('not found');
          if (isNoDataResponse) {
            success([]);
            return;
          }
          failed(message.isNotEmpty ? message : errorMessage);
        return;
        }
      }
      List<DocumentFolderModel> list = [];
      if (result is List) {
        for (final e in result) {
          try {
            if (e is Map<String, dynamic>) {
              list.add(DocumentFolderModel.fromJson(e));
            } else if (e is Map) {
              list.add(DocumentFolderModel.fromJson(Map<String, dynamic>.from(e)));
            }
          } catch (_) {
            // skip malformed item
          }
        }
      } else if (result is Map && result['Data'] is List) {
        final dataList = result['Data'] as List;
        for (final e in dataList) {
          try {
            if (e is Map<String, dynamic>) {
              list.add(DocumentFolderModel.fromJson(e));
            } else if (e is Map) {
              list.add(DocumentFolderModel.fromJson(Map<String, dynamic>.from(e)));
            }
          } catch (_) {
            // skip malformed item
          }
        }
      } else if (result is Map) {
        try {
          list.add(DocumentFolderModel.fromJson(Map<String, dynamic>.from(result)));
        } catch (_) {
          failed(errorMessage);
          return;
        }
      }
      success(list);
    } catch (e) {
      log('DocumentRepository getFolderList: $e');
      failed(errorMessage);
    }
  }

  /// Fetches one folder's contents (FolderDocuments + FolderList) by folder ID for recursive download.
  /// Uses same client/fy as GetFolderList. Backend may return one folder object or list with one item.
  Future<void> getFolderContents({
    required int folderID,
    String clientOrgID = '0',
    String? financialYearID,
    required Function(DocumentFolderModel folder) success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.getFolderContents(
      tokenID: tokenID,
      folderID: folderID,
      clientOrgID: clientOrgID,
      financialYearID: financialYearID,
    );
    try {
      final result = await getMethod(url: Uri.parse(url));
      if (result is Map) {
        final successFlag = result['Success'];
        final message = result['Message']?.toString() ?? '';
        if (successFlag == 0 || (message.isNotEmpty && successFlag != 1)) {
          final lower = message.toLowerCase();
          if (!lower.contains('no data') && !lower.contains('no record')) {
            failed(message.isNotEmpty ? message : errorMessage);
            return;
          }
        }
      }
      DocumentFolderModel? folder;
      if (result is Map && result['Data'] is Map) {
        final data = result['Data'] as Map;
        folder = DocumentFolderModel.fromJson(Map<String, dynamic>.from(data));
      } else if (result is Map && (result['FolderDocuments'] != null || result['FolderList'] != null)) {
        folder = DocumentFolderModel.fromJson(Map<String, dynamic>.from(result));
      } else if (result is List && result.length == 1 && result.first is Map) {
        folder = DocumentFolderModel.fromJson(Map<String, dynamic>.from(result.first as Map));
      } else if (result is Map) {
        folder = DocumentFolderModel.fromJson(Map<String, dynamic>.from(result));
      }
      if (folder != null) {
        success(folder);
      } else {
        failed(errorMessage);
      }
    } catch (e) {
      log('DocumentRepository getFolderContents: $e');
      failed(errorMessage);
    }
  }

  Future<void> getDocumentURL({
    required int documentId,
    required void Function(String url, [String? token]) success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.getDocumentURL(tokenID: tokenID, id: documentId);

    final result = await getMethod(url: Uri.parse(url));

    try {
      if (result is Map && result['Success'] == 0) {
        failed(result['Message']?.toString() ?? errorMessage);
        return;
      }
      String? viewUrl;
      dynamic data = result;
      if (result is String) {
        final s = result.trim();
        if (s.startsWith('http://') || s.startsWith('https://')) {
          viewUrl = s;
        } else {
        try {
          data = jsonDecode(result);
          if (data is String) data = jsonDecode(data);
        } catch (_) {
            final match = RegExp(r'"url"\s*:\s*"([^"]+)"', caseSensitive: false).firstMatch(result);
            if (match != null) viewUrl = match.group(1)?.replaceAll(r'\/', '/');
          }
        }
      }
      if (viewUrl == null && data is Map) {
        viewUrl = (data['url'] ?? data['Url'] ?? data['URL'] ?? data['ViewUrl'] ?? data['ViewURL'])?.toString().replaceAll(r'\/', '/');
        if (viewUrl == null) {
          final dataPayload = data['Data'] ?? data['data'];
          if (dataPayload is Map) {
            viewUrl = (dataPayload['url'] ?? dataPayload['Url'] ?? dataPayload['ViewUrl'] ?? dataPayload['ViewURL'])?.toString().replaceAll(r'\/', '/');
          } else if (dataPayload is String && (dataPayload.startsWith('http://') || dataPayload.startsWith('https://'))) {
            viewUrl = dataPayload;
          }
        }
      }
      if (viewUrl != null && viewUrl.isNotEmpty) {
        // Resolve relative URLs against API base so WebView can load them.
        if (!viewUrl.startsWith('http://') && !viewUrl.startsWith('https://')) {
          final base = Uri.parse(Urls.baseUrl);
          viewUrl = base.resolve(viewUrl.startsWith('/') ? viewUrl : '/$viewUrl').toString();
        }
        // Append token so the document server can authorize the WebView request (avoids blank content).
        if (!viewUrl.toLowerCase().contains('tokenid=')) {
          final separator = viewUrl.contains('?') ? '&' : '?';
          viewUrl = '$viewUrl${separator}tokenID=${Uri.encodeComponent(tokenID)}';
        }
        success(viewUrl, tokenID);
      } else {
        failed('Could not get document URL');
      }
    } catch (e) {
      log('DocumentRepository getDocumentURL: $e');
      failed(errorMessage);
    }
  }

  Future<void> checkFolderNameExists({
    required String folderName,
    required int parentFolderId,
    required Function(List<DocumentFolderModel> existing) success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.checkFolderNameExist(
      tokenID: tokenID,
      foldername: folderName,
      parentfolderid: parentFolderId,
    );

    final result = await getMethod(url: Uri.parse(url));

    try {
      if (result is Map && result['Success'] == 0) {
        failed(result['Message']?.toString() ?? errorMessage);
        return;
      }
      List<DocumentFolderModel> list = [];
      if (result is List) {
        for (final e in result) {
          try {
            if (e is Map<String, dynamic>) {
              list.add(DocumentFolderModel.fromJson(e));
            } else if (e is Map) {
              list.add(DocumentFolderModel.fromJson(Map<String, dynamic>.from(e)));
            }
          } catch (_) {}
        }
      }
      success(list);
    } catch (e) {
      log('DocumentRepository checkFolderNameExists: $e');
      failed(errorMessage);
    }
  }

  Future<void> addFolder({
    required int docFolderId,
    required String folderName,
    required int parentFolderId,
    required Function() success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final body = {
      'DocFolderID': docFolderId,
      'FolderName': folderName.trim(),
      'FolderPath': '',
      'TokenID': tokenID,
      'FinancialYearID': 0,
      'ParentFolderId': parentFolderId,
      'Comments': '',
      'ClientID': 0,
    };
    final result = await postJsonMethod(
      url: Uri.parse(Urls.addFolder),
      body: body,
    );
    try {
      if (result is Map && result['Success'] == 0) {
        failed(result['Message']?.toString() ?? errorMessage);
        return;
      }
      if (result is String && result.toLowerCase().contains('error')) {
        failed(result);
        return;
      }
      success();
    } catch (e) {
      log('DocumentRepository addFolder: $e');
      failed(errorMessage);
    }
  }

  Future<void> moveDocument({
    required int documentId,
    required int targetFolderId,
    required Function() success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.moveDocument(
      tokenID: tokenID,
      documentID: documentId,
      targetFolderID: targetFolderId,
    );
    final result = await getMethod(url: Uri.parse(url));
    try {
      if (result is String) {
        failed(result);
        return;
      }
      if (result is Map && result['Success'] == 0) {
        failed(result['Message']?.toString() ?? errorMessage);
        return;
      }
      success();
    } catch (e) {
      log('DocumentRepository moveDocument: $e');
      failed(errorMessage);
    }
  }

  Future<void> moveFolder({
    required int folderId,
    required String folderName,
    required int targetFolderId,
    required Function() success,
    required Function(String message) failed,
  }) async {
    await addFolder(
      docFolderId: folderId,
      folderName: folderName,
      parentFolderId: targetFolderId,
      success: success,
      failed: failed,
    );
  }

  /// Returns true if [bytes] start with known document/image/binary magic bytes.
  static bool _isKnownBinary(Uint8List bytes) {
    if (bytes.isEmpty) return false;
    final bodyStart = bytes.length >= 4 ? bytes.sublist(0, 4) : bytes;
    if (bodyStart.length >= 4 &&
        bodyStart[0] == 0x25 && bodyStart[1] == 0x50 && bodyStart[2] == 0x44 && bodyStart[3] == 0x46) return true;
    if (bodyStart.length >= 2 && bodyStart[0] == 0xFF && bodyStart[1] == 0xD8) return true;
    if (bodyStart.length >= 4 &&
        bodyStart[0] == 0x89 && bodyStart[1] == 0x50 && bodyStart[2] == 0x4E && bodyStart[3] == 0x47) return true;
    if (bodyStart.length >= 3 &&
        bodyStart[0] == 0x47 && bodyStart[1] == 0x49 && bodyStart[2] == 0x46) return true;
    if (bytes.length >= 12 &&
        bodyStart[0] == 0x52 && bodyStart[1] == 0x49 && bodyStart[2] == 0x46 && bodyStart[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) return true;
    if (bodyStart.length >= 2 && bodyStart[0] == 0x42 && bodyStart[1] == 0x4D) return true;
    if (bodyStart.length >= 4 &&
        bodyStart[0] == 0x50 && bodyStart[1] == 0x4B &&
        (bodyStart[2] == 0x03 || bodyStart[2] == 0x05 || bodyStart[2] == 0x07) &&
        (bodyStart[3] == 0x04 || bodyStart[3] == 0x06 || bodyStart[3] == 0x08)) return true;
    if (bodyStart.length >= 4 &&
        bodyStart[0] == 0xD0 && bodyStart[1] == 0xCF && bodyStart[2] == 0x11 && bodyStart[3] == 0xE0) return true;
    if (bodyStart.length >= 4 &&
        (bodyStart[0] == 0x49 && bodyStart[1] == 0x49 && bodyStart[2] == 0x2A && bodyStart[3] == 0x00)) return true;
    if (bodyStart.length >= 4 &&
        (bodyStart[0] == 0x4D && bodyStart[1] == 0x4D && bodyStart[2] == 0x00 && bodyStart[3] == 0x2A)) return true;
    return false;
  }

  /// Returns true if [contentType] suggests binary file (image, pdf, Office, octet-stream). Use when body might not have magic bytes.
  static bool _isBinaryContentType(String? contentType) {
    if (contentType == null || contentType.isEmpty) return false;
    final lower = contentType.toLowerCase().split(';').first.trim();
    return lower == 'application/octet-stream' ||
        lower == 'application/pdf' ||
        lower.startsWith('image/') ||
        lower.startsWith('video/') ||
        lower == 'application/zip' ||
        lower.startsWith('application/vnd.') ||
        lower == 'application/msword' ||
        lower == 'application/vnd.ms-excel' ||
        lower == 'application/vnd.ms-powerpoint' ||
        lower.contains('wordprocessingml') ||
        lower.contains('spreadsheetml') ||
        lower.contains('presentationml') ||
        lower == 'text/csv';
  }

  /// Returns true if [bytes] look like binary (null byte, or not valid UTF-8). Use as fallback so wrong Content-Type does not drop files.
  static bool _looksLikeBinary(Uint8List bytes) {
    if (bytes.isEmpty) return false;
    if (bytes.contains(0)) return true;
    try {
      utf8.decode(bytes, allowMalformed: false);
      return false;
    } catch (_) {
      return true;
    }
  }

  /// Keys to look for base64 file content in API responses (top-level and nested).
  static const List<String> _base64Keys = [
    'FileContent', 'FileBytes', 'Content', 'Data', 'File', 'Base64',
    'DocumentContent', 'Bytes', 'Value', 'Result', 'FileData', 'DocumentUrl',
  ];

  /// Tries to extract file bytes from a JSON response (e.g. base64 in FileContent, Data, or nested Data.FileContent). Returns null if not found.
  static Uint8List? _extractBytesFromJson(Uint8List bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final extracted = _extractBytesFromMap(map);
      if (extracted != null) return extracted;
      // Nested: Data.FileContent, Result.FileContent, etc.
      for (final key in ['Data', 'Result', 'Response', 'Payload']) {
        final v = map[key];
        if (v is Map) {
          final fromNested = _extractBytesFromMap(Map<String, dynamic>.from(v));
          if (fromNested != null) return fromNested;
        }
      }
    } catch (_) {}
    return null;
  }

  static Uint8List? _extractBytesFromMap(Map<String, dynamic> map) {
    for (final key in _base64Keys) {
      final v = map[key];
      if (v == null) continue;
      if (v is String) {
        try {
          return Uint8List.fromList(base64Decode(v));
        } catch (_) {}
      }
    }
    return null;
  }

  /// Tries to extract file bytes from HTML or text that contains data: URLs (e.g. data:image/png;base64,... or any MIME). Returns null if none found.
  static Uint8List? _extractBytesFromHtml(Uint8List bytes) {
    try {
      final text = utf8.decode(bytes, allowMalformed: true);
      // Match data:<mime>;base64,<base64payload> for any MIME (image, pdf, office, etc.)
      final re = RegExp(r'data:[^;]+;base64\s*,\s*([A-Za-z0-9+/=]+)', caseSensitive: false);
      final match = re.firstMatch(text);
      if (match != null) {
        final b64 = match.group(1)?.replaceAll(RegExp(r'\s'), '');
        if (b64 != null && b64.isNotEmpty) {
          return Uint8List.fromList(base64Decode(b64));
        }
      }
    } catch (_) {}
    return null;
  }

  /// If [bytes] is JSON containing a file URL (e.g. url, fileUrl, downloadUrl), fetches that URL and returns file bytes or null.
  Future<Uint8List?> _fetchBytesFromJsonUrl(Uint8List bytes, String? tokenID) async {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      String? fileUrl;
      for (final key in ['url', 'Url', 'URL', 'fileUrl', 'FileUrl', 'downloadUrl', 'DownloadUrl', 'documentUrl', 'DocumentUrl']) {
        final v = map[key];
        if (v is String && (v.startsWith('http://') || v.startsWith('https://'))) {
          fileUrl = v;
          break;
        }
      }
      if (fileUrl == null) {
        final data = map['Data'] ?? map['data'];
        if (data is Map) {
          for (final key in ['url', 'Url', 'fileUrl', 'downloadUrl']) {
            final v = data[key];
            if (v is String && (v.startsWith('http://') || v.startsWith('https://'))) {
              fileUrl = v;
              break;
            }
          }
        }
      }
      if (fileUrl == null || fileUrl.isEmpty) return null;
      final uri = Uri.parse(fileUrl);
      http.Response r = tokenID != null && tokenID.isNotEmpty
          ? await http.get(uri, headers: {'Authorization': 'Bearer $tokenID'})
          : await _rawGet(uri);
      if (r.statusCode == 401 || r.statusCode == 403) {
        r = await _rawGet(uri);
      }
      if (r.statusCode != 200 || r.bodyBytes.isEmpty) return null;
      final b = r.bodyBytes;
      if (_isKnownBinary(b) || _isBinaryContentType(r.headers['content-type'])) return b;
      final extracted = _extractBytesFromJson(b);
      return extracted;
    } catch (_) {
      return null;
    }
  }

  /// Tries to get document bytes by fetching the view URL first (same URL used for viewing). Returns bytes or null.
  /// Tries without Bearer first (token in URL) so emulator/servers that only accept query token work.
  Future<Uint8List?> _getDocumentBytesViaViewUrl(int documentId, String tokenID) async {
    final completer = Completer<Uint8List?>();
    getDocumentURL(
      documentId: documentId,
      success: (viewUrl, [token]) async {
        log('Download via view URL (GetDocumentURL): $viewUrl');
        try {
          final uri = Uri.parse(viewUrl);
          http.Response resp = await _rawGet(uri);
          if (resp.statusCode == 401 || resp.statusCode == 403) {
            if (token != null && token.isNotEmpty) {
              resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
              log('Download via view URL retry with Bearer: status=${resp.statusCode}');
            }
          }
          log('Download via view URL status=${resp.statusCode} contentType=${resp.headers['content-type']} len=${resp.bodyBytes.length}');
          if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
            completer.complete(null);
            return;
          }
          final b = resp.bodyBytes;
          final contentType = resp.headers['content-type'];
          if (_isKnownBinary(b) || _isBinaryContentType(contentType)) {
            completer.complete(b);
            return;
          }
          var extracted = _extractBytesFromJson(b);
          if (extracted != null && extracted.isNotEmpty) {
            completer.complete(extracted);
            return;
          }
          extracted = _extractBytesFromHtml(b);
          if (extracted != null && extracted.isNotEmpty) {
            completer.complete(extracted);
            return;
          }
          final fromUrl = await _fetchBytesFromJsonUrl(b, tokenID);
          if (fromUrl != null && fromUrl.isNotEmpty) {
            completer.complete(fromUrl);
            return;
          }
          if (b.isNotEmpty && _looksLikeBinary(b)) {
            completer.complete(b);
            return;
          }
          completer.complete(null);
        } catch (_) {
          completer.complete(null);
        }
      },
      failed: (_) => completer.complete(null),
    );
    return completer.future;
  }

  /// Tries to get document bytes via DownloadDocument API. Returns bytes or null.
  /// Tries without Bearer first (token in URL) so emulator/servers that only accept query token work.
  Future<Uint8List?> _getDocumentBytesViaDownloadApi(int documentId, String tokenID) async {
    try {
      final downloadUri = Uri.parse(Urls.downloadDocument(tokenID: tokenID, documentID: documentId))
          .replace(queryParameters: {
        'tokenID': tokenID,
        'documentID': documentId.toString(),
        'id': documentId.toString(),
      });
      http.Response response = await http.get(downloadUri);
      if (response.statusCode == 401 || response.statusCode == 403) {
        response = await http.get(downloadUri, headers: {'Authorization': 'Bearer $tokenID'});
        log('DownloadDocument retry with Bearer: status=${response.statusCode}');
      }
      log('DownloadDocument status=${response.statusCode} contentType=${response.headers['content-type']} len=${response.bodyBytes.length}');
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }
      final bytes = response.bodyBytes;
      final contentType = response.headers['content-type'];
      if (_isKnownBinary(bytes) || _isBinaryContentType(contentType)) return bytes;
      final extracted = _extractBytesFromJson(bytes);
      if (extracted != null && extracted.isNotEmpty) return extracted;
      final fromHtml = _extractBytesFromHtml(bytes);
      if (fromHtml != null && fromHtml.isNotEmpty) return fromHtml;
      final fromUrl = await _fetchBytesFromJsonUrl(bytes, tokenID);
      if (fromUrl != null && fromUrl.isNotEmpty) return fromUrl;
      if (bytes.isNotEmpty && _looksLikeBinary(bytes)) return bytes;
      return null;
    } catch (e) {
      log('DocumentRepository _getDocumentBytesViaDownloadApi: $e');
      return null;
    }
  }

  /// Download document as raw bytes. Tries view URL first (same as viewing), then DownloadDocument API. Saves to device via caller.
  Future<void> downloadDocument({
    required int documentId,
    required Function(Uint8List bytes) success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken)?.trim() ?? '';
    if (tokenID.isEmpty || tokenID == 'null') {
      failed('Please sign in again to download.');
      return;
    }
    try {
      // Prefer view URL first so already-visible documents download the same way they are viewed.
      Uint8List? bytes = await _getDocumentBytesViaViewUrl(documentId, tokenID);
      if (bytes == null || bytes.isEmpty) {
        bytes = await _getDocumentBytesViaDownloadApi(documentId, tokenID);
      }
      if (bytes != null && bytes.isNotEmpty) {
        success(bytes);
        return;
      }
      _logBodySnippet(Uint8List(0));
      failed('Document not available');
    } catch (e) {
      log('DocumentRepository downloadDocument: $e');
      failed(errorMessage);
    }
  }

  /// Fallback: fetch document bytes by getting the view URL (GetDocumentURL) and then GET that URL. Use when DownloadDocument returns JSON/error.
  // ignore: unused_element
  void _tryDownloadViaDocumentUrl({
    required int documentId,
    required Function(Uint8List bytes) success,
    required Function(String message) failed,
    required String fallbackMsg,
  }) {
    getDocumentURL(
      documentId: documentId,
      success: (viewUrl, [token]) {
        _fetchUrlAndDeliverBytes(viewUrl, token, success, failed, fallbackMsg);
      },
      failed: (_) => failed(fallbackMsg),
    );
  }

  Future<void> _fetchUrlAndDeliverBytes(
    String viewUrl,
    String? token,
    Function(Uint8List bytes) success,
    Function(String message) failed,
    String fallbackMsg,
  ) async {
    try {
      final uri = Uri.parse(viewUrl);
      final resp = token != null && token.isNotEmpty
          ? await http.get(uri, headers: {'Authorization': 'Bearer $token'})
          : await _rawGet(uri);
      log('Fallback download via URL status=${resp.statusCode} contentType=${resp.headers['content-type']} len=${resp.bodyBytes.length}');
      if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
        _logBodySnippet(resp.bodyBytes);
        failed(fallbackMsg);
        return;
      }
      final b = resp.bodyBytes;
      final contentType = resp.headers['content-type'];
      if (_isKnownBinary(b) || _isBinaryContentType(contentType)) {
        success(b);
        return;
      }
      var extracted = _extractBytesFromJson(b);
      if (extracted == null || extracted.isEmpty) {
        extracted = _extractBytesFromHtml(b);
      }
      if (extracted != null && extracted.isNotEmpty) {
        success(extracted);
        return;
      }
      _logBodySnippet(resp.bodyBytes);
      failed(fallbackMsg);
    } catch (_) {
      failed(fallbackMsg);
    }
  }

  /// Log a small snippet of the body (first 200 chars) for debugging server responses.
  void _logBodySnippet(Uint8List bytes) {
    try {
      final text = utf8.decode(bytes, allowMalformed: true);
      final snippet = text.length > 200 ? '${text.substring(0, 200)}...' : text;
      log('Download body snippet: $snippet');
    } catch (_) {
      log('Download body snippet: <non-UTF8 ${bytes.length} bytes>');
    }
  }

  /// Probes the server to check if a document upload endpoint is available.
  /// Returns true if the server accepts the upload route (200/201 or 400 validation);
  /// false if the server returns "no action", 404, or on error.
  /// See BACKEND_DOCUMENT_UPLOAD_SPEC.md for the endpoint the server must implement.
  Future<bool> checkDocumentUploadAvailable() async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    if (tokenID.isEmpty) return false;

    final urlsToProbe = <String>[];
    final override = Urls.documentUploadEndpointOverride.trim();
    if (override.isNotEmpty) {
      urlsToProbe.add(override.contains('?')
          ? '$override&tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=0'
          : '$override?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=0');
    }
    urlsToProbe.addAll([
      Urls.primaryDocumentUploadWithQuery(tokenID: tokenID, docFolderID: 0),
      Urls.saveDocumentWithQuery(tokenID: tokenID, docFolderID: 0),
      Urls.uploadDocumentWithQuery(tokenID: tokenID, docFolderID: 0),
      Urls.uploadFileWithQuery(tokenID: tokenID, docFolderID: 0),
      Urls.fileUploadWithQuery(tokenID: tokenID, docFolderID: 0),
    ]);

    final probeBytes = Uint8List.fromList([0]);
    for (final urlString in urlsToProbe) {
      try {
        final uri = Uri.parse(urlString);
        final request = http.MultipartRequest('POST', uri);
        request.headers['Accept'] = '*/*';
        request.fields['tokenID'] = tokenID;
        request.fields['docFolderID'] = '0';
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          probeBytes,
          filename: 'probe.txt',
          contentType: MediaType('text', 'plain'),
        ));
        final response = await request.send();
        final body = await _readResponseBodySafely(response);
        final status = response.statusCode;
        log('DocumentRepository checkDocumentUploadAvailable: $urlString -> $status');
        if (status == 200 || status == 201) return true;
        if (status == 400) {
          final bodyLower = body.toLowerCase();
          if (bodyLower.contains('no action was found') ||
              bodyLower.contains('no http resource') ||
              bodyLower.contains('no action was found on the controller')) continue;
          return true;
        }
        final bodyLower = body.toLowerCase();
        if (bodyLower.contains('no action was found') ||
            bodyLower.contains('no http resource') ||
            bodyLower.contains('no action was found on the controller')) continue;
        if (status == 404) continue;
      } catch (e) {
        log('DocumentRepository checkDocumentUploadAvailable error: $e');
      }
    }
    return false;
  }

  /// Uploads a document (file/camera/scanner) to [docFolderId].
  /// Administrator permission to enable document upload is configured on the backend, not here.
  /// See BACKEND_DOCUMENT_UPLOAD_SPEC.md → "Grant user role permission" and BACKEND_ALTERNATIVE_SOLUTIONS.md.
  Future<void> UploadDocument({
    required int docFolderId,
    required String clientOrgId,
    String? financialYearId,
    required String fileName,
    required Uint8List fileBytes,
    required Function() success,
    required Function(String message) failed,
  }) async {
    if (fileBytes.isEmpty) {
      failed('Image data is empty. Please try capturing again.');
      return;
    }
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    if (tokenID.isEmpty) {
      failed('Please sign in again.');
      return;
    }
    final safeName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');

    log(
      'DocumentRepository uploadDocument: baseUrl=${Urls.baseUrl}, '
      'override=${Urls.documentUploadEndpointOverride.isEmpty ? "(none)" : "set"}, '
      'docFolderId=$docFolderId',
    );

    // If an explicit override is set, use the dedicated service and do not probe other URLs.
    final overrideEndpoint = Urls.documentUploadEndpointOverride.trim();
    if (overrideEndpoint.isNotEmpty) {
      try {
        final ok = await DocumentUploadService.UploadDocument(
          docFolderId: docFolderId,
          fileName: safeName,
          fileBytes: fileBytes,
          clientId: clientOrgId,
          financialYearId: financialYearId,
        );
        if (ok) {
          success();
        } else {
          failed('Upload failed at $overrideEndpoint.');
        }
      } catch (e) {
        failed(e.toString());
      }
      return;
    }

    try {
      final jsonUploadOk = await _tryUploadViaBase64Json(
        tokenID: tokenID,
        docFolderId: docFolderId,
        fileName: safeName,
        fileBytes: fileBytes,
        success: success,
        failed: failed,
      );
      if (jsonUploadOk) return;
    } catch (e) {
      log('DocumentRepository uploadDocument base64 JSON: $e');
    }

    try {
      final formUploadOk = await _tryUploadViaFormUrlEncoded(
        tokenID: tokenID,
        docFolderId: docFolderId,
        fileName: safeName,
        fileBytes: fileBytes,
        success: success,
        failed: failed,
      );
      if (formUploadOk) return;
    } catch (e) {
      log('DocumentRepository uploadDocument form-urlencoded: $e');
    }

    http.StreamedResponse? streamedResponse;
    String body = '';

    String? successfulUploadUrl;

    try {
    // Multipart: use backend override URL first if set, then built-in list (Document/Documents/File actions).
    final builtInUrls = [
      Urls.primaryDocumentUploadWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.saveDocumentWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.documentControllerWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.documentsUploadWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.documentsUploadFileWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.documentsUploadDocumentWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.documentsSaveDocumentWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.documentsAddDocumentWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.fileUploadWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.fileUploadFileWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.fileUploadPath,
      Urls.fileUploadFilePath,
      Urls.uploadDocumentWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.uploadWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.uploadFileWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.addDocumentWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.postDocumentWithQuery(tokenID: tokenID, docFolderID: docFolderId),
      Urls.uploadDocumentPath,
      Urls.uploadPath,
      Urls.uploadFilePath,
    ];
    final override = Urls.documentUploadEndpointOverride.trim();
    final urlsToTry = override.isEmpty
        ? builtInUrls
        : [
            override.contains('?')
                ? '$override&tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderId'
                : '$override?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderId',
            ...builtInUrls,
          ];

    const multipartFieldNames = ['file', 'File', 'document', 'upload'];
    for (final fieldName in multipartFieldNames) {
      for (var i = 0; i < urlsToTry.length; i++) {
        final urlString = urlsToTry[i];
        final uri = Uri.parse(urlString);
    final request = http.MultipartRequest('POST', uri);
        request.headers['Accept'] = '*/*';
        request.fields['tokenID'] = tokenID;
        request.fields['docFolderID'] = docFolderId.toString();
    request.files.add(http.MultipartFile.fromBytes(
          fieldName,
      fileBytes,
          filename: safeName,
          contentType: _mediaTypeFromFileName(safeName),
        ));

        log('DocumentRepository uploadDocument try: POST $urlString (field: $fieldName)');
        try {
          streamedResponse = await request.send();
          body = await _readResponseBodySafely(streamedResponse);
          log('DocumentRepository uploadDocument response: ${streamedResponse.statusCode}');
          final bodyLower = body.toLowerCase();
          final isActionOrRouteError = bodyLower.contains('no action was found') ||
              bodyLower.contains('no http resource') ||
              bodyLower.contains('no action was found on the controller');
          // Only treat 200/201 as success when body is not an error page (some servers return 200 with HTML error).
          if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
            if (!isActionOrRouteError) {
              successfulUploadUrl = urlString;
              break;
            }
            // 200 but body says "no action" -> not a real success, try next URL
            if (i < urlsToTry.length - 1 || fieldName != multipartFieldNames.last) {
              continue;
            }
            failed(
              'Upload endpoint not configured on server (HTTP ${streamedResponse.statusCode}) at $urlString.',
            );
            return;
          }
          if (isActionOrRouteError && (i < urlsToTry.length - 1 || fieldName != multipartFieldNames.last)) {
            continue;
          }
          if (streamedResponse.statusCode == 404 && (i < urlsToTry.length - 1 || fieldName != multipartFieldNames.last)) {
            continue;
          }
          final msg = isActionOrRouteError
              ? 'Upload endpoint not configured on server (HTTP ${streamedResponse.statusCode}) at $urlString.'
              : (body.trim().isNotEmpty
                  ? 'Upload failed (HTTP ${streamedResponse.statusCode}) at $urlString: ${_truncateBody(body)}'
                  : 'Upload failed (HTTP ${streamedResponse.statusCode}). $errorMessage');
          failed(msg);
        return;
        } catch (e) {
          log('DocumentRepository uploadDocument try error: $e');
          if (streamedResponse != null) {
            try {
              await streamedResponse.stream.drain();
            } catch (_) {}
          }
          if (i == urlsToTry.length - 1 && fieldName == multipartFieldNames.last) rethrow;
        }
      }
      if (successfulUploadUrl != null) break;
    }

    final response = streamedResponse;
    if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
      final bodyLower = body.toLowerCase();
      final isActionError = bodyLower.contains('no action was found') ||
          bodyLower.contains('no http resource') ||
          bodyLower.contains('no action was found on the controller');
      final status = response?.statusCode ?? 0;
      final msg = isActionError
          ? 'Upload endpoint not configured on server (HTTP $status).'
          : (body.trim().isNotEmpty
              ? 'Upload failed (HTTP $status): ${_truncateBody(body)}'
              : 'Upload failed (HTTP $status). $errorMessage');
      failed(msg);
      return;
    }

    try {
      final result = await handleResponse(http.Response(body, response.statusCode));
        if (result is Map && result['Success'] == 0) {
          failed(result['Message']?.toString() ?? errorMessage);
          return;
        }
      int? documentIdFromResponse;
      if (result is Map) {
        documentIdFromResponse = _parseDocumentIdFromUploadResponse(result);
      } else if (body.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map) documentIdFromResponse = _parseDocumentIdFromUploadResponse(decoded);
        } catch (_) {}
      }
      final usedFileController = successfulUploadUrl != null &&
          (successfulUploadUrl.contains('/File/') || successfulUploadUrl.contains('/file/'));
      if (documentIdFromResponse != null && usedFileController && documentIdFromResponse > 0) {
        moveDocument(
          documentId: documentIdFromResponse,
          targetFolderId: docFolderId,
          success: success,
          failed: failed,
        );
      } else {
      success();
      }
    } catch (e) {
      // handleResponse can throw (e.g. jsonDecode fails when server returns 200 with HTML error page)
      log('DocumentRepository uploadDocument parse response: $e');
      final bodyLower = body.toLowerCase();
      final isActionOrRouteError = bodyLower.contains('no action was found') ||
          bodyLower.contains('no http resource') ||
          bodyLower.contains('no action was found on the controller');
      if (isActionOrRouteError) {
        failed('Upload endpoint not configured on server (HTTP ${response.statusCode}).');
      } else {
        failed(
          body.trim().isNotEmpty
              ? 'Upload failed (HTTP ${response.statusCode}): ${_truncateBody(body)}'
              : 'Invalid server response (HTTP ${response.statusCode}). Please try again.',
        );
      }
    }
    } on Exception catch (e, st) {
      log('DocumentRepository uploadDocument: $e');
      log('$st');
      failed('Upload failed: ${e.toString().replaceAll(RegExp(r'^Exception:\s*'), '')}');
    } catch (e, st) {
      log('DocumentRepository uploadDocument: $e');
      log('$st');
      failed('Upload failed. Please check your connection and try again.');
    }
  }

 /* static const String _uploadEndpointNotConfiguredMessage =
      'Document upload is not available on this server. '
      'Please ask your administrator to enable the document upload action.';*/

  static String _truncateBody(String body, [int maxLen = 200]) {
    final trimmed = body.trim();
    if (trimmed.length <= maxLen) return trimmed;
    return '${trimmed.substring(0, maxLen)}…';
  }

  /// Returns MediaType for multipart upload from file extension (PDF, Word, images, etc.).
  static MediaType _mediaTypeFromFileName(String fileName) {
    final ext = fileName.split('.').lastOrNull?.toLowerCase() ?? '';
    switch (ext) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
      case 'ppt':
        return MediaType('application', 'vnd.ms-powerpoint');
      case 'pptx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.presentationml.presentation',
        );
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'webp':
        return MediaType('image', 'webp');
      case 'txt':
        return MediaType('text', 'plain');
      case 'csv':
        return MediaType('text', 'csv');
      case 'rtf':
        return MediaType('application', 'rtf');
      case 'odt':
        return MediaType('application', 'vnd.oasis.opendocument.text');
      case 'ods':
        return MediaType('application', 'vnd.oasis.opendocument.spreadsheet');
      case 'odp':
        return MediaType('application', 'vnd.oasis.opendocument.presentation');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Alternative upload: POST application/json with base64 file content. Returns true if upload succeeded.
  Future<bool> _tryUploadViaBase64Json({
    required String tokenID,
    required int docFolderId,
    required String fileName,
    required Uint8List fileBytes,
    required Function() success,
    required Function(String message) failed,
  }) async {
    final fileBase64 = base64Encode(fileBytes);
    final jsonBody = <String, dynamic>{
      'TokenID': tokenID,
      'DocFolderID': docFolderId,
      'FileName': fileName,
      'FileContent': fileBase64,
    };
    final override = Urls.documentUploadEndpointOverride.trim();
    final urls = override.isEmpty
        ? [
            Urls.uploadDocumentJsonPath,
            Urls.addDocumentJsonPath,
            Urls.documentsUploadDocumentPath,
            Urls.documentsAddDocumentPath,
          ]
        : [
            override,
            Urls.uploadDocumentJsonPath,
            Urls.addDocumentJsonPath,
            Urls.documentsUploadDocumentPath,
            Urls.documentsAddDocumentPath,
          ];
    for (final urlString in urls) {
      try {
        log('DocumentRepository uploadDocument (base64 JSON): POST $urlString');
        final response = await http.post(
          Uri.parse(urlString),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(jsonBody),
        );
        final bodyStr = response.body;
        log('DocumentRepository uploadDocument (base64 JSON) response: ${response.statusCode}');
        if (response.statusCode != 200 && response.statusCode != 201) {
          final bodyLower = bodyStr.toLowerCase();
          if (bodyLower.contains('no action') || bodyLower.contains('no http resource')) continue;
          failed(bodyStr.trim().isNotEmpty ? _truncateBody(bodyStr) : errorMessage);
          return false;
        }
        try {
          final result = await handleResponse(http.Response(bodyStr, response.statusCode));
          if (result is Map && result['Success'] == 0) {
            failed(result['Message']?.toString() ?? errorMessage);
            return false;
          }
          success();
          return true;
        } catch (_) {
          success();
          return true;
        }
      } catch (e) {
        log('DocumentRepository uploadDocument (base64 JSON) error: $e');
      }
    }
    return false;
  }

  /// Alternative upload: POST application/x-www-form-urlencoded with base64 file content.
  /// Some backends accept this when JSON or multipart fail. Returns true if upload succeeded.
  Future<bool> _tryUploadViaFormUrlEncoded({
    required String tokenID,
    required int docFolderId,
    required String fileName,
    required Uint8List fileBytes,
    required Function() success,
    required Function(String message) failed,
  }) async {
    final fileBase64 = base64Encode(fileBytes);
    final body = 'TokenID=${Uri.encodeComponent(tokenID)}&DocFolderID=$docFolderId'
        '&FileName=${Uri.encodeComponent(fileName)}&FileContent=${Uri.encodeComponent(fileBase64)}';
    final override = Urls.documentUploadEndpointOverride.trim();
    final urls = override.isEmpty
        ? [
            Urls.uploadDocumentJsonPath,
            Urls.addDocumentJsonPath,
            Urls.documentsUploadDocumentPath,
            Urls.documentsAddDocumentPath,
          ]
        : [
            override,
            Urls.uploadDocumentJsonPath,
            Urls.addDocumentJsonPath,
            Urls.documentsUploadDocumentPath,
            Urls.documentsAddDocumentPath,
          ];
    for (final urlString in urls) {
      try {
        log('DocumentRepository uploadDocument (form-urlencoded): POST $urlString');
        final response = await http.post(
          Uri.parse(urlString),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: body,
        );
        final bodyStr = response.body;
        log('DocumentRepository uploadDocument (form-urlencoded) response: ${response.statusCode}');
        if (response.statusCode != 200 && response.statusCode != 201) {
          final bodyLower = bodyStr.toLowerCase();
          if (bodyLower.contains('no action') || bodyLower.contains('no http resource')) continue;
          failed(bodyStr.trim().isNotEmpty ? _truncateBody(bodyStr) : errorMessage);
          return false;
        }
        try {
          final result = await handleResponse(http.Response(bodyStr, response.statusCode));
          if (result is Map && result['Success'] == 0) {
            failed(result['Message']?.toString() ?? errorMessage);
            return false;
          }
          success();
          return true;
        } catch (_) {
          success();
          return true;
        }
      } catch (e) {
        log('DocumentRepository uploadDocument (form-urlencoded) error: $e');
      }
    }
    return false;
  }

  /// Parses upload response for document ID (DocumentID, documentId, Id, id).
  static int? _parseDocumentIdFromUploadResponse(Map<dynamic, dynamic> map) {
    final keys = ['DocumentID', 'documentId', 'DocumentId', 'Id', 'id', 'DOCUMENT_ID'];
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      if (v is int && v > 0) return v;
      if (v is String) {
        final n = int.tryParse(v);
        if (n != null && n > 0) return n;
      }
    }
    return null;
  }

  Future<void> lockDocument({
    required int documentId,
    required Function() success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.lockDocument(tokenID: tokenID, id: documentId);
    final result = await getMethod(url: Uri.parse(url));
    try {
      if (result is Map && result['Success'] == 0) {
        failed(result['Message']?.toString() ?? errorMessage);
        return;
      }
      success();
    } catch (e) {
      log('DocumentRepository lockDocument: $e');
      failed(errorMessage);
    }
  }

  Future<void> unlockDocument({
    required int documentId,
    required Function() success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.unlockDocument(tokenID: tokenID, id: documentId);
    final result = await getMethod(url: Uri.parse(url));
    try {
      if (result is Map && result['Success'] == 0) {
        failed(result['Message']?.toString() ?? errorMessage);
        return;
      }
      success();
    } catch (e) {
      log('DocumentRepository unlockDocument: $e');
      failed(errorMessage);
    }
  }

  Future<void> unshareDocument({
    required int documentId,
    required Function() success,
    required Function(String message) failed,
  }) async {
    final pre = await SharedPreferences.getInstance();
    final tokenID = pre.getString(PreferenceHelper.userToken) ?? '';
    final url = Urls.unshareDocument(tokenID: tokenID, id: documentId);
    final result = await getMethod(url: Uri.parse(url));
    try {
      if (result is Map && result['Success'] == 0) {
        failed(result['Message']?.toString() ?? errorMessage);
        return;
      }
      success();
    } catch (e) {
      log('DocumentRepository unshareDocument: $e');
      failed(errorMessage);
    }
  }
}
