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
  optional `mobileOnly` check. `phoneNumberLength` gives the digits expected
  after the dial code.
* Search by name, ISO code, or dial code, with or without `+`.
* Filter, exclude, sort, pin favourites, and add custom countries with
  `CountryListConfig`.
* Square, round, or emoji flags and four layouts with `LayoutConfig`;
  right-to-left support.
* Theme every picker with the `CountrySelectorThemeData` theme extension.
* `CountryRepository` for looking up and searching countries without UI.
