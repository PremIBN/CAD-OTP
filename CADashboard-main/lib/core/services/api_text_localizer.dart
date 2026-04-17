import 'package:cadashboard/core/services/app_locale_controller.dart';
import 'package:cadashboard/core/services/transliteration_service.dart';
import 'package:flutter/widgets.dart';

class ApiTextLocalizer {
  static final Map<String, String> _cache = <String, String>{};

  static String localize(String text, {Locale? locale}) {
    final lang = (locale ?? AppLocaleController.locale.value)?.languageCode ?? 'en';
    if (lang == 'en' || text.isEmpty) return text;
    final key = '$lang|$text';
    final cached = _cache[key];
    if (cached != null) return cached;
    final out = TransliterationService.transliterate(text, lang);
    _cache[key] = out;
    return out;
  }

  static void clearCache() => _cache.clear();
}

