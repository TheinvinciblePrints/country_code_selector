import '../models/country_model.dart';
import 'phone_number_length_service.dart';

class CountryService {
  final PhoneNumberLengthService _phoneNumberLengthService = PhoneNumberLengthService();

  Future<Country> loadCountryWithPhoneNumberLength(Country country) async {
    final List<int>? phoneNumberLength = await _phoneNumberLengthService.getPhoneNumberLength(country.code);
    return country.copyWith(phoneNumberLength: phoneNumberLength);
  }
}
