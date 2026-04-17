import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleService {
  static const supportedLanguageCodes = <String>[
    'en',
    'hi',
    'gu',
    'kn',
    'mr',
    'ta',
    'te',
  ];

  static Future<String?> loadLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(PreferenceHelper.appLocale);
    if (code == null || code.trim().isEmpty) return null;
    return code;
  }

  static Future<void> saveLanguageCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null || code.trim().isEmpty) {
      await prefs.remove(PreferenceHelper.appLocale);
      return;
    }
    await prefs.setString(PreferenceHelper.appLocale, code);
  }
}

