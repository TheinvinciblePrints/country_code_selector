import 'dart:convert';

import 'package:flutter/material.dart';

import '../../country_code_selector.dart';

/// A service class responsible for handling country data, including fetching
/// a list of countries and retrieving default or specific country information.
///
/// This class uses JSON data for countries, and provides methods to return
/// country objects localized to the user's device locale. It also integrates
/// additional features such as phone number length retrieval for each country.
class CountrySelector with CountryService {
  // Private constructor to prevent instantiation
  CountrySelector._();

  /// Retrieves the list of countries by parsing the predefined JSON data.
  ///
  /// The method reads the JSON data from the constant string, parses it, and
  /// converts it into a list of `Country` objects.
  ///
  /// Returns a [Future] that resolves to a [List] of [Country] objects.
  Future<List<Country>> getCountries() async {
    // JSON data is stored as a string in constants.
    const String rawData = StringConstants.countryJson;

    // Parse the string into a list of dynamic objects.
    final List<dynamic> parsed = json.decode(rawData) as List<dynamic>;

    // Map the dynamic objects to Country objects and return.
    return parsed.map((dynamic json) => Country.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Retrieves the default country based on the user's device locale.
  ///
  /// This method reads a predefined JSON dataset of country information and tries to
  /// match the device's current locale to a country by its ISO code. If a match is found,
  /// the country name is localized using the app's localization system. It also includes
  /// the phone number length for the country by calling [loadCountryWithPhoneNumberLength].
  ///
  /// If no matching country is found for the device's locale, the method throws an exception.
  /// If the device does not have a country code, it defaults to 'US'.
  ///
  /// Example usage:
  /// ```dart
  /// Country country = await getDefaultCountry(context: context);
  /// print(country.name); // Output: localized country name
  /// ```
  ///
  /// Returns a [Future] that resolves to a [Country] object with localized name and phone number length.
  ///
  /// Throws an [Exception] if no country is found for the locale.
  Future<Country> getDefaultCountry({required BuildContext context}) async {
    // Read the predefined JSON data from constants.
    const String rawData = StringConstants.countryJson;

    // Parse the JSON string into a list of dynamic country objects.
    final List<dynamic> countryList = json.decode(rawData) as List<dynamic>;

    // Retrieve the device's locale.
    final Locale deviceLocale = Localizations.localeOf(context);

    // Get the device's ISO country code or fallback to 'US' if not available.
    final String deviceIsoCode = deviceLocale.countryCode ?? 'US';

    // Find the country that corresponds to the device's ISO code in the dataset.
    final Map<String, dynamic> countryJson = countryList.cast<Map<String, dynamic>>().firstWhere(
          (Map<String, dynamic> country) => country['code'].toString().toUpperCase() == deviceIsoCode.toUpperCase(),
          orElse: () => throw Exception('Country for locale $deviceIsoCode not found.'),
        );

    // Create a Country object from the JSON data.
    final Country country = Country.fromJson(countryJson);

    // Localize the country name using the current locale.
    final String localizedCountryName = CountrySelectorLocalizations.of(context)?.translate(country.code) ?? country.name;

    // Return the Country object with the localized name and phone number length.
    final Country localizedCountry = country.copyWith(name: localizedCountryName);
    return loadCountryWithPhoneNumberLength(localizedCountry);
  }

  /// Retrieves a specific country by its ISO country code.
  ///
  /// This method takes in a [context] and [countryCode], and searches the predefined
  /// JSON dataset for a country that matches the provided country code. If found,
  /// the method localizes the country's name.
  ///
  /// [context] is required to access localization and other Flutter-specific resources.
  ///
  /// [countryCode] must be a valid ISO country code (e.g., 'US', 'GB').
  ///
  /// Returns a [Future] that resolves to a [Country] object or `null` if not found.
  Future<Country?> getCountryByCountryCode({required BuildContext context, required String countryCode}) async {
    
    // Retrieve the JSON data.
    const String rawData = StringConstants.countryJson;

    // Parse the JSON string into a list of dynamic objects.
    final List<dynamic> countryList = json.decode(rawData) as List<dynamic>;

    try {
      // Find the country that matches the given country code.
      final Map<String, dynamic> countryJson = countryList.cast<Map<String, dynamic>>().firstWhere(
            (Map<String, dynamic> country) => country['code'].toString().toUpperCase() == countryCode.toUpperCase(),
            orElse: () => throw Exception('Country with code $countryCode not found'),
          );

      // Create a Country object and localize the name.
      final Country country = Country.fromJson(countryJson);
      final String localizedCountryName = CountrySelectorLocalizations.of(context)?.translate(country.code) ?? country.name;

      // Return the country with the localized name.
      return country.copyWith(name: localizedCountryName);
    } catch (e) {
      // Return null if the country is not found.
      return null;
    }
  }
}
