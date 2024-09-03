import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Handles localization for the CountrySelector, providing translated strings
/// based on the current locale.
class CountrySelectorLocalizations {
  /// Creates a localization instance for the given locale.
  CountrySelectorLocalizations(this.locale);

  /// The locale for which this localization instance is created.
  final Locale locale;

  /// Stores the localized values, where each locale maps to a dictionary of
  /// string key-value pairs.
  final Map<String, Map<String, String>> _localizedValues = <String, Map<String, String>>{};

  /// Retrieves the [CountrySelectorLocalizations] instance from the given
  /// [BuildContext].
  ///
  /// This is used to access the localized strings throughout the app.
  static CountrySelectorLocalizations? of(BuildContext context) {
    return Localizations.of<CountrySelectorLocalizations>(context, CountrySelectorLocalizations);
  }

  static LocalizationsDelegate<CountrySelectorLocalizations> delegate = const CountrySelectorLocalizationsDelegate();

  /// Loads the localized strings from the JSON file corresponding to the given locale.
  ///
  /// The JSON file should be placed under `packages/country_code_selector/i18n/`
  /// with the filename corresponding to the locale's language code.
  Future<bool> load(Locale locale) async {
    // Load the JSON file for the current locale
    final String jsonString = await rootBundle.loadString('packages/country_code_selector/i18n/${locale.languageCode}.json');

    // Decode the JSON file into a Map
    final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    // Populate _localizedValues with the key-value pairs for the current locale
    _localizedValues[locale.languageCode] = jsonMap.map((String key, dynamic value) {
      return MapEntry<String, String>(key, value.toString());
    });

    return true;
  }

  /// Translates the given [code] based on the current locale.
  ///
  /// If a translation is not available, it returns the original [code].
  String translate(String code) {
    // Safely access the locale map and return the translated string
    return _localizedValues[locale.languageCode]?[code] ?? code;
  }
}

/// A delegate class that helps in loading the [CountrySelectorLocalizations]
/// for the app based on the current locale.
class CountrySelectorLocalizationsDelegate extends LocalizationsDelegate<CountrySelectorLocalizations> {
  /// Creates a constant [CountrySelectorLocalizationsDelegate] instance.
  const CountrySelectorLocalizationsDelegate();

  /// Determines whether the delegate supports the given locale.
  ///
  /// This checks if the locale's language code is supported.
  @override
  bool isSupported(Locale locale) => <String>[
        'af',
        'am',
        'ar',
        'as',
        'az',
        'be',
        'bg',
        'bn',
        'bs',
        'ca',
        'cs',
        'cy',
        'da',
        'de',
        'el',
        'en',
        'es',
        'et',
        'eu',
        'fa',
        'fi',
        'fo',
        'fr',
        'ga',
        'gd',
        'gl',
        'gu',
        'ha',
        'he',
        'hi',
        'hr',
        'hu',
        'hy',
        'ia',
        'id',
        'ig',
        'is',
        'it',
        'ja',
        'jv',
        'ka',
        'kk',
        'km',
        'kn',
        'ko',
        'ku',
        'ky',
        'lo',
        'lt',
        'lv',
        'mi',
        'mk',
        'ml',
        'mn',
        'mr',
        'ms',
        'my',
        'nb',
        'ne',
        'nl',
        'nn',
        'no',
        'or',
        'pa',
        'pl',
        'ps',
        'pt',
        'qu',
        'ro',
        'ru',
        'sc',
        'sd',
        'si',
        'sk',
        'sl',
        'so',
        'sq',
        'sr',
        'sv',
        'sw',
        'ta',
        'te',
        'th',
        'ti',
        'tk',
        'to',
        'tr',
        'uk',
        'ur',
        'uz',
        'vi',
        'yo',
        'zh',
        'zu'
      ].contains(locale.languageCode);

  /// Loads the localization for the given [locale].
  ///
  /// This method is called to load the localized strings when the locale changes.
  @override
  Future<CountrySelectorLocalizations> load(Locale locale) async {
    final CountrySelectorLocalizations localizations = CountrySelectorLocalizations(locale);
    await localizations.load(locale);
    return localizations;
  }

  /// Determines whether the delegate should reload if the old delegate changes.
  ///
  /// Returning `false` as the localizations should not reload in this case.
  @override
  bool shouldReload(CountrySelectorLocalizationsDelegate old) => false;
}
