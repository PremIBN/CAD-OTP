import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/model/check_token_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:cadashboard/main.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepo extends ApiClient {

  static const String _fallbackMessage = 'Something went wrong';
  static const Duration _prefsAfterLoginTimeout = Duration(seconds: 12);

  static const List<String> _messageKeys = [
    'Message', 'message', 'msg', 'Msg', 'error', 'Error', 'errorMessage', 'ErrorMessage',
    'detail', 'Detail', 'details', 'reason', 'Reason', 'status_message', 'statusMessage', 'error_description',
  ];

  /// Extracts backend error message so we never show generic when backend sent a reason.
  static String _getMessage(dynamic r) {
    if (r is Map) {
      for (final key in _messageKeys) {
        final m = r[key];
        if (m != null) {
          final s = m.toString().trim();
          if (s.isEmpty || s == 'Something went wrong' || s == 'Something went Wrong') continue;
          if (s.startsWith('{') || s.startsWith('[')) {
            try {
              final decoded = jsonDecode(s);
              if (decoded is Map) {
                for (final k in _messageKeys) {
                  final n = decoded[k];
                  if (n != null) {
                    final t = n.toString().trim();
                    if (t.isNotEmpty) return t;
                  }
                }
              }
            } catch (_) {}
          }
          return s;
        }
      }
      log('Login: backend response keys=${r.keys.toList()}, no known message key. Full: $r');
    }
    return _fallbackMessage;
  }

  static bool _isSuccessMap(Map<String, dynamic> map) {
    final v = map['Success'] ?? map['success'];
    return v == 1 || v == true;
  }

  /// Returns a valid lat/lng string for API (non-empty, numeric; otherwise "0").
  static String _validCoord(String? value) {
    if (value == null) return '0';
    final t = value.trim();
    if (t.isEmpty) return '0';
    if (double.tryParse(t) != null) return t;
    return '0';
  }

  Future<void> authenticateUser({
    required String username,
    required String password,
    required String loginMode,
    required String deviceID,
    required String deviceName,
    required String ip,
    required String latitude,
    required String longitude,
    required Function(int success, String message, LoginModel response) successResponse,
    required Function(int success, String message) failedResponse,
  }) async {
    final lat = _validCoord(latitude);
    final lng = _validCoord(longitude);
    final params = <String, String>{
      'userName': username,
      'password': password,
      'loginMode': loginMode,
      'deviceID': deviceID,
      'deviceName': deviceName,
      'latlng': '$lat,$lng',
      'ip': ip,
    };

    final uri = Uri.parse(Urls.AuthenticateUser);
    var result;

    try {
      // Original behaviour: form-urlencoded body first.
      result = await withOutTokenPostMethod(
        url: uri,
        queryParam: null,
        header: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      // Fallback: send params as query string if body style is not accepted.
      if (result is! Map || !_isSuccessMap(Map<String, dynamic>.from(result))) {
        result = await withOutTokenPostMethod(url: uri, queryParam: params);
      }
    } catch (e, st) {
      log("Login API call exception :---> $e");
      log("Login stack :---> $st");
      try {
        result = await withOutTokenPostMethod(url: uri, queryParam: params);
      } catch (_) {
        final errMsg = e.toString().trim().isNotEmpty ? e.toString() : _fallbackMessage;
        failedResponse(0, errMsg);
        return;
      }
    }

    SharedPreferences preferences;
    try {
      preferences =
          await SharedPreferences.getInstance().timeout(_prefsAfterLoginTimeout);
    } on TimeoutException {
      failedResponse(0, 'Login timed out while saving session. Please try again.');
      return;
    }

        try {
          if (result is! Map<String, dynamic>) {
            failedResponse(0, _getMessage(result));
            return;
          }
          final map = Map<String, dynamic>.from(result);
          final serverMessage = _getMessage(map);
          if (serverMessage == _fallbackMessage) {
            log('Login: showing fallback; result Success=${map['Success']}, keys=${map.keys.toList()}');
          }

          if (!_isSuccessMap(map)) {
            failedResponse(0, serverMessage);
            return;
          }

          try {
            final model = LoginModel.fromJson(map);
            debugPrint("Device ID :-> ${model.deviceId}");
            try {
              preferences.setString(PreferenceHelper.userData, jsonEncode(map));
              final tokenId = map['TokenID'] ?? model.tokenId;
              if (tokenId != null) {
                final tokenStr = tokenId.toString();
                preferences.setString(PreferenceHelper.userToken, tokenStr);
                // Log login token so we can compare with menu API token.
                log('Login: stored TokenID for user=$username → $tokenStr');
                // Also print plainly so it shows in Cursor's run output.
                // You can copy this value into Postman.
                print('LOGIN TOKENID: $tokenStr');
              }
            } catch (_) {
              log("Login set preferences failed");
            }
            successResponse(1, 'User Authenticate Successfully', model);
          } catch (e) {
            log("Login parse success response :---> $e");
            failedResponse(0, serverMessage);
          }
        } catch (e) {
          log("Login Exception :---> $e");
          final msg = result is Map ? _getMessage(result) : _fallbackMessage;
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            showSnackBar(context: ctx, isError: true, message: msg);
          }
          failedResponse(0, msg);
        }
  }
}

