import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/specific_client_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _apiIndicatesFailure(Map<String, dynamic> map) {
  if (!map.containsKey('Success') && !map.containsKey('success')) {
    return false;
  }
  final s = map['Success'] ?? map['success'];
  if (s is int) return s == 0;
  if (s is bool) return s == false;
  final t = s?.toString().trim().toLowerCase();
  return t == '0' || t == 'false';
}

String _messageFromApiMap(Map<String, dynamic> map, String fallback) {
  final m = map['Message'] ?? map['message'];
  final str = m?.toString().trim();
  if (str != null && str.isNotEmpty) return str;
  return fallback;
}

Map<String, dynamic> _payloadMapForOrganisation(Map<String, dynamic> map) {
  final data = map['Data'] ?? map['data'];
  if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
  if (data is Map) return Map<String, dynamic>.from(data);
  return map;
}

class SpecificClientRepo extends ApiClient{

  Future<void> specificClient({
    required String orgID,
    required Function(SpecificClientModel response) success,
    required Function(String message) failed,
  }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    final result = await getMethod(
      url: Uri.parse(Urls.SpecificClient),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
        'orgID' : orgID
      }
    );

    if (result is! Map) {
      appPrint('SpecificClient: non-map response for orgID=$orgID');
      failed(errorMessage);
      return;
    }
    final map = Map<String, dynamic>.from(result);
    if (_apiIndicatesFailure(map)) {
      failed(_messageFromApiMap(map, errorMessage));
      return;
    }

    final payload = _payloadMapForOrganisation(map);
    try {
      final clientModel = SpecificClientModel.fromJson(payload);
      success(clientModel);
    } catch (e, st) {
      appPrint('SpecificClient Exception : -----> $e\n$st');
      failed(
        'Unable to load this client for editing. Please try again, or contact support if the issue persists.',
      );
    }

  }

}