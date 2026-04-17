import 'dart:developer';

import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers FCM token and requests iOS presentation options. No-op if the user
/// turned notifications off in App settings.
Future<void> registerFcmTokenAndRequestPlatformPermission() async {
  final preferences = await SharedPreferences.getInstance();
  if (!(preferences.getBool(PreferenceHelper.appNotificationsUserEnabled) ?? true)) {
    return;
  }

  final firebaseMessaging = FirebaseMessaging.instance;

  final fcmToken = await firebaseMessaging.getToken() ?? '';
  log(name: 'FCM Token', '${preferences.getString(PreferenceHelper.fcmToken)}');

  await preferences.setString(PreferenceHelper.fcmToken, fcmToken);

  await firebaseMessaging.requestPermission(alert: true, sound: true, badge: true);

  await firebaseMessaging.setForegroundNotificationPresentationOptions(
    badge: true,
    sound: true,
    alert: true,
  );
}
