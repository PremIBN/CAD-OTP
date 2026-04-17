import 'package:cadashboard/core/services/app_locale_service.dart';
import 'package:flutter/widgets.dart';

class AppLocaleController {
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static const Locale _englishLocale = Locale('en');

  static Future<void> init() async {
    final code = await AppLocaleService.loadLanguageCode();
    if (code == null) return;
    locale.value = Locale(code);
  }

  /// Sets [locale] synchronously first so dependent widgets rebuild immediately,
  /// then persists to preferences (no app restart required).
  static Future<void> setLanguageCode(String? code) async {
    final trimmed = code?.trim();
    final next =
        (trimmed == null || trimmed.isEmpty) ? null : Locale(trimmed);
    locale.value = next;
    await AppLocaleService.saveLanguageCode(trimmed);
  }

  /// Preferred input locales for keyboard/spell hints:
  /// selected app language first, then English fallback.
  static List<Locale> inputHintLocales(BuildContext context) {
    final selected = locale.value ?? Localizations.localeOf(context);
    final lang = selected.languageCode.trim().toLowerCase();
    final isSupported = AppLocaleService.supportedLanguageCodes.contains(lang);
    final primary = isSupported ? Locale(lang) : _englishLocale;
    if (primary.languageCode == _englishLocale.languageCode) {
      return const [_englishLocale];
    }
    return [primary, _englishLocale];
  }
}

