## 0.1.1

* Search ignores accents and Arabic spelling variants: in French "etats" finds
  "États-Unis" and "senegal" finds "Sénégal"; in Arabic "امارات" and
  "الامارات" find "الإمارات" (hamza forms, taa marbuta, alif maqsura and
  tashkeel are normalized). Covers Latin, Greek, Cyrillic, Hebrew and Arabic.
* Alphabetical sorting ignores accents, so "Égypte" sorts with the E's rather
  than after "Zimbabwe", and in Arabic ignores the leading "ال", so "البرازيل"
  sorts under ب.
* The Arabic header now reads "اختر البلد أو المنطقة", since the list includes
  territories as well as countries.

## 0.1.0

First release.

* Country pickers: searchable dialog, searchable bottom sheet, Cupertino
  wheel, dropdown, and `CountryCodeSelectorWidget`, a flag and dial code
  button for phone number fields.
* Design your own picker: `customBuilder` on
  `showCountryCodeSelectorBottomSheet` (or the `CountrySelectorBuilder`
  widget) provides the filtered countries, search, selection, and the
  selected country's phone number lengths.
* 250 countries and territories with flags, dial codes, and mobile number
  lengths from libphonenumber.
* Country names in 202 languages, plus regional variants such as Traditional
  Chinese, Latin Serbian, European Portuguese, and Latin American Spanish,
  from Unicode CLDR 48.2.0.
* `Country.isValidPhoneNumber` validates numbers against libphonenumber's
  number ranges, in local, trunk-prefixed, or international form, with an
  optional `mobileOnly` check. `Country.toE164` returns the number in E.164
  form (`+2348031234567`) for storing or sending to a backend.
  `phoneNumberLength` gives the digits expected after the dial code. Apps
  that don't validate numbers don't include libphonenumber's ~2 MB of
  metadata.
* `pinUserCountry` puts the user's country, detected from their locale
  region, first in the dialog, bottom sheet, `CountryCodeSelectorWidget`, and
  custom builder (`data.userCountry`). Off by default.
* Search by name, ISO code, or dial code, with or without `+`.
* Filter, exclude, sort, pin favourites, and add custom countries with
  `CountryListConfig`.
* Square, round, or emoji flags and four layouts with `LayoutConfig`;
  right-to-left support.
* Theme every picker with the `CountrySelectorThemeData` theme extension.
* `CountryRepository` for looking up and searching countries without UI.
