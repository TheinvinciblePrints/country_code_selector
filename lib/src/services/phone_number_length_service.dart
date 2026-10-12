import 'package:dlibphonenumber/dlibphonenumber.dart';

/// Looks up possible mobile phone number lengths from the libphonenumber
/// metadata at runtime.
///
/// The bundled countries don't need it: their lengths are stored in the
/// package (see `tool/generate_phone_lengths.dart`), so apps that never
/// validate numbers don't include libphonenumber's metadata. Use this for
/// regions or dial codes outside the bundled data.
abstract final class PhoneNumberLengthService {
  static final Map<String, List<int>?> _cache = <String, List<int>?>{};

  /// Returns how many digits a mobile number of [regionCode] (an ISO 3166-1
  /// alpha-2 code) has after [dialCode], or `null` if unknown.
  ///
  /// The count is for the national number without its trunk prefix: Nigeria
  /// returns `[10]` for 0803 123 4567, because the leading 0 is dropped after
  /// +234. When [dialCode] includes part of the national number, like the
  /// area code in +1876 (Jamaica), those digits aren't counted either, so
  /// Jamaica returns `[7]`.
  ///
  /// Uses the mobile lengths, or the region's general lengths when it has no
  /// separate mobile numbers. Results are cached.
  static List<int>? lengthsFor(String regionCode, {String? dialCode}) {
    final String region = regionCode.toUpperCase();
    final String dialDigits = (dialCode ?? '').replaceAll(RegExp(r'\D'), '');
    return _cache.putIfAbsent('$region$dialDigits', () {
      try {
        final PhoneMetadata? metadata = PhoneNumberUtil.instance
            .getMetadataForRegion(regionCode: region);
        if (metadata == null) {
          return null;
        }
        // -1 marks a number type the region doesn't have.
        List<int> valid(List<int> lengths) =>
            lengths.where((int l) => l > 0).toList();
        List<int> lengths = valid(metadata.mobile.possibleLength);
        if (lengths.isEmpty) {
          lengths = valid(metadata.generalDesc.possibleLength);
        }

        final String callingCode = metadata.countryCode.toString();
        final int extra =
            dialDigits.length > callingCode.length &&
                    dialDigits.startsWith(callingCode)
                ? dialDigits.length - callingCode.length
                : 0;
        lengths =
            lengths
                .map((int l) => l - extra)
                .where((int l) => l > 0)
                .toSet()
                .toList()
              ..sort();
        return lengths.isEmpty ? null : List<int>.unmodifiable(lengths);
      } catch (_) {
        // Metadata lookups shouldn't fail; treat any failure as unknown.
        return null;
      }
    });
  }
}
