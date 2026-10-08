import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Builds the country list shown by the selector widgets.
///
/// Applies [CountryListConfig.countryFilter] or
/// [CountryListConfig.excludeCountry], then sorts with
/// [CountryListConfig.comparator]. Codes are matched case-insensitively.
///
/// [source] replaces the bundled country data when provided and not empty.
List<Country> buildCountryList(
  CountryListConfig? config, {
  List<Map<String, dynamic>>? source,
}) {
  List<Country> countries = (source == null || source.isEmpty)
      ? CountryService.countryList
          .map((dynamic json) => Country.fromJson(json as Map<String, dynamic>))
          .toList()
      : source.map(Country.fromJson).toList();

  final Set<String>? filter = _upperCaseSet(config?.countryFilter);
  if (filter != null) {
    countries = countries
        .where((Country c) => filter.contains(c.code.toUpperCase()))
        .toList();
    if (countries.isEmpty) {
      throw Exception('Invalid country list');
    }
  }

  final Set<String>? excluded = _upperCaseSet(config?.excludeCountry);
  if (excluded != null) {
    countries = countries
        .where((Country c) => !excluded.contains(c.code.toUpperCase()))
        .toList();
  }

  if (config?.comparator != null) {
    countries.sort(config!.comparator);
  }

  return countries;
}

/// Returns the entries of [countries] whose code is in [favouriteCodes],
/// in the order the codes were given.
List<Country> favouritesOf(
    List<Country> countries, List<String>? favouriteCodes) {
  if (favouriteCodes == null || favouriteCodes.isEmpty) {
    return <Country>[];
  }
  final Map<String, Country> byCode = <String, Country>{
    for (final Country c in countries) c.code.toUpperCase(): c,
  };
  return favouriteCodes
      .map((String code) => byCode[code.toUpperCase()])
      .whereType<Country>()
      .toList();
}

/// Filters [countries] by name, ISO code or dial code.
///
/// Dial codes match with or without the leading `+`, so `234` and `+234`
/// both find Nigeria.
List<Country> searchCountries(List<Country> countries, String query) {
  final String q = query.trim().toUpperCase();
  if (q.isEmpty) {
    return countries;
  }
  final String digits = q.replaceAll(RegExp(r'[^0-9]'), '');
  final bool isDialQuery = RegExp(r'^\+?[0-9 ]+$').hasMatch(q);

  return countries.where((Country c) {
    if (c.code.toUpperCase().contains(q) || c.name.toUpperCase().contains(q)) {
      return true;
    }
    return isDialQuery &&
        c.dialCodes.any((String d) => d.replaceAll('+', '').startsWith(digits));
  }).toList();
}

Set<String>? _upperCaseSet(List<String>? codes) {
  if (codes == null || codes.isEmpty) {
    return null;
  }
  return codes.map((String c) => c.toUpperCase()).toSet();
}
