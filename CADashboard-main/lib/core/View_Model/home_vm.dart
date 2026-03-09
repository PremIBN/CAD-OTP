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
import 'package:cadashboard/core/repository/menu_repository.dart';

class HomeVM extends BaseModel {
  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<int> notification = ValueNotifier(0);

  final MenuRepository _menuRepository = MenuRepository();

  /// Latest session tokenID to use for menu and token checks.
  /// When coming from a fresh login, this is set from the login response
  /// so we never accidentally use an older stored token.
  String? _sessionTokenId;

  void setSessionToken(String? tokenId) {
    final t = tokenId?.trim();
    if (t == null || t.isEmpty || t.toLowerCase() == 'null') {
      _sessionTokenId = null;
    } else {
      _sessionTokenId = t;
    }
  }

  /// Menus returned by menu API (CreateMenuSubMenu). Only these are shown; no hardcoded list.
  List<MenuItem> menuItems = [];

  late String userName;
  late String userEmail;

  Future<void> checkToken(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // Prefer the in-memory session token from latest login; fall back to stored one.
    final storedToken = preferences.getString(PreferenceHelper.userToken) ?? '';
    final tokenId = _sessionTokenId ?? storedToken;
    appPrint('-----> Token : $tokenId');
    tokenRepo.checkToken(
      token: tokenId,
      successResponse: (success, message, response) async {
        try {
          preferences.setBool(PreferenceHelper.isSignIn, true);
          userName = preferences.getString(PreferenceHelper.fullName) ?? '';
          userEmail = preferences.getString(PreferenceHelper.userEmail) ?? '';
          appPrint('Token : $message');

          // Wait for menu API (same tokenID); do not render home until response is received.
          try {
            menuItems = await _menuRepository.fetchMenu(tokenId: tokenId);
          } catch (e, st) {
            appPrint('Fetch menu failed: $e $st');
            menuItems = [];
          }

          viewLoader.value = ViewState.success;
          notifyListeners();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) getNotification(context);
          });
        } catch (e, st) {
          appPrint('Token success callback error: $e $st');
          menuItems = [];
          viewLoader.value = ViewState.success;
        }
      },
      failedResponse: (success, message, statusCode) {
        appPrint('Token : $message');
        if (context.mounted) {
          CommonFunction.showSnackBar(
              context: context,
              isError: true,
              message: 'Your Session has been Expired');
          Navigator.pushAndRemoveUntil(
              context, cusNavigate(const LoginScreen()), (route) => false);
        }
        viewLoader.value = ViewState.failed;
      },
    );
  }

  /// Pull-to-refresh: reloads token and user data, returns a Future that completes when done.
  Future<void> refresh(BuildContext context) async {
    final completer = Completer<void>();
    final preferences = await SharedPreferences.getInstance();
    final storedToken = preferences.getString(PreferenceHelper.userToken) ?? '';
    final tokenId = _sessionTokenId ?? storedToken;
    tokenRepo.checkToken(
      token: tokenId,
      successResponse: (success, message, response) async {
        try {
          preferences.setBool(PreferenceHelper.isSignIn, true);
          userName = preferences.getString(PreferenceHelper.fullName) ?? '';
          userEmail = preferences.getString(PreferenceHelper.userEmail) ?? '';
          try {
            menuItems = await _menuRepository.fetchMenu(tokenId: tokenId);
          } catch (e, st) {
            appPrint('Fetch menu failed: $e $st');
            menuItems = [];
          }
          notifyListeners();
          viewLoader.value = ViewState.success;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) getNotification(context);
          });
        } catch (e, st) {
          appPrint('Token success callback error: $e $st');
          menuItems = [];
          viewLoader.value = ViewState.success;
        }
        if (!completer.isCompleted) completer.complete();
      },
      failedResponse: (success, message, statusCode) {
        appPrint('Token : $message');
        if (context.mounted) {
          CommonFunction.showSnackBar(
              context: context,
              isError: true,
              message: 'Your Session has been Expired');
          Navigator.pushAndRemoveUntil(
              context, cusNavigate(const LoginScreen()), (route) => false);
        }
        viewLoader.value = ViewState.failed;
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  Future<void> getNotification(BuildContext context) async {
    notificationRepo.getNotification(
      success: (response) {
        notification.value = response.length;
        notifyListeners();
      },
      failed: (message) {
        if (context.mounted) {
          CommonFunction.showSnackBar(
              context: context, isError: true, message: message);
        }
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
          ).then((_) {
            // Proceed with logout even if location API failed, so user can always log out
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
          });
        } else {
          CommonFunction.showSnackBar(context: context, isError: true, message: "Location not found");
        }
      },
    );
  }
}