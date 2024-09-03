import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/utils.dart';

/// Represents a country with its associated details such as name, code, emoji, image, dial codes, and optional phone number length.
@immutable
class Country {
  /// Creates a [Country] instance with the specified properties.
  const Country({
    required this.name,
    required this.code,
    required this.emoji,
    required this.image,
    required this.dialCodes,
    required this.slug,
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
      image: json['image'] != null ? json['image'] as String : '',
      dialCodes: json['dialCodes'] != null ? List<String>.from(json['dialCodes'] as List<String>) : <String>[],
      slug: json['slug'] != null ? json['slug'] as String : '',
      phoneNumberLength: json['phoneNumberLength'] != null ? List<int>.from(json['phoneNumberLength'] as List<String>) : null,
    );
  }

  /// The name of the country.
  final String name;

  /// The ISO 3166-1 alpha-2 country code.
  final String code;

  /// The emoji representing the country's flag.
  final String emoji;

  /// The URL to the country's flag image.
  final String image;

  /// The list of dial codes associated with the country.
  final List<String> dialCodes;

  /// A slug identifier for the country, often used for URLs or identification.
  final String slug;

  /// The list of possible lengths for a phone number in the country.
  final List<int>? phoneNumberLength;

  /// Equality operator to compare two [Country] objects based on their name.
  @override
  bool operator ==(Object other) => (other is Country) && other.name == name;

  /// Returns a hash code based on the country's name.
  @override
  int get hashCode => name.hashCode;

  /// Converts the [Country] object into a map suitable for JSON encoding.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'code': code,
      'emoji': emoji,
      'image': image,
      'dialCodes': dialCodes,
      'slug': slug,
      'phoneNumberLength': phoneNumberLength,
    };
  }

  /// Converts the [Country] object into a JSON string.
  String toJson() => json.encode(toMap());

  /// Localizes the country's name based on the current [BuildContext].
  ///
  /// Uses the [CountrySelectorLocalizations] to translate the name if a translation is available.
  Country localize(BuildContext context) {
    return copyWith(
      name: CountrySelectorLocalizations.of(context)?.translate(code) ?? name,
    );
  }

  /// Creates a copy of the current [Country] object with optional new values for any property.
  ///
  /// If a property is not provided, the original value is used.
  Country copyWith({
    String? name,
    String? code,
    String? emoji,
    String? image,
    List<String>? dialCodes,
    String? slug,
    List<int>? phoneNumberLength,
  }) {
    return Country(
      name: name ?? this.name,
      code: code ?? this.code,
      emoji: emoji ?? this.emoji,
      image: image ?? this.image,
      dialCodes: dialCodes ?? this.dialCodes,
      slug: slug ?? this.slug,
      phoneNumberLength: phoneNumberLength ?? this.phoneNumberLength,
    );
  }
}
