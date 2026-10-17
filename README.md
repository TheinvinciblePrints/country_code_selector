# country_code_selector

[![pub package](https://img.shields.io/pub/v/country_code_selector.svg)](https://pub.dev/packages/country_code_selector)
[![CI](https://github.com/TheinvinciblePrints/country_code_selector/actions/workflows/ci.yml/badge.svg)](https://github.com/TheinvinciblePrints/country_code_selector/actions/workflows/ci.yml)

A country code picker for Flutter. Pick from a searchable dialog, a bottom
sheet, an iOS-style wheel, a dropdown, or a compact button for phone number
fields. Every country comes with its flag, dial code and name in 200+
languages.

<p>
  <img src="https://raw.githubusercontent.com/TheinvinciblePrints/country_code_selector/main/doc/screenshots/dialog.png" width="200" alt="Country dialog">
  <img src="https://raw.githubusercontent.com/TheinvinciblePrints/country_code_selector/main/doc/screenshots/bottom_sheet.png" width="200" alt="Bottom sheet with round flags">
  <img src="https://raw.githubusercontent.com/TheinvinciblePrints/country_code_selector/main/doc/screenshots/cupertino.png" width="200" alt="Cupertino wheel">
  <img src="https://raw.githubusercontent.com/TheinvinciblePrints/country_code_selector/main/doc/screenshots/phone_field.png" width="200" alt="Phone number field with validation">
  <img src="https://raw.githubusercontent.com/TheinvinciblePrints/country_code_selector/main/doc/screenshots/custom_builder.png" width="200" alt="Custom bottom sheet built with customBuilder">
</p>

## Features

- Five pickers: dialog, bottom sheet, Cupertino wheel, dropdown, and a
  flag + dial code button for phone fields.
- Or design your own picker: a builder gives you the countries, search,
  selection and phone number lengths, and you build the UI.
- 250 countries and territories with SVG flags, dial codes and mobile number
  lengths.
- Country names in **202 languages, 238 locales** with regional and script
  variants (Traditional Chinese, Latin Serbian, European Portuguese, Latin
  American Spanish, …), from [Unicode CLDR](https://cldr.unicode.org).
  [See the full list](https://github.com/TheinvinciblePrints/country_code_selector/blob/main/doc/supported_languages.md).
- Search by name, ISO code or dial code (`234` or `+234`).
- Filter, exclude, sort, pin favourites and add your own entries.
- Square, round or emoji flags, four layouts, right-to-left support.
- Follows your app's light and dark theme; customise it with a theme
  extension.

## Getting started

```shell
flutter pub add country_code_selector
```

Add the localization delegate so country names are translated:

```dart
import 'package:country_code_selector/country_code_selector.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: const [
    CountryCodeSelectorLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
  home: const MyHomePage(),
);
```

Without the delegate everything still works, with English country names.

## Usage

### Phone number field

`CountryCodeSelectorWidget` shows the selected flag and dial code and opens a
picker when tapped. It starts on the user's country unless you pass
`initialCountryCode`.

```dart
TextField(
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    labelText: 'Phone number',
    prefixIcon: CountryCodeSelectorWidget(
      initialCountryCode: 'NG',
      pickerType: CountryPickerType.bottomSheet, // or dialog, cupertino
      onChanged: (Country country) => setState(() => _country = country),
    ),
  ),
);
```

### Dialog and bottom sheet

```dart
final Country? country =
    await CountryCodeSelector.showCountryCodeSelectorDialog(
  context: context,
  favouriteCountries: ['NG', 'GH', 'KE'],
);

final Country? fromSheet =
    await CountryCodeSelector.showCountryCodeSelectorBottomSheet(
  context: context,
  isScrollControlled: true, // full height
  useSafeArea: true,
);
```

Both return `null` when dismissed.

#### Put the user's country first

Pass `pinUserCountry: true` to pin the user's country above your favourites.
It's detected from the region of the app's locale, or else the device's (for
example `fr_FR` pins France), and isn't duplicated if it's also a favourite:

```dart
CountryCodeSelector.showCountryCodeSelectorBottomSheet(
  context: context,
  pinUserCountry: true,
  favouriteCountries: ['GB', 'US'],
);
```

It's off by default. Nothing is pinned when the phone has no region set, or
when the country is filtered out. The detection reflects the user's language
and region setting, not their location. `CountryCodeSelectorWidget` and
`CountrySelectorBuilder` accept it too, and a custom builder can read the
detected country from `data.userCountry` even when it isn't pinned.

### Cupertino wheel

```dart
final Country? country = await CountryCodeSelector
    .showCountryCodeSelectorCupertinoBottomSheet(
  context: context,
  setInitialValue: CountryRepository.byCode('NG'),
);
```

Returns the country confirmed with the OK button, or `null` when dismissed.

### Your own bottom sheet design

Pass `customBuilder` to build the sheet's UI yourself. It receives a
`CountrySelectorData` with everything you need:

| | |
|---|---|
| `countries` | The list to show: filtered, sorted, localized and matching the search |
| `allCountries`, `favourites` | Every country, and the favourites in the order given |
| `userCountry` | The user's country from their locale region, or `null` |
| `selected`, `selectedPhoneNumberLength` | The current selection and its mobile number lengths, e.g. `[10]` |
| `query`, `search(text)` | The search text, and a function to update it |
| `select(country)` | Select without closing, e.g. to highlight before confirming |
| `confirm([country])` | Close the sheet and return `country`, or the selection |
| `cancel()` | Close the sheet and return `null` |

```dart
final Country? country =
    await CountryCodeSelector.showCountryCodeSelectorBottomSheet(
  context: context,
  isScrollControlled: true,
  initialCountry: _country, // shown as selected
  favouriteCountries: ['NG', 'GH', 'KE'],
  customBuilder: (BuildContext context, CountrySelectorData data) {
    return Column(
      children: [
        TextField(onChanged: data.search),
        Expanded(
          child: ListView(
            children: [
              for (final Country c in data.countries)
                ListTile(
                  leading: CountryFlag(country: c, mode: FlagMode.round),
                  title: Text(c.name),
                  subtitle: Text(c.dialCode),
                  selected: c == data.selected,
                  onTap: () => data.select(c),
                ),
            ],
          ),
        ),
        if (data.selected != null)
          FilledButton(
            onPressed: data.confirm,
            child: Text(
              'Use ${data.selected!.dialCode} '
              '(${data.selectedPhoneNumberLength?.join(' or ')} digits)',
            ),
          ),
      ],
    );
  },
);
```

Filtering, sorting and localization still follow `countryListConfig` and
`layoutConfig.enableLocalization`. The example app has a complete custom
sheet in `CustomCountrySheet`.

To use the same kind of custom UI somewhere else, such as inline on a page or
in a dialog, use the `CountrySelectorBuilder` widget with `onConfirm` and
`onCancel`.

### Dropdown

```dart
CountryCodeSelectorDropDown(
  selectInitialCountry: 'NG',
  onSelectValue: (Country country) => print(country.dialCode),
);
```

Pass `value` instead to control the selection yourself.

### Working with `Country`

```dart
country.name;              // 'Nigeria' (localized when picked from a selector)
country.code;              // 'NG'
country.dialCode;          // '+234'
country.emoji;             // '🇳🇬'
country.phoneNumberLength; // [10]: mobile digits after the dial code
country.isValidPhoneNumber('0803 123 4567'); // true
country.toE164('0803 123 4567');             // '+2348031234567'
```

### Validating phone numbers

`isValidPhoneNumber` checks a number against the country's real number ranges
using libphonenumber, not just its length:

```dart
final Country ng = CountryRepository.byCode('NG')!;
ng.isValidPhoneNumber('0803 123 4567');     // true: leading 0 and spaces are fine
ng.isValidPhoneNumber('803 123 4567');      // true
ng.isValidPhoneNumber('+234 803 123 4567'); // true
ng.isValidPhoneNumber('+44 7400 123456');   // false: a UK number
ng.isValidPhoneNumber('0803 123');          // false
ng.isValidPhoneNumber(input, mobileOnly: true); // also rejects landlines
```

Where the dial code includes an area code, like `+1876` for Jamaica, the
local digits alone are enough (`'210 1234'`). In a form:

```dart
TextFormField(
  keyboardType: TextInputType.phone,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  decoration: InputDecoration(
    prefixIcon: CountryCodeSelectorWidget(
      onChanged: (Country c) => setState(() => _country = c),
    ),
  ),
  validator: (String? value) =>
      _country.isValidPhoneNumber(value ?? '', mobileOnly: true)
          ? null
          : 'Enter a valid ${_country.name} mobile number',
);
```

`toE164` accepts the same input and returns the number in E.164 form, the
international format without spaces that backends, SMS gateways and
authentication providers expect, or `null` when the number isn't valid:

```dart
ng.toE164('0803 123 4567');     // '+2348031234567'
ng.toE164('+234 803-123-4567'); // '+2348031234567'
ng.toE164('0803 123');          // null
```

Validation uses libphonenumber's numbering rules, which add about 2 MB to a
release build. They're only included if your app calls `isValidPhoneNumber`
or `toE164`; an app that just picks countries doesn't pay for them.

`phoneNumberLength` gives the number of digits typed after `dialCode`, without
the national trunk prefix: a Nigerian number written locally as
0803 123 4567 is +234 803 123 4567, so it's `[10]`. Use it for hints or
`maxLength`, e.g. "10 digits after +234".

## Customization

### Which countries, in which order

```dart
CountryCodeSelector.showCountryCodeSelectorBottomSheet(
  context: context,
  countryListConfig: CountryListConfig(
    countryFilter: ['NG', 'GH', 'KE', 'ZA'], // or excludeCountry: [...]
    sortingBehavior: SortingBehavior.byDialCode, // default: alphabetical
    customCountryEntries: [
      Country(
        name: 'Customland',
        code: 'XC',
        emoji: '🏳️',
        image: 'assets/flags/customland.png', // an asset of your app
        dialCodes: ['+999'],
      ),
    ],
  ),
);
```

### How each row looks

```dart
const LayoutConfig(
  elementsOrder: DisplayOrder.flagCodeAndCountryName,
  flagMode: FlagMode.round, // square, round or emoji
  flagWidth: 24,
  flagHeight: 18,
  showCountryCode: true,
  showCountryName: true,
  enableLocalization: true, // false keeps names in English
);
```

`CountryTile` and `CountryFlag` are exported, so you can build your own list
with the same rows.

### Theme

Add `CountrySelectorThemeData` to your theme to style every picker. Anything
you leave out comes from your `ThemeData`, so dark mode works by default.

```dart
ThemeData(
  extensions: const [
    CountrySelectorThemeData(
      backgroundColor: Colors.white,
      countryNameTextStyle: TextStyle(fontSize: 16),
      dialCodeTextStyle: TextStyle(color: Colors.grey),
      borderRadius: 20,
    ),
  ],
);
```

The search field can also be customised per picker with `SearchStyle`.

### Looking up countries without UI

```dart
CountryRepository.byCode('ng');           // Country? (bundled, English)
CountryRepository.search(CountryRepository.all, '+44');
CountryCodeSelector.getDefaultCountry(context: context); // user's country
```

## Localization

| What | Supported |
|------|-----------|
| Country names | **238 locales**: 202 languages plus 36 regional and script variants |
| Selector text ("Select country", "No country found") | 41 languages, covering 63 locales; others show English |
| Search hint | Every language Flutter's Material widgets support |

**[See every supported language →](https://github.com/TheinvinciblePrints/country_code_selector/blob/main/doc/supported_languages.md)**

The selector picks the closest match for the app's locale and falls back to
English. For example, `zh_TW` uses Traditional Chinese, `es_MX` Latin American
Spanish, `pt_AO` European Portuguese and `fr_CA` Canadian French. Override the
selector's own text with the `header`, `searchStyle.hintText` and
`emptySearchBuilder` parameters.

Flutter's Material widgets support fewer languages than this package. If your
app's `supportedLocales` includes a language Flutter doesn't support, add a
fallback `MaterialLocalizations` delegate for it, as described in
[Flutter's internationalization guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#adding-support-for-a-new-language).

## Credits

- Flags from [flag-icons](https://github.com/lipis/flag-icons) (MIT License,
  see `assets/flags/LICENSE`).
- Country names from the
  [Unicode Common Locale Data Repository](https://cldr.unicode.org) (Unicode
  License v3, see `assets/i18n/LICENSE`). Regenerate them with
  `dart run tool/generate_translations.dart`.
- Phone number rules and lengths from
  [dlibphonenumber](https://pub.dev/packages/dlibphonenumber). The lengths are
  stored in the package; regenerate them with
  `dart run tool/generate_phone_lengths.dart` after upgrading it.

## Contributing

Issues and pull requests are welcome on
[GitHub](https://github.com/TheinvinciblePrints/country_code_selector/issues).
Translations of the selector's own text are especially welcome: add an entry
to `lib/src/data/ui_strings.dart`.
