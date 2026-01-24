// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cadashboard/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';

class HomeVM extends BaseModel {
  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<int> notification = ValueNotifier(0);

  late String userName;
  late String userEmail;

  Future<void> checkToken(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    appPrint('-----> Token : ${preferences.getString(PreferenceHelper.userToken)}');
    tokenRepo.checkToken(
      token: preferences.getString(PreferenceHelper.userToken) ?? "",
      successResponse: (success, message, response) {
        preferences.setBool(PreferenceHelper.isSignIn, true);
        userName = preferences.getString(PreferenceHelper.fullName)!;
        userEmail = preferences.getString(PreferenceHelper.userEmail)!;
        notifyListeners();
        appPrint('Token : $message');
        getNotification(context);
        // getAllTask(context);
      },
      failedResponse: (success, message, statusCode) {
        appPrint('Token : $message');
        CommonFunction.showSnackBar(
            context: context,
            isError: true,
            message: 'Your Session has been Expired');
        Navigator.pushAndRemoveUntil(
            context, cusNavigate(const LoginScreen()), (route) => false);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getNotification(BuildContext context) async {
    notificationRepo.getNotification(
      success: (response) {
        notification.value = response.length;
        notifyListeners();
        viewLoader.value = ViewState.success;
      },
      failed: (message) {
        CommonFunction.showSnackBar(
            context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  dialog(
    BuildContext context,
    String title,
    String subTitle, {String? latitude, String? longitude}) {
    CommonFunction.alertDialog(
      context: context,
      title: title,
      subTitle: subTitle,
      onNo: () {
        Navigator.pop(context);
      },
      onYes: () async {
        if (latitude != null && longitude != null) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          addLoggedInAreaAddressRepository.afterLoginApi(
            tokenID: "${preferences.getString(PreferenceHelper.userToken)}",
            address: "",
            loginDetailID: "${preferences.getString(PreferenceHelper.loginDetailID)}",
            latitude: latitude,
            longitude: longitude,
            isLogin: "2",
            successResponse: (success, message, response) {
              debugPrint("AfterLogoutApi Home VM Success --> :: $success :: $message :: $response");
            },
            failedResponse: (success, message) {
              debugPrint("AfterLogoutApi Home VM Failed -> :: $success :: $message");
            },
          ).then((value) {
            if (value == true) {
              logoutRepo.logoutUser(
                perform: title,
                latitude: latitude,
                longitude: longitude,
                response: (message) async {
                  SharedPreferences preferences = await SharedPreferences.getInstance();
                  if (message == '$title Successfully') {
                    CommonFunction.showSnackBar(context: context, isError: false, message: message);
                    preferences.setString(PreferenceHelper.userToken, 'null');
                    preferences.setBool(PreferenceHelper.isSignIn, false);
                    preferences.clear();
                    Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
                  } else {
                    Navigator.pop(context);
                    CommonFunction.showSnackBar(context: context, isError: true, message: message);
                  }
                },
              );
            }
          });
        } else {
          CommonFunction.showSnackBar(context: context, isError: true, message: "Location not found");
        }
      },
    );
  }
}