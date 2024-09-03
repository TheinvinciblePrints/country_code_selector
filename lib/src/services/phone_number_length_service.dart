import 'package:dlibphonenumber/dlibphonenumber.dart';

class PhoneNumberLengthService {
  final PhoneNumberUtil _phoneUtil = PhoneNumberUtil.instance;

  Future<List<int>?> getPhoneNumberLength(String regionCode) async {
    try {
      final PhoneMetadata? phoneNumberMetadata = _phoneUtil.getMetadataForRegion(regionCode: regionCode);
      if (phoneNumberMetadata != null) {
        return phoneNumberMetadata.mobile.possibleLength;
      }
    } catch (e) {
      print('Error getting phone number length: $e');
    }
    return null;
  }
}
