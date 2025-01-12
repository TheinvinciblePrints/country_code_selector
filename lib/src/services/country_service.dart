import 'dart:convert';

import '../constants/constants.dart';
import '../models/country_model.dart';
import 'phone_number_length_service.dart';

class CountryService {
  CountryService._();

  static final PhoneNumberLengthService _phoneNumberLengthService =
      PhoneNumberLengthService();

  static Future<Country> loadCountryWithPhoneNumberLength(Country country) async {
    final List<int>? phoneNumberLength =
        await _phoneNumberLengthService.getPhoneNumberLength(regionCode:country.code);
    return country.copyWith(phoneNumberLength: phoneNumberLength);
  }

  // Parse the JSON string into a list of dynamic objects.
  static final List<dynamic> countryList =
      json.decode(StringConstants.countryJson) as List<dynamic>;
}
