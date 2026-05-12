import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/model/client/std_code_model.dart';
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
    if (v == true) return true;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == '1' || s == 'true';
    }
    return false;
  }

  /// Strips BOM / outer whitespace from API string fields (avoids silent AuthenticateUser failures).
  static String _cleanApiString(String? s) {
    if (s == null) return '';
    var t = s.trim();
    if (t.startsWith('\ufeff')) t = t.substring(1).trim();
    return t;
  }

  /// Web/API may nest credentials under `RegisterUser`/`Data`.
  static Map<String, dynamic> _mapForCredentials(Map<String, dynamic> map) {
    for (final k in ['RegisterUser', 'registerUser', 'Data', 'data']) {
      final v = map[k];
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    return map;
  }

  /// Returns a valid lat/lng string for API (non-empty, numeric; otherwise "0").
  static String _validCoord(String? value) {
    if (value == null) return '0';
    final t = value.trim();
    if (t.isEmpty) return '0';
    if (double.tryParse(t) != null) return t;
    return '0';
  }

  /// CADashboard `AuthenticateUser`: POST with fields in **query string** only.
  Future<dynamic> _postAuthenticateUserOnce({
    required String username,
    required String password,
    required String loginMode,
    required bool trimPassword,
    required String deviceID,
    required String deviceName,
    required String ip,
    required String latitude,
    required String longitude,
    bool pascalCaseKeys = false,
  }) async {
    final lat = _validCoord(latitude);
    final lng = _validCoord(longitude);
    final pwd = trimPassword ? password.trim() : password;
    final params = pascalCaseKeys
        ? <String, String>{
            'UserName': username.trim(),
            'Password': pwd,
            'LoginMode': loginMode,
            'DeviceID': deviceID,
            'DeviceName': deviceName,
            'latlng': '$lat,$lng',
            'ip': ip,
          }
        : <String, String>{
            'userName': username.trim(),
            'password': pwd,
            'loginMode': loginMode,
            'deviceID': deviceID,
            'deviceName': deviceName,
            'latlng': '$lat,$lng',
            'ip': ip,
          };

    final uri = Uri.parse(Urls.AuthenticateUser);
    try {
      return await withOutTokenPostMethod(url: uri, queryParam: params);
    } catch (e, st) {
      log("Login API call exception :---> $e");
      log("Login stack :---> $st");
      try {
        return await withOutTokenPostMethod(url: uri, queryParam: params);
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> _handleAuthenticateUserResult({
    required dynamic result,
    required String usernameForLog,
    required Function(int success, String message, LoginModel response) successResponse,
    required Function(int success, String message) failedResponse,
  }) async {
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
            log('Login: stored TokenID for user=$usernameForLog → $tokenStr');
            print('LOGIN TOKENID: $tokenStr');
          }
        } catch (_) {
          log("Login set preferences failed");
        }
        // Caller may choose to show a message; avoid always showing a success toast.
        successResponse(1, '', model);
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
    /// When false, password is sent exactly as returned (e.g. OTP JSON). Manual login uses trim.
    bool trimPasswordForAuthenticate = true,
  }) async {
    dynamic result;
    try {
      result = await _postAuthenticateUserOnce(
        username: username,
        password: password,
        loginMode: loginMode,
        trimPassword: trimPasswordForAuthenticate,
        deviceID: deviceID,
        deviceName: deviceName,
        ip: ip,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      final errMsg = e.toString().trim().isNotEmpty ? e.toString() : _fallbackMessage;
      failedResponse(0, errMsg);
      return;
    }

    await _handleAuthenticateUserResult(
      result: result,
      usernameForLog: username,
      successResponse: successResponse,
      failedResponse: failedResponse,
    );
  }

  /// After `ValidateOTPAndLogin` succeeds, the server may return credentials that only match
  /// `AuthenticateUser` with a different **login id** (email vs username) or **loginMode** (web vs app).
  /// Tries a small ordered set of combinations before failing.
  Future<void> authenticateUserAfterOtp({
    required Map<String, dynamic> otpResponseJson,
    required String userName,
    required String password,
    required String deviceID,
    required String deviceName,
    required String ip,
    required String latitude,
    required String longitude,
    required Function(int success, String message, LoginModel response) successResponse,
    required Function(int success, String message) failedResponse,
  }) async {
    final cred = _mapForCredentials(otpResponseJson);
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = cred[k] ?? otpResponseJson[k];
        final s = _cleanApiString(v?.toString());
        if (s.isNotEmpty && s != 'null') return s;
      }
      return '';
    }

    final primaryUser = _cleanApiString(userName);
    var pass = password.startsWith('\ufeff') ? password.substring(1) : password;
    final email = pick(['EmailId', 'emailId', 'Email', 'email']);
    final mobile = pick(['Mobile', 'mobile', 'ContactNo', 'contactNo']);

    final rawAttempts =
        <({
          String username,
          String password,
          String loginMode,
          bool trimPassword,
          bool pascalCaseKeys,
        })>[
      (
        username: primaryUser,
        password: pass,
        loginMode: '2',
        trimPassword: false,
        pascalCaseKeys: false,
      ),
      (
        username: primaryUser,
        password: pass,
        loginMode: '2',
        trimPassword: true,
        pascalCaseKeys: false,
      ),
      (
        username: primaryUser,
        password: pass,
        loginMode: '0',
        trimPassword: false,
        pascalCaseKeys: false,
      ),
      (
        username: primaryUser,
        password: pass,
        loginMode: '1',
        trimPassword: false,
        pascalCaseKeys: false,
      ),
      (
        username: primaryUser,
        password: pass,
        loginMode: '2',
        trimPassword: false,
        pascalCaseKeys: true,
      ),
    ];

    bool distinctUser(String u) =>
        u.isNotEmpty &&
        u.toLowerCase() != primaryUser.toLowerCase();

    if (distinctUser(email)) {
      rawAttempts.insert(
        1,
        (
          username: email,
          password: pass,
          loginMode: '2',
          trimPassword: false,
          pascalCaseKeys: false,
        ),
      );
      rawAttempts.add((
        username: email,
        password: pass,
        loginMode: '0',
        trimPassword: false,
        pascalCaseKeys: false,
      ));
    }
    if (distinctUser(mobile)) {
      rawAttempts.add((
        username: mobile,
        password: pass,
        loginMode: '2',
        trimPassword: false,
        pascalCaseKeys: false,
      ));
    }

    final seen = <String>{};
    var lastFailureMessage = _fallbackMessage;
    const maxAttempts = 12;

    for (final a in rawAttempts) {
      if (a.username.isEmpty || a.password.isEmpty) continue;
      final key =
          '${a.username}|${a.password}|${a.loginMode}|${a.trimPassword}|${a.pascalCaseKeys}';
      if (!seen.add(key)) continue;
      log(
        'AuthenticateUser (post-OTP attempt): '
        'userLen=${a.username.length} loginMode=${a.loginMode} trimPwd=${a.trimPassword} '
        'pascal=${a.pascalCaseKeys}',
      );

      dynamic result;
      try {
        result = await _postAuthenticateUserOnce(
          username: a.username,
          password: a.password,
          loginMode: a.loginMode,
          trimPassword: a.trimPassword,
          deviceID: deviceID,
          deviceName: deviceName,
          ip: ip,
          latitude: latitude,
          longitude: longitude,
          pascalCaseKeys: a.pascalCaseKeys,
        );
      } catch (e) {
        lastFailureMessage = e.toString().trim().isNotEmpty ? e.toString() : _fallbackMessage;
        continue;
      }

      if (result is Map) {
        final map = Map<String, dynamic>.from(result);
        if (_isSuccessMap(map)) {
          await _handleAuthenticateUserResult(
            result: map,
            usernameForLog: a.username,
            successResponse: successResponse,
            failedResponse: failedResponse,
          );
          return;
        }
        lastFailureMessage = _getMessage(map);
      }

      if (seen.length >= maxAttempts) break;
    }

    failedResponse(0, lastFailureMessage);
  }

  /// Calls **`ComboBoxController.GetAllCountry()`** (`Urls.comboBoxControllerGetAllCountry`) — no login token needed.
  ///
  /// Matches web `FillCountrySTDCode()` — only rows with non-empty `STDCode` are returned
  /// (`if (field.STDCode != null && field.STDCode != '')`).
  /// Used on the OTP login screen for country / STD picker.
  Future<void> getAllCountryForLogin({
    required Function(List<StdCodeModel> list) success,
    required Function(String message) failed,
  }) async {
    final uri = Uri.parse(Urls.GetAllCountry);
    dynamic result;
    try {
      result = await withOutTokenGetMethod(url: uri);
    } catch (e) {
      failed(e.toString());
      return;
    }

    try {
      final list = <StdCodeModel>[];
      void addMapsFromList(List<dynamic> raw) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            list.add(StdCodeModel.fromJson(item));
          } else if (item is Map) {
            list.add(StdCodeModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      if (result is List) {
        addMapsFromList(result);
      } else if (result is Map) {
        final map = Map<String, dynamic>.from(result);
        for (final key in ['CountryList', 'countryList', 'Data', 'data', 'List', 'list', 'masterCodesObj']) {
          final v = map[key];
          if (v is List) {
            addMapsFromList(v);
            break;
          }
          if (v is Map && v['Country'] is List) {
            addMapsFromList(v['Country'] as List);
            break;
          }
        }
        if (list.isEmpty) {
          for (final v in map.values) {
            if (v is List && v.isNotEmpty && v.first is Map) {
              addMapsFromList(v);
              break;
            }
          }
        }
      }

      bool hasStdLikeWeb(final StdCodeModel e) {
        final raw = e.stdCode?.trim() ?? '';
        return raw.isNotEmpty;
      }

      final valid = list.where(hasStdLikeWeb).toList()
        ..sort((a, b) => (a.codeName ?? '').toLowerCase().compareTo((b.codeName ?? '').toLowerCase()));
      if (valid.isEmpty) {
        failed('No countries loaded.');
        return;
      }
      success(valid);
    } catch (e) {
      log('getAllCountryForLogin parse error: $e');
      failed('Could not load country list.');
    }
  }

  /// Sends OTP via backend. Expects `GenerateLoginOTP(string mobile, string countrySTDCode)`.
  /// [mobile] = local number digits only (e.g. Indian 10 digits). [countrySTDCode] = dialing code digits (e.g. 91).
  Future<void> generateLoginOtp({
    required String mobile,
    required String countrySTDCode,
    required Function(String message) success,
    required Function(String message) failed,
  }) async {
    final uri = Uri.parse(Urls.GenerateLoginOTP);
    dynamic result;
    try {
      result = await withOutTokenGetMethod(
        url: uri,
        queryParam: {'mobile': mobile, 'countrySTDCode': countrySTDCode},
      );
    } catch (e) {
      failed(e.toString());
      return;
    }

    // Backend might return: Map {Success, Message}, or plain int/string codes.
    if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      final ok = _isSuccessMap(map);
      final msg = _getMessage(map);
      if (ok) {
        success(msg.isNotEmpty ? msg : 'OTP sent.');
      } else {
        failed(msg.isNotEmpty ? msg : 'Failed to send OTP.');
      }
      return;
    }

    final raw = result?.toString().trim() ?? '';
    final code = int.tryParse(raw);
    // Web meaning:
    //  >0 : success
    //  -1 : mobile registered with multiple accounts
    //  -2 : mobile not registered with any account
    if (code != null) {
      if (code > 0) {
        success('OTP sent.');
      } else {
        if (code == -1) {
          failed('Mobile number is registered with multiple accounts. Please contact CADASHBOARD support.');
        } else if (code == -2) {
          failed('Mobile number is not registered with any account. Please contact CADASHBOARD support.');
        } else {
          failed('Failed to send OTP. ($code)');
        }
      }
      return;
    }

    // Fallback: treat any non-empty response as success.
    if (raw.isNotEmpty && raw != 'null') {
      success('OTP sent.');
    } else {
      failed('Failed to send OTP.');
    }
  }

  /// Verifies OTP via backend and returns the login credentials.
  ///
  /// Sends **both** prefixed and flat keys so ASP.NET model binding works whether
  /// the action uses `RegisterUser registerUserObj` or the same shape as web jQuery
  /// (`ContactNo` + `OTP` only).
  /// Returns object containing UserName + Password on success, otherwise empty.
  Future<void> validateOtpAndLogin({
    required String contactNo,
    required String otp,
    required FutureOr<void> Function(
      String userName,
      String password,
      Map<String, dynamic> otpResponseJson,
    ) success,
    required Function(String message) failed,
  }) async {
    final uri = Uri.parse(Urls.ValidateOTPAndLogin);
    final c = contactNo.trim();
    final o = otp.trim();
    dynamic result;
    try {
      result = await withOutTokenPostUrlEncoded(
        url: uri,
        fields: {
          'registerUserObj.ContactNo': c,
          'registerUserObj.OTP': o,
          'ContactNo': c,
          'OTP': o,
        },
      );
    } catch (e) {
      failed(e.toString());
      return;
    }

    // Console / DevTools: full ValidateOTPAndLogin response (remove when done debugging).
    try {
      final line = result is Map
          ? jsonEncode(Map<String, dynamic>.from(result))
          : result?.toString() ?? 'null';
      log('ValidateOTPAndLogin POST $uri → $line');
      debugPrint('ValidateOTPAndLogin response: $line');
    } catch (_) {}

    if (result is! Map) {
      failed('Invalid OTP');
      return;
    }

    final map = Map<String, dynamic>.from(result);
    final cred = _mapForCredentials(map);
    final userRaw = (cred['UserName'] ?? cred['userName'] ?? map['UserName'] ?? map['userName'])?.toString();
    final passRaw = (cred['Password'] ?? cred['password'] ?? map['Password'] ?? map['password'])?.toString();
    final user = _cleanApiString(userRaw);
    // Do not trim password: some backends return secrets with meaningful spacing/encoding.
    var pass = passRaw == null ? '' : passRaw.toString();
    if (pass.startsWith('\ufeff')) pass = pass.substring(1);
    if (user.isEmpty || user == 'null' || pass.isEmpty || pass == 'null') {
      final msg = _getMessage(map);
      // API often returns 200 + empty RegisterUser with no Message → _getMessage is generic.
      if (msg == _fallbackMessage) {
        failed(
          'Invalid OTP',
        );
      } else {
        failed(msg.isNotEmpty ? msg : 'Invalid OTP');
      }
      return;
    }
    log('OTP validated: calling AuthenticateUser next (userLen=${user.length}, passwordLen=${pass.length}).');
    await success(user, pass, map);
  }
}

