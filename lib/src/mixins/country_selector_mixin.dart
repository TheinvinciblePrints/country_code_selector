import 'dart:convert';

import '../constants/string_constants.dart';

mixin CountrySelectorMixin {
  // Parse the JSON string into a list of dynamic objects.
  final List<dynamic> countryList =
      json.decode(StringConstants.countryJson) as List<dynamic>;
}
