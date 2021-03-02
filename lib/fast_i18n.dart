library fast_i18n;

import 'dart:io';
import 'dart:ui';

import 'package:fast_i18n/utils.dart';

class FastI18n {
  static const _localePartsDelimiter = '-';

  /// Returns the locale string used by the device.
  static String getDeviceLocale() => Platform.localeName;

  /// Returns the candidate (or part of it) if it is supported.
  /// Fallbacks to base locale.
  static String selectLocale(String candidate, List<String> supported, String baseLocale) {
    // normalize
    candidate = Utils.normalize(candidate);

    // 1st try: match exactly
    String selected = supported.firstWhere((element) => element == candidate, orElse: () => null);
    if (selected != null) return selected;

    // 2nd try: match the first part (language)
    List<String> deviceLocaleParts = candidate.split(_localePartsDelimiter);
    selected =
        supported.firstWhere((element) => element == deviceLocaleParts.first, orElse: () => null);
    if (selected != null) return selected;

    // 3rd try: match the second part (region)
    selected =
        supported.firstWhere((element) => element == deviceLocaleParts.last, orElse: () => null);
    if (selected != null) return selected;

    // fallback: default locale
    return baseLocale;
  }

  /// Converts the passed locales from [String] to [Locale].
  /// Puts the [baseLocale] into the the beginning of the list.
  static List<Locale> convertToLocales(List<String> locales, String baseLocale) {
    final rawSupportedLocales = [
      baseLocale,
      ...locales.where((locale) => locale != baseLocale),
    ];

    final supportedLocales = rawSupportedLocales.map((rawLocale) {
      if (rawLocale.contains(_localePartsDelimiter)) {
        final localeParts =
            rawLocale.split(_localePartsDelimiter).where((part) => part.isNotEmpty).toList();
        if (localeParts.length == 2) {
          return Locale.fromSubtags(languageCode: localeParts[0], countryCode: localeParts[1]);
        } else if (localeParts.length == 3) {
          return Locale.fromSubtags(
            languageCode: localeParts[0],
            scriptCode: localeParts[1],
            countryCode: localeParts[2],
          );
        } else {
          throw Exception(
              "The locale '$rawLocale' is not in a supported format. Examples of the supported formats: 'en', 'en-US', 'zh-Hans-CN'.");
        }
      } else {
        return Locale.fromSubtags(languageCode: rawLocale);
      }
    }).toList();

    return supportedLocales;
  }
}
