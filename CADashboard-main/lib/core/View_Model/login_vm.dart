// ignore_for_file: await_only_futures

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

  Future<void> login(BuildContext context, String username, String password, String latitude, String longitude) async {

    await notification();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    log(name: "Login Token", "${preferences.getString(PreferenceHelper.fcmToken)}");

    if (Platform.isAndroid) {

      String ipv4 = await Ipify.ipv4();

      AndroidDeviceInfo android = await device.androidInfo;

      loginRepository.authenticateUser(
        username: username,
        password: password,
        loginMode: '2',
        deviceID: await preferences.getString(PreferenceHelper.fcmToken) ?? "",
        deviceName: android.model,
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
            Navigator.pushAndRemoveUntil(context, cusNavigate(const HomeScreen()), (route) => false);
          }
        },
        failedResponse: (success, message) {
          appPrint('------>Login Error : $message');
          buttonLoader.value = false;
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
        },
      );
    } else if (Platform.isIOS) {
      IosDeviceInfo ios = await device.iosInfo;

      String ipv4 = await Ipify.ipv4();
      loginRepository.authenticateUser(
        username: username,
        password: password,
        loginMode: '2',
        deviceID: await preferences.getString(PreferenceHelper.fcmToken) ?? "",
        deviceName: ios.model,
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
            Navigator.pushAndRemoveUntil(context, cusNavigate(const HomeScreen()), (route) => false);
          }
        },
        failedResponse: (success, message) {
          appPrint('------>Login Error : $message');
          buttonLoader.value = false;
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
        },
      );
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
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          loading.value = false;
        } else {
          CommonFunction.showSnackBar(context: context, isError: false, message: message);
          Navigator.pop(context);
          loading.value = false;
        }
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        loading.value = false;
      },
    );
  }
}
