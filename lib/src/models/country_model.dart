import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/utils.dart';

/// Represents a country with various associated details such as name, code, emoji, flag image, dial codes, and optional phone number length.
@immutable
class Country {
  /// Creates a [Country] instance with the specified properties.
  ///
  /// [name] is the name of the country.
  /// [code] is the ISO 3166-1 alpha-2 country code.
  /// [emoji] is the emoji representing the country's flag.
  /// [image] is the URL to the country's flag image.
  /// [dialCodes] is the list of dial codes associated with the country.
  /// [phoneNumberLength] is an optional list of possible lengths for phone numbers in the country.
  const Country({
    required this.name,
    required this.code,
    required this.emoji,
    required this.image,
    required this.dialCodes,
    this.phoneNumberLength,
  });

  /// Creates a [Country] instance from a JSON map.
  ///
  /// If any required property is not present in the JSON, it defaults to an empty value or `null`.
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] != null ? json['name'] as String : '',
      code: json['code'] != null ? json['code'] as String : '',
      emoji: json['emoji'] != null ? json['emoji'] as String : '',
      image: 'assets/flags/${(json['code'] as String).toLowerCase()}.svg',
      dialCodes: json['dialCodes'] != null
          ? List<String>.from((json['dialCodes'] as List<dynamic>)
              .map((dynamic item) => item as String))
          : <String>[],
      phoneNumberLength: json['phoneNumberLength'] != null
          ? List<int>.from(json['phoneNumberLength'] as List<int>)
          : <int>[],
    );
  }

  /// The name of the country.
  final String name;

  /// The ISO 3166-1 alpha-2 country code (e.g., "US" for United States).
  final String code;

  /// The emoji representing the country's flag (e.g., 🇺🇸 for the US).
  final String emoji;

  /// The country's flag image.
  final String image;

  /// A list of dialing codes for the country (e.g., ["+1"] for the US).
  final List<String> dialCodes;

  /// A list of possible phone number lengths for the country.
  ///
  /// This is optional and can be `null` if no information is available.
  final List<int>? phoneNumberLength;

  /// Equality operator to compare two [Country] objects based on their name.
  ///
  /// Returns `true` if the [name] of both countries is the same.
  @override
  bool operator ==(Object other) => (other is Country) && other.name == name;

  /// Returns a hash code based on the country's name.
  @override
  int get hashCode => name.hashCode;

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
    return copyWith(
      name:
          CountryCodeSelectorLocalizations.of(context)?.translate(code) ?? name,
    );
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
      phoneNumberLength: phoneNumberLength ?? this.phoneNumberLength,
    );
  }

  String toCountryStringOnly() {
    return '$_cleanName';
  }

  String? get _cleanName {
    return name.replaceAll(RegExp(r'[[\]]'), '').split(',').first;
  }
}
