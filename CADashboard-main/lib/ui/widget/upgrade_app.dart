import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class UpgradeApp extends StatelessWidget {
  final Widget child;

  const UpgradeApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: child,
    );
  }
}

