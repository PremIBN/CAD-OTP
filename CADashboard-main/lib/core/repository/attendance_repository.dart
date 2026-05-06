import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/attendance/today_attendance_model.dart';
import '../model/attendance/attendance_history_row.dart';

class AttendanceRepository {
  final ApiClient _apiClient = ApiClient();

  Future<TodayAttendance> getTodayAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cachedDayKey = prefs.getString(PreferenceHelper.attendanceCacheDate);
    if (cachedDayKey != todayKey) {
      // New day: clear local attendance cache so card starts from "--".
      await prefs.remove(PreferenceHelper.attendanceSignInTime);
      await prefs.remove(PreferenceHelper.attendanceSignOutTime);
      await prefs.setBool(PreferenceHelper.attendanceIsSignedIn, false);
      await prefs.setString(PreferenceHelper.attendanceCacheDate, todayKey);
    }

    final remote = await _fetchRemoteAttendanceState(prefs);
    bool? signedInFromRemote;
    if (remote?.signedIn != null) {
      signedInFromRemote = remote!.signedIn!;
      await prefs.setBool(PreferenceHelper.attendanceIsSignedIn, signedInFromRemote);
    }
    DateTime? inAt;
    DateTime? outAt;
    if (remote != null) {
      inAt = remote.signInAt;
      outAt = remote.signOutAt;
      if (inAt != null) {
        await prefs.setString(
          PreferenceHelper.attendanceSignInTime,
          inAt.toIso8601String(),
        );
      } else {
        await prefs.remove(PreferenceHelper.attendanceSignInTime);
      }
      if (outAt != null) {
        await prefs.setString(
          PreferenceHelper.attendanceSignOutTime,
          outAt.toIso8601String(),
        );
      } else {
        await prefs.remove(PreferenceHelper.attendanceSignOutTime);
      }
    }

    inAt ??= DateTime.tryParse(
      prefs.getString(PreferenceHelper.attendanceSignInTime) ?? '',
    );
    outAt ??= DateTime.tryParse(
      prefs.getString(PreferenceHelper.attendanceSignOutTime) ?? '',
    );
    // Button state should come from GetAttendanceDetails (LastActivity) whenever available.
    // Only fall back to cached state when remote data is unavailable.
    final signedIn =
        signedInFromRemote ??
        (prefs.getBool(PreferenceHelper.attendanceIsSignedIn) ?? false);
    return TodayAttendance(isSignedIn: signedIn, signInAt: inAt, signOutAt: outAt);
  }

  Future<_RemoteAttendanceState?> _fetchRemoteAttendanceState(
    SharedPreferences prefs,
  ) async {
    final tokenId = (prefs.getString(PreferenceHelper.userToken) ?? '').trim();
    if (tokenId.isEmpty || tokenId.toLowerCase() == 'null') return null;

    String userId = '';
    final userDataRaw = prefs.getString(PreferenceHelper.userData);
    if (userDataRaw != null && userDataRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(userDataRaw);
        if (decoded is Map<String, dynamic>) {
          userId = (decoded['UserID'] ?? '').toString();
        }
      } catch (_) {
        // Ignore parse issues and continue with empty userID.
      }
    }

    final result = await _apiClient.getMethod(
      url: Uri.parse(Urls.GetAttendanceDetails),
      queryParam: {
        'tokenID': tokenId,
        'userID': userId,
      },
      skipLocationCheck: true,
    );

    return _extractRemoteAttendance(result);
  }

  Future<List<AttendanceHistoryRow>> getTodaysAttendanceHistory({
    required String tokenId,
    required DateTime date,
  }) async {
    final dateStr = DateFormat('dd MMM yyyy').format(date);

    final result = await _apiClient.getMethod(
      url: Uri.parse(Urls.GetTodaysAttendanceHistory),
      queryParam: {
        'tokenID': tokenId,
        'AttendanceDate': dateStr,
      },
      skipLocationCheck: true,
    );

    dynamic rowsJson;

    // Endpoint may return a bare table (List) or a wrapped Map.
    if (result is List) {
      rowsJson = result;
    } else if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      // Most common backend shape for this endpoint:
      // { columns: [...], data: [[...],[...]] }
      rowsJson = map['data'] ??
          map['Data'] ??
          map['Table'] ??
          map['table'] ??
          map['Result'] ??
          map['result'];

      if (rowsJson is Map && rowsJson['Table'] is List) {
        rowsJson = rowsJson['Table'];
      }
    }

    if (rowsJson is! List) return [];

    final list = <AttendanceHistoryRow>[];
    for (var i = 0; i < rowsJson.length; i++) {
      final row = rowsJson[i];
      if (row is Map<String, dynamic>) {
        list.add(AttendanceHistoryRow.fromJson(row, i));
      } else if (row is Map) {
        list.add(AttendanceHistoryRow.fromJson(Map<String, dynamic>.from(row), i));
      } else if (row is List) {
        list.add(AttendanceHistoryRow.fromList(row, i));
      }
    }
    return list;
  }

  _RemoteAttendanceState? _extractRemoteAttendance(dynamic response) {
    if (response is! Map) return null;
    final map = Map<String, dynamic>.from(response);

    int? readInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    DateTime? readDate(Map<String, dynamic> source, List<String> keys) {
      for (final key in keys) {
        final value = source[key];
        final parsed = _parseAnyDate(value);
        if (parsed != null) return parsed;
      }
      return null;
    }

    int? lastActivity = readInt(map['LastActivity'] ?? map['lastActivity']);
    DateTime? signInAt = readDate(map, const [
      'SignInTime',
      'SignInAt',
      'FirstSignIn',
      'FirstSignInTime',
      'LoginTime',
      'InTime',
    ]);
    DateTime? signOutAt = readDate(map, const [
      'SignOutTime',
      'SignOutAt',
      'LastSignOut',
      'LastSignOutTime',
      'LogoutTime',
      'OutTime',
    ]);

    dynamic container = map['Data'] ?? map['data'] ?? map['Result'] ?? map['result'] ?? map['Table'] ?? map['table'];
    if (container is List && container.isNotEmpty) {
      container = container.first;
    }
    if (container is Map) {
      final nested = Map<String, dynamic>.from(container);
      lastActivity ??= readInt(nested['LastActivity'] ?? nested['lastActivity']);
      signInAt ??= readDate(nested, const [
        'SignInTime',
        'SignInAt',
        'FirstSignIn',
        'FirstSignInTime',
        'LoginTime',
        'InTime',
      ]);
      signOutAt ??= readDate(nested, const [
        'SignOutTime',
        'SignOutAt',
        'LastSignOut',
        'LastSignOutTime',
        'LogoutTime',
        'OutTime',
      ]);
    }

    if (lastActivity == null && signInAt == null && signOutAt == null) return null;
    return _RemoteAttendanceState(
      // LastActivity = 0 => Sign In button, LastActivity = 1 => Sign Out button
      signedIn: lastActivity == null ? null : lastActivity == 1,
      signInAt: signInAt,
      signOutAt: signOutAt,
    );
  }

  DateTime? _parseAnyDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty || raw == '-') return null;

    final direct = DateTime.tryParse(raw);
    if (direct != null) return direct;

    // Backend often sends attendance times as "hh:mm a" (e.g. "01:18 PM").
    // Convert that time to today's date for card display.
    try {
      final timeOnly = DateFormat('hh:mm a').parseStrict(raw);
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        timeOnly.hour,
        timeOnly.minute,
      );
    } catch (_) {
      // Ignore and continue other parsing styles.
    }

    final msMatch = RegExp(r'\/Date\((\d+)\)\/').firstMatch(raw);
    if (msMatch != null) {
      final ms = int.tryParse(msMatch.group(1) ?? '');
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }

  Future<TodayAttendance> signIn({
    required String tokenId,
    required String loginDetailId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _readUserId(prefs);
    if (userId.trim().isEmpty) {
      throw Exception('User ID not found. Please logout and login again.');
    }
    final pos = await Geolocator.getCurrentPosition();

    String ip = '0.0.0.0';
    try {
      ip = await Ipify.ipv4();
    } catch (_) {}

    final deviceId = (prefs.getString(PreferenceHelper.fcmToken) ?? '').trim();
    final deviceName = Platform.isIOS ? 'iOS' : 'Android';

    final params = <String, dynamic>{
      'tokenID': tokenId,
      'userID': userId,
      // Contract: Sign In => type = 1
      'type': '1',
      'IpAddress': ip,
      'deviceID': deviceId,
      'deviceName': deviceName,
      'loginMode': '2',
      'latitude': pos.latitude.toString(),
      'longitude': pos.longitude.toString(),
    };
    final result = await _apiClient.getMethod(
      url: Uri.parse(Urls.MarkAttendance),
      queryParam: params,
      skipLocationCheck: true,
    );

    final ok = _isSuccess(result);
    final refreshed = await _getTodayAttendanceWithRetry(
      expectedSignedIn: true,
    );
    if (!ok) {
      throw Exception(_messageFrom(result) ?? 'Sign in failed');
    }
    return refreshed;
  }

  Future<TodayAttendance> signOut({
    required String tokenId,
    required String loginDetailId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _readUserId(prefs);
    if (userId.trim().isEmpty) {
      throw Exception('User ID not found. Please logout and login again.');
    }
    final pos = await Geolocator.getCurrentPosition();

    String ip = '0.0.0.0';
    try {
      ip = await Ipify.ipv4();
    } catch (_) {}

    final deviceId = (prefs.getString(PreferenceHelper.fcmToken) ?? '').trim();
    final deviceName = Platform.isIOS ? 'iOS' : 'Android';

    final params = <String, dynamic>{
      'tokenID': tokenId,
      'userID': userId,
      // Contract: Sign Out => type = 0
      'type': '0',
      'IpAddress': ip,
      'deviceID': deviceId,
      'deviceName': deviceName,
      'loginMode': '2',
      'latitude': pos.latitude.toString(),
      'longitude': pos.longitude.toString(),
    };
    final result = await _apiClient.getMethod(
      url: Uri.parse(Urls.MarkAttendance),
      queryParam: params,
      skipLocationCheck: true,
    );

    final ok = _isSuccess(result);
    final refreshed = await _getTodayAttendanceWithRetry(
      expectedSignedIn: false,
    );
    if (!ok) {
      throw Exception(_messageFrom(result) ?? 'Sign out failed');
    }
    return refreshed;
  }

  Future<TodayAttendance> _getTodayAttendanceWithRetry({
    required bool expectedSignedIn,
  }) async {
    // Immediate fetch + short retry backoff for eventual backend consistency.
    const delaysMs = <int>[0, 300, 600, 900];
    late TodayAttendance latest;
    for (final d in delaysMs) {
      if (d > 0) {
        await Future.delayed(Duration(milliseconds: d));
      }
      latest = await getTodayAttendance();
      if (latest.isSignedIn == expectedSignedIn) {
        return latest;
      }
    }
    return latest;
  }

  String _readUserId(SharedPreferences prefs) {
    final userDataRaw = prefs.getString(PreferenceHelper.userData);
    if (userDataRaw != null && userDataRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(userDataRaw);
        if (decoded is Map<String, dynamic>) {
          final candidates = [
            decoded['UserID'],
            decoded['userID'],
            decoded['UserId'],
            decoded['userId'],
          ];
          for (final v in candidates) {
            final s = (v ?? '').toString().trim();
            if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
          }
        }
      } catch (_) {}
    }
    return '';
  }

  bool _isSuccess(dynamic response) {
    Map<String, dynamic>? asMap(dynamic input) {
      if (input is Map) return Map<String, dynamic>.from(input);
      if (input is String) {
        final raw = input.trim();
        if (raw.startsWith('{') && raw.endsWith('}')) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is Map) return Map<String, dynamic>.from(decoded);
          } catch (_) {
            // ignore malformed json string
          }
        }
      }
      return null;
    }

    final map = asMap(response);
    if (map != null) {
      final raw = map['Success'] ?? map['success'];
      if (raw is bool) return raw;
      final s = (raw ?? '').toString().trim().toLowerCase();
      if (s == 'true') return true;
      return int.tryParse(s) == 1;
    }
    return false;
  }

  String? _messageFrom(dynamic response) {
    if (response is String) {
      final s = response.trim();
      if (s.isEmpty) return null;
      if (s.startsWith('{') && s.endsWith('}')) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is Map) {
            final map = Map<String, dynamic>.from(decoded);
            final msg = (map['Message'] ?? map['message'])?.toString().trim();
            return (msg == null || msg.isEmpty) ? null : msg;
          }
        } catch (_) {
          // Keep original string if not valid json
        }
      }
      return s;
    }
    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final msg = (map['Message'] ?? map['message'])?.toString().trim();
      return (msg == null || msg.isEmpty) ? null : msg;
    }
    return null;
  }
}

class _RemoteAttendanceState {
  final bool? signedIn;
  final DateTime? signInAt;
  final DateTime? signOutAt;

  const _RemoteAttendanceState({
    required this.signedIn,
    required this.signInAt,
    required this.signOutAt,
  });
}

