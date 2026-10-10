import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/translation_locales.dart';
import '../data/ui_strings.dart';

/// Handles localization for the CountrySelector, providing translated strings
/// based on the current locale.
class CountryCodeSelectorLocalizations {
  /// Creates a localization instance for the given locale.
  CountryCodeSelectorLocalizations(this.locale);

  /// The locale for which this localization instance is created.
  final Locale locale;

  /// The country names for [locale], keyed by ISO code.
  Map<String, String> _values = <String, String>{};

  /// Retrieves the [CountryCodeSelectorLocalizations] instance from the given
  /// [BuildContext].
  ///
  /// This is used to access the localized strings throughout the app.
  static CountryCodeSelectorLocalizations? of(BuildContext context) {
    return Localizations.of<CountryCodeSelectorLocalizations>(
        context, CountryCodeSelectorLocalizations);
  }

  /// The delegate to add to your app's `localizationsDelegates`.
  static const LocalizationsDelegate<CountryCodeSelectorLocalizations>
      delegate = CountryCodeSelectorLocalizationsDelegate();

  /// The translation used when no better match is bundled.
  static const String fallbackLanguageCode = 'en';

  /// Loads the country names that best match [locale].
  ///
  /// Picks the most specific file bundled under `assets/i18n/` (see
  /// [translationFileFor]). If that file can't be loaded, the English
  /// translations are used instead.
  Future<bool> load(Locale locale) async {
    String jsonString;
    try {
      jsonString =
          await rootBundle.loadString(_assetPath(translationFileFor(locale)));
    } catch (_) {
      jsonString =
          await rootBundle.loadString(_assetPath(fallbackLanguageCode));
    }

    final Map<String, dynamic> jsonMap =
        json.decode(jsonString) as Map<String, dynamic>;
    _values = jsonMap.map(
      (String key, dynamic value) =>
          MapEntry<String, String>(key, value.toString()),
    );
    return true;
  }

  static String _assetPath(String id) =>
      'packages/country_code_selector/assets/i18n/$id.json';

  /// Language codes that devices still report under an older or alternate
  /// name.
  static const Map<String, String> _languageAliases = <String, String>{
    'tl': 'fil',
    'iw': 'he',
    'in': 'id',
    'ji': 'yi',
    'jw': 'jv',
  };

  /// Regions whose Spanish, Portuguese or English names follow a regional
  /// standard rather than the base language, as CLDR defines them.
  static const Set<String> _spainSpanish = <String>{
    'ES', 'EA', 'IC', 'GQ', 'PH', //
  };
  static const Set<String> _usEnglish = <String>{
    'US', 'AS', 'GU', 'MH', 'MP', 'PR', 'UM', 'VI', //
  };
  static const Set<String> _traditionalChinese = <String>{'TW', 'HK', 'MO'};

  /// Returns the id of the bundled translation file that best matches
  /// [locale], e.g. `zh_Hant` for `zh_TW`, `pt_PT` for `pt_AO`, `es_419` for
  /// `es_MX`, or [fallbackLanguageCode] if the language isn't bundled.
  static String translationFileFor(Locale locale) {
    final String language =
        _languageAliases[locale.languageCode] ?? locale.languageCode;
    final String? country = locale.countryCode;
    String? script = locale.scriptCode;
    if (script == null &&
        language == 'zh' &&
        _traditionalChinese.contains(country)) {
      script = 'Hant';
    }

    final List<String> candidates = <String>[
      if (script != null && country != null) '${language}_${script}_$country',
      if (script != null) '${language}_$script',
      if (country != null) '${language}_$country',
      if (country != null)
        ...switch (language) {
          'es' when !_spainSpanish.contains(country) => <String>['es_419'],
          'pt' when country != 'BR' => <String>['pt_PT'],
          'en' when !_usEnglish.contains(country) => <String>['en_001'],
          _ => <String>[],
        },
      language,
    ];
    return candidates.firstWhere(
      kTranslationLocales.contains,
      orElse: () => fallbackLanguageCode,
    );
  }

  /// Whether a translation is bundled for [locale]'s language.
  static bool isLanguageSupported(Locale locale) => kTranslationLocales
      .contains(_languageAliases[locale.languageCode] ?? locale.languageCode);

  /// Returns the translated country name for [key], or `null` if there is
  /// none.
  String? lookup(String key) => _values[key];

  /// The default header of the dialog and bottom sheet, e.g. "Select country".
  String get selectCountry => uiString(locale, kSelectCountryKey);

  /// The default text shown when a search has no results, e.g.
  /// "No country found".
  String get noCountryFound => uiString(locale, kNoCountryFoundKey);

  /// Returns the selector UI string [key] for [locale], falling back to the
  /// language and then to English.
  static String uiString(Locale locale, String key) {
    final List<String> parts = translationFileFor(locale).split('_');
    for (int i = parts.length; i > 0; i--) {
      final String? value = kUiStrings[parts.take(i).join('_')]?[key];
      if (value != null) {
        return value;
      }
    }
    return kUiStrings[fallbackLanguageCode]![key]!;
  }

  /// Translates the given [code] based on the current locale.
  ///
  /// If a translation is not available, it returns the original [code].
  String translate(String code) => lookup(code) ?? code;
}

/// A delegate class that helps in loading the [CountryCodeSelectorLocalizations]
/// for the app based on the current locale.
class CountryCodeSelectorLocalizationsDelegate
    extends LocalizationsDelegate<CountryCodeSelectorLocalizations> {
  /// Creates a constant [CountryCodeSelectorLocalizationsDelegate] instance.
  const CountryCodeSelectorLocalizationsDelegate();

  /// Determines whether the delegate supports the given locale.
  ///
  /// This checks if a translation is bundled for the locale's language.
  @override
  bool isSupported(Locale locale) =>
      CountryCodeSelectorLocalizations.isLanguageSupported(locale);

  /// Loads the localization for the given [locale].
  ///
  /// This method is called to load the localized strings when the locale changes.
  @override
  Future<CountryCodeSelectorLocalizations> load(Locale locale) async {
    final CountryCodeSelectorLocalizations localizations =
        CountryCodeSelectorLocalizations(locale);
    await localizations.load(locale);
    return localizations;
  }

  /// Determines whether the delegate should reload if the old delegate changes.
  ///
  /// Returning `false` as the localizations should not reload in this case.
  @override
  bool shouldReload(CountryCodeSelectorLocalizationsDelegate old) => false;
}
