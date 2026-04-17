import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import '../utils/colors.dart';
// ignore: depend_on_referenced_packages, library_prefixes
import 'package:html/parser.dart' as htmlParser;

class CommonFunction {
  static Widget errorTextWidget(String title) {
    return Center(
      child: Text(
        ApiTextLocalizer.localize(title),
        style: const TextStyle(
          color: AppColor.background,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  static String decodeHTML(String htmlText) {
    return htmlParser.parse(htmlText).toString();
  }

  static void showSnackBar({
    required BuildContext context,
    required bool isError,
    required String message,
    bool localizeMessage = true,
  }) {
    if (!context.mounted) return;
    final msg = localizeMessage
        ? ApiTextLocalizer.localize(message, locale: Localizations.localeOf(context))
        : message;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red : AppColor.logoColor,
      content: Text(
        msg,
        style: const TextStyle(color: Colors.white),
      )),
    );
  }

  /// Use only on [LoginScreen] / sign-in flow: never transliterates or translates text.
  static void showSnackBarLoginPageOnly({
    required BuildContext context,
    required bool isError,
    required String message,
  }) {
    showSnackBar(
      context: context,
      isError: isError,
      message: message,
      localizeMessage: false,
    );
  }

  /// Authentication/snackbar messages that must always remain English regardless of selected app language.
  static void showSnackBarAuthEnglishOnly({
    required BuildContext context,
    required bool isError,
    required String message,
  }) {
    showSnackBar(
      context: context,
      isError: isError,
      message: message,
      localizeMessage: false,
    );
  }

  static alertDialog({required BuildContext context, required String title, required String subTitle, VoidCallback? onYes, VoidCallback? onNo}) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final locale = Localizations.localeOf(context);
        return AlertDialog(
          title: Text(ApiTextLocalizer.localize(title, locale: locale)),
          content: Text(ApiTextLocalizer.localize(subTitle, locale: locale), style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColor.background.withValues(alpha: (0.1))),
              ),
              onPressed: onYes,
              child: Text(ApiTextLocalizer.localize('Yes', locale: locale)),
            ),
            TextButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColor.background),
              ),
              onPressed: onNo,
              child: Text(ApiTextLocalizer.localize('No', locale: locale), style: const TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  static String dateTimeDecode(String input) {
    RegExp datePattern = RegExp(r'\d{2}-[A-Za-z]{3}-\d{2}');
    Match? match = datePattern.firstMatch(input);

    if (match != null) {
      String date = match.group(0)!;
      return date;
    } else {
      return "-";
    }
  }

  static String removeNumberAndSymbol(String input) {
    RegExp pattern = RegExp(r'[0-9_]+');
    return input.replaceAll(pattern, '');
  }

  static String extractTextBeforeDate(String input) {
    RegExp datePattern = RegExp(r'\d{2}-[A-Za-z]{3}-\d{2} \d{2}:\d{2} [APap][Mm]');
    RegExpMatch? dateMatch = datePattern.firstMatch(input);

    if (dateMatch != null) {
      int endIndex = dateMatch.end;
      return input.substring(0, endIndex);
    } else {
      return "-";
    }
  }

}