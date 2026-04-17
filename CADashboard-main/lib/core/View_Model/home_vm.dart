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
import 'package:cadashboard/core/repository/attendance_repository.dart';
import 'package:cadashboard/core/model/attendance/attendance_history_row.dart';

class HomeVM extends BaseModel {
  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<int> notification = ValueNotifier(0);

  final MenuRepository _menuRepository = MenuRepository();
  final AttendanceRepository attendanceRepo = AttendanceRepository();

  // Attendance state (for Attendance card on Home)
  ValueNotifier<bool> attendanceLoading = ValueNotifier(false);
  ValueNotifier<bool> attendanceSignedIn = ValueNotifier(false);
  ValueNotifier<DateTime?> attendanceSignInAt = ValueNotifier(null);
  ValueNotifier<DateTime?> attendanceSignOutAt = ValueNotifier(null);
  ValueNotifier<List<AttendanceHistoryRow>> attendanceHistory =
      ValueNotifier<List<AttendanceHistoryRow>>([]);

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
            if (context.mounted) loadTodayAttendance(context);
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
          CommonFunction.showSnackBarAuthEnglishOnly(
            context: context,
            isError: true,
            message: 'Your Session has been Expired',
          );
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
            if (context.mounted) loadTodayAttendance(context);
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
          CommonFunction.showSnackBarAuthEnglishOnly(
            context: context,
            isError: true,
            message: 'Your Session has been Expired',
          );
          Navigator.pushAndRemoveUntil(
              context, cusNavigate(const LoginScreen()), (route) => false);
        }
        viewLoader.value = ViewState.failed;
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  Future<void> loadTodayAttendance(BuildContext context) async {
    if (attendanceLoading.value) return;
    attendanceLoading.value = true;
    try {
      final today = await attendanceRepo.getTodayAttendance();
      attendanceSignedIn.value = today.isSignedIn;
      attendanceSignInAt.value = today.signInAt;
      attendanceSignOutAt.value = today.signOutAt;
    } catch (e) {
      // Best effort; don't block home if attendance fails
    } finally {
      attendanceLoading.value = false;
    }
  }

  Future<void> attendanceSignIn(BuildContext context) async {
    if (attendanceLoading.value) return;
    attendanceLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenId = prefs.getString(PreferenceHelper.userToken) ?? '';
      final loginDetailId = prefs.getString(PreferenceHelper.loginDetailID) ?? '';
      final res = await attendanceRepo.signIn(tokenId: tokenId, loginDetailId: loginDetailId);
      attendanceSignedIn.value = res.isSignedIn;
      attendanceSignInAt.value = res.signInAt;
      attendanceSignOutAt.value = res.signOutAt;
      if (context.mounted) {
        CommonFunction.showSnackBar(
          context: context,
          isError: false,
          message: 'You Have Successfully Sign In',
        );
      }
    } catch (e) {
      await _syncAttendanceStateSilently();
      if (context.mounted) {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      attendanceLoading.value = false;
    }
  }

  Future<void> attendanceSignOut(BuildContext context) async {
    if (attendanceLoading.value) return;
    attendanceLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenId = prefs.getString(PreferenceHelper.userToken) ?? '';
      final loginDetailId = prefs.getString(PreferenceHelper.loginDetailID) ?? '';
      final res = await attendanceRepo.signOut(tokenId: tokenId, loginDetailId: loginDetailId);
      attendanceSignedIn.value = res.isSignedIn;
      attendanceSignInAt.value = res.signInAt;
      attendanceSignOutAt.value = res.signOutAt;
      if (context.mounted) {
        CommonFunction.showSnackBar(
          context: context,
          isError: false,
          message: 'You Have Successfully Sign Out',
        );
      }
    } catch (e) {
      await _syncAttendanceStateSilently();
      if (context.mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: msg,
        );
      }
    } finally {
      attendanceLoading.value = false;
    }
  }

  Future<void> _syncAttendanceStateSilently() async {
    try {
      final today = await attendanceRepo.getTodayAttendance();
      attendanceSignedIn.value = today.isSignedIn;
      attendanceSignInAt.value = today.signInAt;
      attendanceSignOutAt.value = today.signOutAt;
    } catch (_) {
      // Best effort sync; ignore failures in catch path.
    }
  }

  bool _isAttendanceAlreadyMarkedMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('attendance is marked') ||
        m.contains('attendance already marked') ||
        m.contains('already marked');
  }

  Future<void> loadAttendanceHistory(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenId = prefs.getString(PreferenceHelper.userToken) ?? '';
      final rows =
          await attendanceRepo.getTodaysAttendanceHistory(tokenId: tokenId, date: date);
      attendanceHistory.value = rows;
    } catch (_) {
      attendanceHistory.value = [];
    }
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
                  // Logout success message must always be English.
                  CommonFunction.showSnackBar(
                    context: context,
                    isError: false,
                    message: message,
                    localizeMessage: false,
                  );
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