// ignore_for_file: await_only_futures

import 'dart:async';
import 'dart:developer';
import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/home.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' show Platform;

import '../services/location_dialog_service.dart';

class LoginVM extends BaseModel {
  // TextEditingController usernameController = TextEditingController(text: "sugam.joshi"); //9049295966
  // TextEditingController usernameController = TextEditingController(text: "mahesh.kadam");
  // TextEditingController usernameController = TextEditingController(text: "inbsdemo");
  TextEditingController usernameController = TextEditingController();

  // TextEditingController passwordController = TextEditingController(text: "Sugam@93");
  // TextEditingController passwordController = TextEditingController(text: "Mahesh@123");
  // TextEditingController passwordController = TextEditingController(text: "Demo@123");
  TextEditingController passwordController = TextEditingController();

  TextEditingController forgotEmailController = TextEditingController();
  TextEditingController forgotUsernameController = TextEditingController();

  ValueNotifier<bool> visible = ValueNotifier(true);

  ValueNotifier<bool> buttonLoader = ValueNotifier(false);

  late LoginModel authenticateUserModel;

  DeviceInfoPlugin device = DeviceInfoPlugin();
  NetworkInfo network = NetworkInfo();

  static const Duration _loginBootstrapTimeout = Duration(seconds: 15);
  static const Duration _deviceInfoTimeout = Duration(seconds: 12);
  static const Duration _prefsTimeout = Duration(seconds: 12);
  static const Duration _notificationPermissionTimeout = Duration(seconds: 20);
  static const Duration _microphonePermissionTimeout = Duration(seconds: 20);

  /// Runs after Home is shown. Must not block navigation on login success (App Store review / slow devices).
  Future<void> _requestNotificationPermissionAfterLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_prefsTimeout);
      if (!(prefs.getBool(PreferenceHelper.appNotificationsUserEnabled) ?? true)) {
        return;
      }
      final status = await Permission.notification
          .request()
          .timeout(_notificationPermissionTimeout);

      if (status.isGranted) {
        try {
          await notification().timeout(_loginBootstrapTimeout);
        } catch (e, st) {
          log('LoginVM: notification bootstrap failed: $e');
          log('LoginVM: notification bootstrap stack: $st');
        }
      }
    } catch (e, st) {
      log('LoginVM: notification permission timeout or error: $e');
      log('LoginVM: notification permission stack: $st');
    }
  }

  /// Runs after Home is shown. Must not block navigation on login success.
  ///
  /// Requests microphone permission so iOS shows the Mic toggle in Settings and
  /// voice features can work without a "silent no-op" experience.
  ///
  /// On iOS, Speech Recognition permission is separate from microphone and is
  /// required for `speech_to_text` to function.
  Future<void> _requestMicrophoneAndSpeechPermissionAfterLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_prefsTimeout);
      if (!(prefs.getBool(PreferenceHelper.appMicrophoneUserEnabled) ?? true)) {
        return;
      }

      final micStatus = await Permission.microphone
          .request()
          .timeout(_microphonePermissionTimeout);
      if (!micStatus.isGranted) return;

      if (Platform.isIOS) {
        // Speech Recognition permission is distinct on iOS.
        await Permission.speech.request().timeout(_microphonePermissionTimeout);
      }
    } catch (e, st) {
      log('LoginVM: microphone/speech permission timeout or error: $e');
      log('LoginVM: microphone/speech permission stack: $st');
    }
  }

  Future<void> login(BuildContext context, String username, String password, String latitude, String longitude) async {
    SharedPreferences preferences;
    try {
      preferences = await SharedPreferences.getInstance().timeout(_prefsTimeout);
    } catch (e, st) {
      log('LoginVM: SharedPreferences failed: $e');
      log('LoginVM: SharedPreferences stack: $st');
      buttonLoader.value = false;
      if (context.mounted) {
        CommonFunction.showSnackBarLoginPageOnly(
          context: context,
          isError: true,
          message: 'Could not access device storage. Please try again.',
        );
      }
      return;
    }

    log(name: "Login Token", "${preferences.getString(PreferenceHelper.fcmToken)}");

    if (Platform.isAndroid) {
      String ipv4 = '0.0.0.0';
      try {
        ipv4 = await Ipify.ipv4().timeout(_loginBootstrapTimeout);
      } catch (e, st) {
        log('LoginVM: Ipify ipv4 failed (Android): $e');
        log('LoginVM: Ipify ipv4 stack (Android): $st');
      }

      String deviceName = 'Android';
      try {
        final android = await device.androidInfo.timeout(_deviceInfoTimeout);
        deviceName = android.model;
      } catch (e, st) {
        log('LoginVM: androidInfo failed: $e');
        log('LoginVM: androidInfo stack: $st');
      }

      // Persist context for later MarkAttendance calls
      await preferences.setString(PreferenceHelper.lastLoginDeviceID, preferences.getString(PreferenceHelper.fcmToken) ?? "");
      await preferences.setString(PreferenceHelper.lastLoginDeviceName, deviceName);
      await preferences.setString(PreferenceHelper.lastLoginLatitude, latitude);
      await preferences.setString(PreferenceHelper.lastLoginLongitude, longitude);
      await preferences.setString(PreferenceHelper.lastLoginIpAddress, ipv4);

      loginRepository.authenticateUser(
        username: username,
        password: password,
        loginMode: '2',
        deviceID: await preferences.getString(PreferenceHelper.fcmToken) ?? "",
        deviceName: deviceName,
        ip: ipv4,
        latitude: latitude,
        longitude: longitude,
        successResponse: (success, message, response) async {
          appPrint('------>Login : $message');
          buttonLoader.value = false;
          final access = await ApiClient().requestLocationPermission(
            token: response.tokenId.toString(),
            loginDetailID: response.loginDetailId.toString()
          );
          if (!access) {
            LocationDialogService.show(navigatorKey.currentContext!);
          } else {
            setPreferences(preferences, response);
            addLoggedInAreaAddressRepository.afterLoginApi(
              tokenID: "${response.tokenId}",
              address: "",
              loginDetailID: response.loginDetailId.toString(),
              latitude: latitude.toString(),
              longitude: longitude.toString(),
              isLogin: "1",
              successResponse: (success, message, response) async {
                debugPrint("AfterLoginApi LoginVM Success --> :: $success :: $message :: $response");
              },
              failedResponse: (success, message) {
                debugPrint("AfterLoginApi LoginVM Failed -> :: $success :: $message");
              },
            );
            // Pass the freshly issued tokenID into HomeScreen so it uses
            // this token for initial menu loading instead of any older stored token.
            Navigator.pushAndRemoveUntil(
              context,
              cusNavigate(HomeScreen(tokenId: response.tokenId)),
              (route) => false,
            );
            unawaited(_requestNotificationPermissionAfterLogin());
          }
        },
        failedResponse: (success, message) {
          appPrint('------>Login Error : $message');
          buttonLoader.value = false;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: true,
            message: message,
          );
        },
      );
    } else if (Platform.isIOS) {
      String deviceName = 'iOS';
      try {
        final ios = await device.iosInfo.timeout(_deviceInfoTimeout);
        deviceName = ios.model;
      } catch (e, st) {
        log('LoginVM: iosInfo failed: $e');
        log('LoginVM: iosInfo stack: $st');
      }

      String ipv4 = '0.0.0.0';
      try {
        ipv4 = await Ipify.ipv4().timeout(_loginBootstrapTimeout);
      } catch (e, st) {
        log('LoginVM: Ipify ipv4 failed (iOS): $e');
        log('LoginVM: Ipify ipv4 stack (iOS): $st');
      }
      try {
        // Persist context for later MarkAttendance calls
        await preferences.setString(PreferenceHelper.lastLoginDeviceID, preferences.getString(PreferenceHelper.fcmToken) ?? "");
        await preferences.setString(PreferenceHelper.lastLoginDeviceName, deviceName);
        await preferences.setString(PreferenceHelper.lastLoginLatitude, latitude);
        await preferences.setString(PreferenceHelper.lastLoginLongitude, longitude);
        await preferences.setString(PreferenceHelper.lastLoginIpAddress, ipv4);

        loginRepository.authenticateUser(
        username: username,
        password: password,
        loginMode: '2',
        deviceID: await preferences.getString(PreferenceHelper.fcmToken) ?? "",
        deviceName: deviceName,
        ip: ipv4,
        latitude: latitude,
        longitude: longitude,
        successResponse: (success, message, response) async {
          appPrint('------>Login : $message');
          buttonLoader.value = false;
          // iOS requirement: after successful login, always go to Home.
          // Do not block on location validation or open settings dialogs here.
          setPreferences(preferences, response);
          addLoggedInAreaAddressRepository.afterLoginApi(
            tokenID: "${response.tokenId}",
            address: "",
            loginDetailID: response.loginDetailId.toString(),
            latitude: latitude,
            longitude: longitude,
            isLogin: "1",
            successResponse: (success, message, response) async {
              debugPrint("AfterLoginApi LoginVM Success --> :: $success :: $message :: $response");
            },
            failedResponse: (success, message) {
              debugPrint("AfterLoginApi LoginVM Failed -> :: $success :: $message");
            },
          );
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            cusNavigate(HomeScreen(tokenId: response.tokenId)),
            (route) => false,
          );
          // Notifications/FCM after navigation so login never appears stuck (Guideline 2.1).
          unawaited(_requestNotificationPermissionAfterLogin());
        },
        failedResponse: (success, message) {
          appPrint('------>Login Error : $message');
          buttonLoader.value = false;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: true,
            message: message,
          );
        },
      );
      } catch (e, st) {
        log('LoginVM: iOS login failed: $e');
        log('LoginVM: iOS login stack: $st');
        buttonLoader.value = false;
        if (context.mounted) {
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: true,
            message: 'Login could not complete. Please try again.',
          );
        }
      }
    }
  }

  void setPreferences(SharedPreferences preferences, LoginModel response) async {
    await preferences.setString(PreferenceHelper.userToken, response.tokenId!);
    await preferences.setString(PreferenceHelper.loginDetailID, response.loginDetailId.toString());
    await preferences.setString(PreferenceHelper.userName, response.userName!);
    await preferences.setString(PreferenceHelper.userEmail, response.email!);
    await preferences.setString(PreferenceHelper.fullName, '${response.firstName} ${response.lastName}');
    await preferences.setString(PreferenceHelper.financialYearID, response.financialYearId.toString());
    await preferences.setString(PreferenceHelper.currency, response.currencyId.toString());
    await preferences.setInt(PreferenceHelper.showOtherTaskDetails, response.showtaskotherdetails ?? 0);
    await preferences.setInt(PreferenceHelper.mandateNumber, response.isMandateNoCompulsory ?? 0);
    if(response.isBackDatedActualEffortsRestricted == 1){
      await preferences.setInt(PreferenceHelper.restrictTillDays, response.restrictTillDays ?? 0);
    } else {
      await preferences.remove(PreferenceHelper.restrictTillDays);
    }
  }

  ValueNotifier<bool> loading = ValueNotifier(false);

  Future<void> forgot(BuildContext context, String username, String email) async {
    forgotRepo.forgot(
      email: email,
      username: username,
      success: (message, code) {
        if (code == 204) {
          CommonFunction.showSnackBar(
            context: context,
            isError: true,
            message: message,
          );
          loading.value = false;
        } else {
          CommonFunction.showSnackBar(
            context: context,
            isError: false,
            message: message,
          );
          Navigator.pop(context);
          loading.value = false;
        }
      },
      failed: (message) {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: message,
        );
        loading.value = false;
      },
    );
  }
}
