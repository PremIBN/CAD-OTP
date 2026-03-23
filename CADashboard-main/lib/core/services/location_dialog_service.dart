import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';

class LocationDialogService {

  /// Private constructor
  LocationDialogService._internal();

  /// Create the single instance (static final instance)
  static final LocationDialogService instance = LocationDialogService._internal();

  /// [factory] constructors don't always create a new instance of the class (factory returns the instance)
  factory LocationDialogService() => instance;


  static late OverlayEntry _overlayEntry;
  static bool _isVisible = false;

  static void show(BuildContext context) {
    if (_isVisible) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withValues(alpha: 0.3),
            dismissible: false,
          ),
          Center(
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: SizedBox(
                height: 400,
                width: 300,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(AppImages.closeAnimation),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text(
                            "Login not allowed. You’re currently outside the allowed location. Please move closer to your assigned zone to proceed.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        CusBtn(
                          btnName: "Close",
                          onTap: () {
                            hide();
                            final nav = navigatorKey.currentState;
                            final ctx = navigatorKey.currentContext;
                            if (nav != null && ctx != null && ctx.mounted) {
                              nav.pushAndRemoveUntil(
                                cusNavigate(const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Overlay.of(context, rootOverlay: true).insert(_overlayEntry);
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      appPrint("Overlay is not available");
      return;
    }
    overlayState.insert(_overlayEntry);
    _isVisible = true;
  }

  static void hide() {
    if (!_isVisible) return;
    _overlayEntry.remove();
    _isVisible = false;
  }
}
