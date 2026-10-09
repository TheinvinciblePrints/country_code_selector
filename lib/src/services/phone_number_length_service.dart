import 'package:dlibphonenumber/dlibphonenumber.dart';
import 'package:flutter/foundation.dart';

/// Looks up possible mobile phone number lengths from the libphonenumber
/// metadata.
abstract final class PhoneNumberLengthService {
  static final Map<String, List<int>?> _cache = <String, List<int>?>{};

  /// Returns the possible mobile number lengths for [regionCode] (an ISO
  /// 3166-1 alpha-2 code), or `null` if the region has no metadata.
  ///
  /// Results are cached per region.
  static List<int>? lengthsFor(String regionCode) {
    final String region = regionCode.toUpperCase();
    return _cache.putIfAbsent(region, () {
      try {
        final List<int>? lengths = PhoneNumberUtil.instance
            .getMetadataForRegion(regionCode: region)
            ?.mobile
            .possibleLength;
        return lengths == null ? null : List<int>.unmodifiable(lengths);
      } catch (e) {
        debugPrint('country_code_selector: no phone metadata for $region: $e');
        return null;
      }
    });
  }
}
