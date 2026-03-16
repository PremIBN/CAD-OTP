import 'dart:io';

import 'package:cadashboard/core/View_Model/splash_screen_vm.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0,
      upperBound: 1,
      reverseDuration: const Duration(seconds: 1),
    );
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.addListener(() => setState(() {}));
    controller.forward();
  }

  Future<bool> notificationPermission() async {
    if(Platform.isAndroid){
      final permission = await Permission.notification.request();
      if (permission == PermissionStatus.denied) {
        final permission = await Permission.notification.request();
        if (permission == PermissionStatus.denied) {
          showSnackBar(context: context, message: 'Notification permissions are denied', isError: true);
          return false;
        }
      }
      if (permission == PermissionStatus.permanentlyDenied) {
        showSnackBar(context: context, message: 'Notification permissions are permanently denied, we cannot request permissions.', isError: true);
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StatelessBaseView(
      model: SplashScreenVM(),
      onInitState: (p0) {
        p0.checkToken(context);
      },
      builder: (buildContext, model, child) {
        return Scaffold(
            body: ScaleTransition(
              scale: scaleAnimation,
              child: Center(
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    child: Image.asset(AppImages.logo,color: AppColor.logoColor,)),
              ),
            )
        );
      },
    );
  }
}