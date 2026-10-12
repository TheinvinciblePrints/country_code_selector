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
  /// [sortingBehavior] and [comparator] control the order of the list.
  /// [customCountryEntries] allows adding custom country entries to the list.
  ///
  /// If both [countryFilter] and [excludeCountry] are provided, an assertion
  /// error will be thrown, as you can only use one of them at a time.
  const CountryListConfig({
    this.countryFilter,
    this.excludeCountry,
    this.sortingBehavior = SortingBehavior.alphabetical,
    this.comparator,
    this.customCountryEntries,
  }) : assert(
         (excludeCountry == null) || (countryFilter == null),
         'either provide excludeCountry or countryFilter',
       ),
       assert(
         sortingBehavior != SortingBehavior.custom || comparator != null,
         'SortingBehavior.custom requires a comparator',
       );

  /// A list of ISO country codes to filter the country list.
  ///
  /// If provided, only the countries with these codes will be included in
  /// the list. Codes are matched case-insensitively.
  final List<String>? countryFilter;

  /// Controls the order of the country list. Defaults to
  /// [SortingBehavior.alphabetical].
  ///
  /// Ignored when [comparator] is provided.
  final SortingBehavior sortingBehavior;

  /// A comparator function to customize the sorting order of the country list.
  ///
  /// It receives localized countries. When provided, it takes precedence over
  /// [sortingBehavior].
  final Comparator<Country>? comparator;

  /// A list of ISO country codes to exclude from the list.
  ///
  /// Codes are matched case-insensitively.
  final List<String>? excludeCountry;

  /// Additional countries to add to the bundled dataset.
  ///
  /// An entry with the same code as a bundled country replaces it. Entries are
  /// subject to [countryFilter] and [excludeCountry] like any other country.
  final List<Country>? customCountryEntries;
}

/// The order of the country list.
enum SortingBehavior {
  /// By localized country name.
  alphabetical,

  /// By numeric dial code, e.g. +1, +7, +20, +27, ..., then by name.
  byDialCode,

  /// By [CountryListConfig.comparator], which must be provided.
  custom,
}
