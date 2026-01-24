import 'dart:developer';
import 'dart:io' show Platform;
import 'core/common/app_version_service.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/ui/screen/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cadashboard/core/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions, PermissionStatusGetters;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestNotificationPermission();
  preferences = await SharedPreferences.getInstance();
  await AppVersionService.init();
  appCrashlytics();
  runApp(const MyApp());
}

late double width;
late double height;
late SharedPreferences preferences;
appPrint(Object? msg) => debugPrint(msg.toString());
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
ValueNotifier<bool> isLocationPermissionEnabled = ValueNotifier(false);

Future getFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? tokenValue = preferences.getString(PreferenceHelper.fcmToken);
  try {
    String? token = await messaging.getToken();
    appPrint("FCM Token: $token");
    appPrint("SharedPreferences: $tokenValue");
  } catch (e) {
    appPrint("Error retrieving FCM token: $e");
  }
}

notification() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String fcmToken = await firebaseMessaging.getToken() ?? "";
  log(name: "FCM Token", "${preferences.getString(PreferenceHelper.fcmToken)}");
  appPrint("FCM Token : ${preferences.getString(PreferenceHelper.fcmToken)}");
  await preferences.setString(PreferenceHelper.fcmToken, fcmToken);

  log(name: "preferences FCM Token", "${preferences.getString(PreferenceHelper.fcmToken)}");
  appPrint("preferences FCM Token : ${preferences.getString(PreferenceHelper.fcmToken)}");

  firebaseMessaging.requestPermission(alert: true, sound: true, badge: true);

  firebaseMessaging.setForegroundNotificationPresentationOptions(badge: true, sound: true, alert: true);
}

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await Permission.notification.status;

    if (androidInfo.isDenied || androidInfo.isPermanentlyDenied) {
      final result = await Permission.notification.request();

      if (result.isGranted) {
        await notification();
        appPrint("Notification permission granted on Android!");
      } else {
        appPrint("Notification permission denied on Android.");
      }
    } else {
      await notification();
      appPrint("Notification permission already granted on Android.");
    }
  } else if (Platform.isIOS) {
    final iosInfo = await Permission.notification.status;

    if (iosInfo.isDenied || iosInfo.isPermanentlyDenied) {
      final result = await Permission.notification.request();

      if (result.isGranted) {
        await notification();
        appPrint("Notification permission granted on iOS!");
      } else {
        appPrint("Notification permission denied on iOS.");
      }
    } else {
      await notification();
      appPrint("Notification permission already granted on iOS.");
    }
  }
}

appCrashlytics() {
  const fatalError = true;
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        LocalNotificationService.display(message);
        appPrint(":Message-----=== $message");
      } else {
        appPrint(":---------------> Notification NULL");
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    LocalNotificationService.initialize(context);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'CADashboard',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: AppColor.background),
          centerTitle: true,
          color: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: AppColor.background,
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),
          elevation: 10,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black.withValues(alpha: (0.2)),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.background,
          primary: AppColor.background,
        ),
        fontFamily: 'Exo2',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
