import 'package:cadashboard/core/services/fcm_token_sync.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class NotificationPermissionDialogService {
  NotificationPermissionDialogService._internal();

  static final NotificationPermissionDialogService instance =
      NotificationPermissionDialogService._internal();

  factory NotificationPermissionDialogService() => instance;

  static late OverlayEntry _overlayEntry;
  static bool _isVisible = false;

  static bool _osAllowsNotif(PermissionStatus s) => s.isGranted || s.isLimited;

  static Future<void> show(BuildContext context) async {
    if (_isVisible) return;

    final prefs = await SharedPreferences.getInstance();
    final userWantsNotif =
        prefs.getBool(PreferenceHelper.appNotificationsUserEnabled) ?? true;
    if (!userWantsNotif) return;

    final status = await Permission.notification.status;
    if (_osAllowsNotif(status)) {
      // No popup needed; keep FCM in sync.
      await registerFcmTokenAndRequestPlatformPermission();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Localizations.override(
        context: context,
        locale: const Locale('en'),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              ModalBarrier(
                color: Colors.black.withValues(alpha: 0.3),
                dismissible: false,
              ),
              Center(
                child: Material(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    height: 400,
                    width: 300,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(AppImages.closeAnimation),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                "Enable notifications to receive important updates and reminders.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CusBtn(
                                    btnName: "Allow",
                                    localizeText: false,
                                    onTap: () async {
                                      final result =
                                          await Permission.notification.request();
                                      if (result.isPermanentlyDenied ||
                                          result.isRestricted) {
                                        await openAppSettings();
                                      }
                                      if (_osAllowsNotif(result)) {
                                        final p =
                                            await SharedPreferences.getInstance();
                                        await p.setBool(
                                          PreferenceHelper.appNotificationsUserEnabled,
                                          true,
                                        );
                                        await registerFcmTokenAndRequestPlatformPermission();
                                      }
                                      hide();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CusBtn(
                                    btnName: "Cancel",
                                    localizeText: false,
                                    bGColor: Colors.grey.shade600,
                                    onTap: () {
                                      hide();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;
    overlayState.insert(_overlayEntry);
    _isVisible = true;
  }

  static void hide() {
    if (!_isVisible) return;
    _overlayEntry.remove();
    _isVisible = false;
  }
}

