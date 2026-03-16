import 'dart:typed_data';

import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uploads a document to the override endpoint using the app's stored token.
/// Matches the app auth (tokenID) and backend contract (tokenID, docFolderID, multipart file).
/// Use when [Urls.documentUploadEndpointOverride] is set; otherwise [DocumentRepository.uploadDocument] tries multiple URLs.
class DocumentUploadService {
  /// Uploads [fileBytes] as [fileName] to the folder [docFolderId] using the override URL.
  /// Uses token from SharedPreferences (same as rest of app). Returns true on 200/201.
  /// [clientId] and [financialYearId] come from the current document filters so
  /// the upload goes to the same client/FY context as the list.
  static Future<bool> UploadDocument({
    required int docFolderId,
    required String fileName,
    required Uint8List fileBytes,
    required String clientId,
    String? financialYearId,
  }) async {
    final endpoint = Urls.documentUploadEndpointOverride.trim();
    if (endpoint.isEmpty) {
      throw StateError(
        'Document upload override URL is not set. Set Urls.documentUploadEndpointOverride in api_url.dart.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final tokenID = prefs.getString(PreferenceHelper.userToken) ?? '';
    if (tokenID.isEmpty) {
      throw StateError('Not signed in. Token missing.');
    }

    // Build query to match backend API:
    // http://www.cadashboard.com/web/api/Document/UploadFile
    //   ?tokenID=...&folderID=...&fileid=0&clientID=...&FinancialYearID=...
    final fyId = (financialYearId != null && financialYearId.isNotEmpty)
        ? financialYearId
        : (prefs.getString(PreferenceHelper.financialYearID) ?? '0');

    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'tokenID': tokenID,
        'folderID': docFolderId.toString(),
        'fileid': '0',
        'clientID': clientId,
        'FinancialYearID': fyId,
      },
    );

    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = '*/*';
    request.fields['tokenID'] = tokenID;
    request.fields['folderID'] = docFolderId.toString();
    request.fields['fileid'] = '0';
    request.fields['clientID'] = clientId;
    request.fields['FinancialYearID'] = fyId;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: _contentTypeFromFileName(fileName),
      ),
    );

    final response = await request.send();
    String body;
    try {
      body = await response.stream.bytesToString();
    } catch (_) {
      try {
        await response.stream.drain();
      } catch (_) {}
      body = '';
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    throw Exception(body.isNotEmpty ? body : 'Upload failed: ${response.statusCode}');
  }

  static MediaType _contentTypeFromFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    return MediaType('application', 'octet-stream');
  }
}
