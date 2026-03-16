import 'package:flutter/material.dart';

class Utils {

  // Email Check
  static bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(em);
  }

  static const EdgeInsets cardPadding = EdgeInsets.all(10.0);
  static final BorderRadius cardRadius = BorderRadius.circular(8);

  static bool isPassword(String password) {

    String p = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#%&*])[A-Za-z0-9!@#%&*]";
    RegExp regExp = RegExp(p);

    return regExp.hasMatch(password);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

showSnackBar({required BuildContext context, required bool isError, required String message}) {
  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
    SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: isError ? Colors.red : Colors.green),
      ),
      content: Text(message,textAlign: TextAlign.start, style: const TextStyle(color: Colors.white)),
    ),
  );
}