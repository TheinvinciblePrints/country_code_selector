import 'package:dlibphonenumber/dlibphonenumber.dart';

import '../models/country_model.dart';

/// Validates and normalizes phone numbers against libphonenumber's metadata.
///
/// Usually called through [Country.isValidPhoneNumber] and [Country.toE164].
abstract final class PhoneNumberValidator {
  static final PhoneNumberUtil _util = PhoneNumberUtil.instance;

  /// Whether [number] is a valid phone number of [country].
  ///
  /// [number] may be what the user typed after the country's dial code, with
  /// or without the national trunk prefix (`0803 123 4567` or
  /// `803 123 4567` for Nigeria), or a full international number starting
  /// with `+`, which must then belong to [country]. Spaces, dashes, dots and
  /// brackets are ignored. Where the dial code includes an area code, like
  /// +1876 for Jamaica, the local digits alone are enough.
  ///
  /// With [mobileOnly], landlines and special numbers (toll-free, premium
  /// rate, …) are rejected; numbers that may be either, as in the US, pass.
  ///
  /// Countries libphonenumber has no metadata for, such as custom entries,
  /// are checked against [Country.phoneNumberLength] only, and are invalid if
  /// that is unknown too.
  static bool isValid(
    Country country,
    String number, {
    bool mobileOnly = false,
  }) => toE164(country, number, mobileOnly: mobileOnly) != null;

  /// Returns [number] in E.164 format, e.g. `+2348031234567`, or `null` if it
  /// isn't a valid number of [country] (see [isValid] for the accepted
  /// input).
  ///
  /// E.164 is the international format without spaces that SMS gateways,
  /// authentication providers and most backends expect.
  ///
  /// For countries without metadata, a number of a valid
  /// [Country.phoneNumberLength] is returned as the dial code followed by its
  /// digits.
  static String? toE164(
    Country country,
    String number, {
    bool mobileOnly = false,
  }) {
    final String region = country.code.toUpperCase();
    final String digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return null;
    }
    final PhoneMetadata? metadata = _util.getMetadataForRegion(
      regionCode: region,
    );
    if (metadata == null) {
      final bool validLength =
          country.phoneNumberLength?.contains(digits.length) ?? false;
      final String dialDigits = country.dialCode.replaceAll(RegExp(r'\D'), '');
      return validLength && dialDigits.isNotEmpty
          ? '+$dialDigits$digits'
          : null;
    }

    final List<String> candidates = <String>[];
    if (number.trimLeft().startsWith('+')) {
      candidates.add('+$digits');
    } else {
      // Digits of the dial code beyond the calling code, e.g. "876" in
      // +1876, which users don't retype.
      final String callingCode = metadata.countryCode.toString();
      final String dialDigits = country.dialCode.replaceAll(RegExp(r'\D'), '');
      final String extra =
          dialDigits.startsWith(callingCode)
              ? dialDigits.substring(callingCode.length)
              : '';
      if (extra.isNotEmpty && !digits.startsWith(extra)) {
        candidates.add('$extra$digits');
      }
      candidates.add(digits);
    }

    for (final String candidate in candidates) {
      final PhoneNumber? parsed = _parse(candidate, region);
      if (parsed != null &&
          _util.isValidNumberForRegion(parsed, region) &&
          (!mobileOnly || _isMobile(parsed))) {
        return _util.format(parsed, PhoneNumberFormat.e164);
      }
    }
    return null;
  }

  static PhoneNumber? _parse(String number, String region) {
    try {
      return _util.parse(number, region);
    } on NumberParseException {
      return null;
    }
  }

  static bool _isMobile(PhoneNumber number) {
    final PhoneNumberType type = _util.getNumberType(number);
    return type == PhoneNumberType.mobile ||
        type == PhoneNumberType.fixedLineOrMobile;
  }
}
