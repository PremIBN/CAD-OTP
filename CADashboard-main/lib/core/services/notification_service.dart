import 'dart:convert';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/splash_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {

  // Instance of FlutterNotification plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    // Initialization  setting for android
      const InitializationSettings initializationSettingsAndroid = InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"));

      _notificationsPlugin.initialize(

        initializationSettingsAndroid,

        // to handle event when we receive notification
        onDidReceiveNotificationResponse: (details) {
          // ignore: unnecessary_null_comparison
          if(details != null){
            appPrint(' Notification Payload ---> ${details.payload}');
            // appPrint('Notification Not NUll');
            Navigator.push(context, cusNavigate(const SplashScreen()));
          }else{
            appPrint('Notification is NULL');
          }
        },
      );
  }

  static Future<void> display(RemoteMessage message) async {
    // To display the notification in device

    appPrint(' Notification Payload ---> ${message.data}');

    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          message.notification!.android!.channelId ?? 'FadFocus id', //"Channel Id"
          message.notification!.android!.imageUrl ?? "FadFocus", //Main Channel
          playSound: true,
          sound: UriAndroidNotificationSound(message.notification!.android!.sound ?? 'default'),
          color: AppColor.background,
          importance: Importance.max,
          icon: "@mipmap/ic_launcher",
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          channelShowBadge: true,
        ),
      );

      await _notificationsPlugin.show(
          int.parse(id.toString()),
          message.notification?.title,
          message.notification?.body,
          notificationDetails,
          payload: json.encode(message.data),
      );

      appPrint(' Notification Type ---> ${message.messageType}');

    } catch (e) {
      debugPrint('Error : ${e.toString()}');
    }
  }
}
