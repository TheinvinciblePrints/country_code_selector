import '../models/models.dart';

/// Configuration class for managing the country list.
///
/// This class allows filtering, excluding, sorting, and adding custom country
/// entries to the country list.
class CountryListConfig {
  /// Creates a configuration for the country list.
  ///
  /// [countryFilter] is used to include only specific countries in the list.
  /// [excludeCountry] is used to exclude specific countries from the list.
  /// [comparator] allows sorting the country list based on custom logic.
  /// [customCountryEntries] allows adding custom country entries to the list.
  ///
  /// If both [countryFilter] and [excludeCountry] are provided, an assertion
  /// error will be thrown, as you can only use one of them at a time.
  CountryListConfig({
    this.countryFilter,
    this.excludeCountry,
    this.comparator,
    this.customCountryEntries,
  }) : assert((excludeCountry == null) || (countryFilter == null),
            'either provide excludeCountry or countryFilter');

  /// A list of country codes to filter the country list.
  ///
  /// If provided, only the countries with these codes will be included in
  /// the list. This is useful when you want to restrict the country options
  /// to specific regions or groups of countries.
  final List<String>? countryFilter;

  /// A comparator function to customize the sorting order of the country list.
  ///
  /// This allows for changing the order in which countries are displayed in
  /// the list. For example, you can sort countries alphabetically or by
  /// dialing code.
  final Comparator<Country>? comparator;

  /// A list of country codes to exclude certain countries from the list.
  ///
  /// If provided, the countries with these codes will not be shown in the
  /// country list. This is useful when you want to hide specific countries
  /// from the options.
  final List<String>? excludeCountry;

  /// A list of custom country entries added by the user.
  ///
  /// This allows the addition of custom country entries to the list, which
  /// may not be included in the default country dataset. This is useful for
  /// adding regions or territories that do not have standard ISO country
  /// codes.
  final List<Country>? customCountryEntries;
}
