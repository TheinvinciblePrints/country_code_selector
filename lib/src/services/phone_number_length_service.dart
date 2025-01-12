import 'package:dlibphonenumber/dlibphonenumber.dart';
import 'package:flutter/foundation.dart';

class PhoneNumberLengthService {
  final PhoneNumberUtil _phoneUtil = PhoneNumberUtil.instance;

  Future<List<int>?> getPhoneNumberLength({required String regionCode}) async {
    try {
      final PhoneMetadata? phoneNumberMetadata = _phoneUtil.getMetadataForRegion(regionCode: regionCode);
      if (phoneNumberMetadata != null) {
        return phoneNumberMetadata.mobile.possibleLength;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting phone number length: $e');
      }
    }
    return null;
  }
}
