import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/phone_number_length_service.dart';
import '../services/phone_number_validator.dart';
import '../utils/country_code_selector_localizations.dart';

/// Represents a country with various associated details such as name, code, emoji, flag image, dial codes, and optional phone number length.
@immutable
class Country {
  /// Creates a [Country] instance with the specified properties.
  ///
  /// [name] is the name of the country.
  /// [code] is the ISO 3166-1 alpha-2 country code.
  /// [emoji] is the emoji representing the country's flag.
  /// [image] is the asset path of the country's flag image.
  /// [dialCodes] is the list of dial codes associated with the country.
  /// [phoneNumberLength] overrides the possible phone number lengths. When
  /// omitted, they are looked up from the phone number metadata on first use.
  const Country({
    required this.name,
    required this.code,
    required this.emoji,
    required this.image,
    required this.dialCodes,
    List<int>? phoneNumberLength,
  }) : _phoneNumberLength = phoneNumberLength;

  /// Creates a [Country] instance from a JSON map, as produced by [toMap].
  ///
  /// Missing values default to empty, and [image] defaults to the bundled
  /// flag for [code].
  factory Country.fromJson(Map<String, dynamic> json) {
    final String code = json['code'] as String? ?? '';
    return Country(
      name: json['name'] as String? ?? '',
      code: code,
      emoji: json['emoji'] as String? ?? '',
      image:
          json['image'] as String? ?? 'assets/flags/${code.toLowerCase()}.svg',
      dialCodes: (json['dialCodes'] as List<dynamic>?)
              ?.map((dynamic item) => item as String)
              .toList() ??
          <String>[],
      phoneNumberLength: (json['phoneNumberLength'] as List<dynamic>?)
          ?.map((dynamic item) => item as int)
          .toList(),
    );
  }

  /// The name of the country.
  final String name;

  /// The ISO 3166-1 alpha-2 country code (e.g., "US" for United States).
  final String code;

  /// The emoji representing the country's flag (e.g., 🇺🇸 for the US).
  final String emoji;

  /// The asset path of the country's flag image.
  final String image;

  /// A list of dialing codes for the country (e.g., ["+1"] for the US).
  final List<String> dialCodes;

  /// The main dialing code (e.g., "+1"), or an empty string if there is none.
  String get dialCode => dialCodes.isEmpty ? '' : dialCodes.first;

  final List<int>? _phoneNumberLength;

  /// How many digits a mobile number has after [dialCode], e.g. `[10]` for
  /// Nigeria and `[7]` for Jamaica (+1876).
  ///
  /// The national trunk prefix isn't counted: a Nigerian number written
  /// locally as 0803 123 4567 is +234 803 123 4567, so the 0 is dropped and
  /// 10 digits remain. Use this to validate or limit a phone field that shows
  /// [dialCode] as its prefix.
  ///
  /// Uses the value passed to the constructor if any, otherwise it is looked
  /// up from libphonenumber's metadata. `null` if no information is available,
  /// as for Antarctica.
  List<int>? get phoneNumberLength =>
      _phoneNumberLength ??
      PhoneNumberLengthService.lengthsFor(code, dialCode: dialCode);

  /// Whether [number] is a valid phone number of this country.
  ///
  /// Accepts what the user typed after [dialCode], with or without the
  /// national trunk prefix, or a full international number starting with `+`
  /// that belongs to this country. Formatting characters are ignored.
  /// [mobileOnly] rejects landlines and special numbers.
  ///
  /// ```dart
  /// final Country ng = CountryRepository.byCode('NG')!;
  /// ng.isValidPhoneNumber('0803 123 4567'); // true
  /// ng.isValidPhoneNumber('+234 803 123 4567'); // true
  /// ng.isValidPhoneNumber('803 123'); // false
  /// ```
  ///
  /// See [PhoneNumberValidator.isValid] for details.
  bool isValidPhoneNumber(String number, {bool mobileOnly = false}) =>
      PhoneNumberValidator.isValid(this, number, mobileOnly: mobileOnly);

  /// Equality operator to compare two [Country] objects based on their ISO code.
  ///
  /// Returns `true` if the [code] of both countries is the same, so a country
  /// is still equal to its localized copy.
  @override
  bool operator ==(Object other) =>
      (other is Country) && other.code.toUpperCase() == code.toUpperCase();

  /// Returns a hash code based on the country's ISO code.
  @override
  int get hashCode => code.toUpperCase().hashCode;

  /// Converts the [Country] object into a map suitable for JSON encoding.
  ///
  /// The resulting map contains the country name, code, emoji, flag image URL, dial codes, and phone number length.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'code': code,
      'emoji': emoji,
      'image': image,
      'dialCodes': dialCodes,
      'phoneNumberLength': phoneNumberLength,
    };
  }

  /// Converts the [Country] object into a JSON string.
  ///
  /// This is useful for serializing the country information to be stored or transmitted.
  String toJson() => json.encode(toMap());

  /// Localizes the country's name based on the current [BuildContext].
  ///
  /// This method uses [CountryCodeSelectorLocalizations] to translate the country name
  /// if a translation is available. Otherwise, it returns the original name.
  Country localize(BuildContext context) {
    final String? translated =
        CountryCodeSelectorLocalizations.of(context)?.lookup(code);
    return translated == null ? this : copyWith(name: translated);
  }

  /// Creates a copy of the current [Country] object with optional new values for any property.
  ///
  /// This method allows you to create a modified copy of the country object,
  /// while keeping the original values for properties that are not explicitly provided.
  Country copyWith({
    String? name,
    String? code,
    String? emoji,
    String? image,
    List<String>? dialCodes,
    List<int>? phoneNumberLength,
  }) {
    return Country(
      name: name ?? this.name,
      code: code ?? this.code,
      emoji: emoji ?? this.emoji,
      image: image ?? this.image,
      dialCodes: dialCodes ?? this.dialCodes,
      phoneNumberLength: phoneNumberLength ?? _phoneNumberLength,
    );
  }

  /// The country name without bracketed or comma-separated qualifiers.
  String toCountryStringOnly() {
    return name.replaceAll(RegExp(r'[[\]]'), '').split(',').first;
  }

  @override
  String toString() => 'Country($code, $name, $dialCode)';
}
