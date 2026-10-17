import 'package:flutter/widgets.dart';

import '../config/country_list_config.dart';
import '../data/countries.dart';
import '../models/models.dart';

/// Access to the bundled country data, plus the filtering, sorting and search
/// used by the selector widgets.
abstract final class CountryRepository {
  /// Every bundled country, with English names.
  static const List<Country> all = kCountries;

  static final Map<String, Country> _byCode = <String, Country>{
    for (final Country c in kCountries) c.code: c,
  };

  /// Returns the bundled country with the ISO [code] (case-insensitive), or
  /// `null` if there is none.
  static Country? byCode(String code) => _byCode[code.toUpperCase()];

  /// Returns the user's country, with an English name, from the region of
  /// the app's locale or else of the device locale, or `null` if neither has
  /// a region in the bundled data.
  ///
  /// This reflects the user's language and region setting, not where they
  /// are. Unlike `CountryCodeSelector.getDefaultCountry`, there is no
  /// fallback, so nothing is assumed when the region is unknown.
  static Country? userCountry(BuildContext context) =>
      <String?>[
        Localizations.maybeLocaleOf(context)?.countryCode,
        WidgetsBinding.instance.platformDispatcher.locale.countryCode,
      ].whereType<String>().map(byCode).whereType<Country>().firstOrNull;

  /// Builds the country list described by [config].
  ///
  /// Adds [CountryListConfig.customCountryEntries], applies
  /// [CountryListConfig.countryFilter] or [CountryListConfig.excludeCountry],
  /// localizes names when [context] is given, then sorts.
  ///
  /// Throws an [ArgumentError] if the filter matches no countries.
  static List<Country> resolve(
    CountryListConfig? config, {
    BuildContext? context,
  }) {
    final Map<String, Country> byCode = <String, Country>{
      for (final Country c in kCountries) c.code: c,
      for (final Country c in config?.customCountryEntries ?? <Country>[])
        c.code.toUpperCase(): c,
    };
    Iterable<Country> countries = byCode.values;

    final Set<String>? filter = _upperCaseSet(config?.countryFilter);
    if (filter != null) {
      countries = countries.where(
        (Country c) => filter.contains(c.code.toUpperCase()),
      );
    }

    final Set<String>? excluded = _upperCaseSet(config?.excludeCountry);
    if (excluded != null) {
      countries = countries.where(
        (Country c) => !excluded.contains(c.code.toUpperCase()),
      );
    }

    final List<Country> result =
        context == null
            ? countries.toList()
            : countries.map((Country c) => c.localize(context)).toList();

    if (filter != null && result.isEmpty) {
      throw ArgumentError.value(
        config!.countryFilter,
        'countryFilter',
        'matches no countries',
      );
    }

    result.sort(
      config?.comparator ??
          switch (config?.sortingBehavior ?? SortingBehavior.alphabetical) {
            SortingBehavior.byDialCode => _compareByDialCode,
            SortingBehavior.alphabetical ||
            SortingBehavior.custom => _compareByName,
          },
    );
    return result;
  }

  /// Returns the entries of [countries] whose code is in [favouriteCodes], in
  /// the order the codes were given, without duplicates.
  ///
  /// [first], when given and present in [countries], is placed before them;
  /// it is how the selectors pin the user's country.
  static List<Country> favourites(
    List<Country> countries,
    List<String>? favouriteCodes, {
    String? first,
  }) {
    final Map<String, Country> byCode = <String, Country>{
      for (final Country c in countries) c.code.toUpperCase(): c,
    };
    final Set<String> seen = <String>{};
    return <String>[if (first != null) first, ...?favouriteCodes]
        .map((String code) => code.toUpperCase())
        .where(seen.add)
        .map((String code) => byCode[code])
        .whereType<Country>()
        .toList();
  }

  /// Filters [countries] by name, ISO code or dial code.
  ///
  /// Dial codes match with or without the leading `+`, so `234` and `+234`
  /// both find Nigeria.
  static List<Country> search(List<Country> countries, String query) {
    final String q = query.trim().toUpperCase();
    if (q.isEmpty) {
      return countries;
    }
    final String digits = q.replaceAll(RegExp(r'[^0-9]'), '');
    final bool isDialQuery = RegExp(r'^\+?[0-9 ]+$').hasMatch(q);

    return countries.where((Country c) {
      if (c.code.toUpperCase().contains(q) ||
          c.name.toUpperCase().contains(q)) {
        return true;
      }
      return isDialQuery &&
          c.dialCodes.any(
            (String d) => d.replaceAll('+', '').startsWith(digits),
          );
    }).toList();
  }

  static int _compareByName(Country a, Country b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  static int _compareByDialCode(Country a, Country b) {
    final int byDial = _dialNumber(a).compareTo(_dialNumber(b));
    return byDial != 0 ? byDial : _compareByName(a, b);
  }

  /// The dial code as a number for sorting; countries without one sort last.
  static int _dialNumber(Country c) =>
      int.tryParse(c.dialCode.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1 << 30;

  static Set<String>? _upperCaseSet(List<String>? codes) {
    if (codes == null || codes.isEmpty) {
      return null;
    }
    return codes.map((String c) => c.toUpperCase()).toSet();
  }
}
