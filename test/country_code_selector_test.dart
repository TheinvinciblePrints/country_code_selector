import 'dart:convert';
import 'dart:io';

import 'package:country_code_selector/country_code_selector.dart';
import 'package:country_code_selector/src/data/phone_lengths.dart';
import 'package:country_code_selector/src/data/translation_locales.dart';
import 'package:country_code_selector/src/data/ui_strings.dart';
import 'package:country_code_selector/src/utils/text_folding.dart';
import 'package:dlibphonenumber/dlibphonenumber.dart'
    show PhoneMetadata, PhoneNumberFormat, PhoneNumberUtil;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('en'), Locale('fr'), Locale('ar')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      CountryCodeSelectorLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

/// Pumps [widget] and lets the localization JSON (real asset I/O) finish
/// loading, which `pumpAndSettle` alone does not wait for.
Future<void> _pumpApp(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  for (int i = 0; i < 20 && find.byType(Scaffold).evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  group('country data', () {
    final List<String> codes =
        CountryRepository.all.map((Country c) => c.code).toList();

    test('has no duplicate codes', () {
      expect(codes.toSet().length, codes.length);
    });

    test('every country has a flag and an English name', () {
      final Map<String, dynamic> en =
          jsonDecode(File('assets/i18n/en.json').readAsStringSync())
              as Map<String, dynamic>;
      for (final Country c in CountryRepository.all) {
        expect(File(c.image).existsSync(), isTrue, reason: c.image);
        expect(en.containsKey(c.code), isTrue, reason: c.code);
        expect(c.dialCodes, isNotEmpty, reason: c.code);
      }
    });

    test('byCode is case-insensitive', () {
      expect(CountryRepository.byCode('ng')?.name, 'Nigeria');
      expect(CountryRepository.byCode('zz'), isNull);
    });
  });

  group('Country', () {
    const Country germany = Country(
      name: 'Germany',
      code: 'DE',
      emoji: '',
      image: '',
      dialCodes: <String>['+49'],
    );

    test('equality is by code, so localized copies are equal', () {
      expect(germany.copyWith(name: 'Allemagne'), germany);
      expect(germany.copyWith(name: 'Allemagne').hashCode, germany.hashCode);
    });

    test('fromJson accepts decoded phoneNumberLength', () {
      final Map<String, dynamic> json =
          jsonDecode(
                '{"name":"X","code":"NG","dialCodes":["+234"],"phoneNumberLength":[10]}',
              )
              as Map<String, dynamic>;
      expect(Country.fromJson(json).phoneNumberLength, <int>[10]);
    });

    test('toJson and fromJson round-trip', () {
      final Country ng = CountryRepository.byCode('NG')!;
      final Country copy = Country.fromJson(
        jsonDecode(ng.toJson()) as Map<String, dynamic>,
      );
      expect(copy.toMap(), ng.toMap());
    });

    test('phoneNumberLength is looked up lazily', () {
      expect(CountryRepository.byCode('NG')!.phoneNumberLength, contains(10));
      expect(
        germany.copyWith(phoneNumberLength: <int>[1]).phoneNumberLength,
        <int>[1],
      );
    });

    test('phoneNumberLength counts digits after the dial code', () {
      List<int>? lengths(String code) =>
          CountryRepository.byCode(code)!.phoneNumberLength;
      expect(lengths('NG'), <int>[10]); // trunk 0 not counted
      expect(lengths('US'), <int>[10]);
      // The dial code already includes the area code.
      expect(lengths('JM'), <int>[7]);
      expect(lengths('AS'), <int>[7]);
      expect(lengths('AQ'), isNull); // no phone metadata
      expect(CountryRepository.byCode('VA')!.dialCode, '+39');
      for (final Country c in CountryRepository.all) {
        final List<int>? l = c.phoneNumberLength;
        if (l != null) {
          expect(l, isNotEmpty, reason: c.code);
          expect(l.every((int n) => n > 0), isTrue, reason: '${c.code} $l');
        }
      }
    });

    test('stored phone lengths match dlibphonenumber', () {
      // If this fails after upgrading dlibphonenumber or editing the country
      // data, run: dart run tool/generate_phone_lengths.dart
      for (final Country c in CountryRepository.all) {
        expect(
          kPhoneNumberLengths[c.code],
          PhoneNumberLengthService.lengthsFor(c.code, dialCode: c.dialCode),
          reason: c.code,
        );
      }
      expect(
        kPhoneNumberLengths.keys.where(
          (String code) => CountryRepository.byCode(code) == null,
        ),
        isEmpty,
      );
    });

    test('dialCode is the first dial code', () {
      expect(germany.dialCode, '+49');
      expect(germany.copyWith(dialCodes: <String>[]).dialCode, '');
    });
  });

  group('isValidPhoneNumber', () {
    final Country ng = CountryRepository.byCode('NG')!;

    test('accepts local, trunk-prefixed and international forms', () {
      expect(ng.isValidPhoneNumber('803 123 4567'), isTrue);
      expect(ng.isValidPhoneNumber('0803 123 4567'), isTrue);
      expect(ng.isValidPhoneNumber('(0803) 123-4567'), isTrue);
      expect(ng.isValidPhoneNumber('+234 803 123 4567'), isTrue);
    });

    test('rejects wrong lengths, other countries and empty input', () {
      expect(ng.isValidPhoneNumber('803 123'), isFalse);
      expect(ng.isValidPhoneNumber('803 123 4567 89'), isFalse);
      expect(ng.isValidPhoneNumber('+44 7400 123456'), isFalse);
      expect(ng.isValidPhoneNumber(''), isFalse);
      expect(ng.isValidPhoneNumber('abc'), isFalse);
    });

    test(
      'accepts only the local digits where the dial code has an area code',
      () {
        final Country jm = CountryRepository.byCode('JM')!;
        expect(jm.dialCode, '+1876');
        expect(jm.isValidPhoneNumber('210 1234'), isTrue);
        expect(jm.isValidPhoneNumber('876 210 1234'), isTrue);
        expect(jm.isValidPhoneNumber('+1 876 210 1234'), isTrue);
        // A US number isn't Jamaican.
        expect(jm.isValidPhoneNumber('+1 201 555 0123'), isFalse);
      },
    );

    test('mobileOnly rejects landlines', () {
      final PhoneMetadata gb =
          PhoneNumberUtil.instance.getMetadataForRegion(regionCode: 'GB')!;
      final Country uk = CountryRepository.byCode('GB')!;
      expect(uk.isValidPhoneNumber(gb.fixedLine.exampleNumber), isTrue);
      expect(
        uk.isValidPhoneNumber(gb.fixedLine.exampleNumber, mobileOnly: true),
        isFalse,
      );
      expect(
        uk.isValidPhoneNumber(gb.mobile.exampleNumber, mobileOnly: true),
        isTrue,
      );
    });

    test('falls back to phoneNumberLength without metadata', () {
      const Country custom = Country(
        name: 'Customland',
        code: 'XC',
        emoji: '',
        image: '',
        dialCodes: <String>['+999'],
        phoneNumberLength: <int>[6],
      );
      expect(custom.isValidPhoneNumber('123 456'), isTrue);
      expect(custom.isValidPhoneNumber('12345'), isFalse);
      expect(
        CountryRepository.byCode('AQ')!.isValidPhoneNumber('123456'),
        isFalse,
      );
    });

    test('toE164 normalizes every accepted form', () {
      for (final String input in <String>[
        '0803 123 4567',
        '803-123-4567',
        '(0803) 123 4567',
        '+234 803 123 4567',
        '+2348031234567',
      ]) {
        expect(ng.toE164(input), '+2348031234567', reason: input);
      }
      expect(ng.toE164('0803 123'), isNull);
      expect(ng.toE164('+44 7400 123456'), isNull);
      expect(ng.toE164(''), isNull);

      final Country jm = CountryRepository.byCode('JM')!;
      expect(jm.toE164('210 1234'), '+18762101234');
      expect(jm.toE164('876 210 1234'), '+18762101234');

      const Country custom = Country(
        name: 'Customland',
        code: 'XC',
        emoji: '',
        image: '',
        dialCodes: <String>['+999'],
        phoneNumberLength: <int>[6],
      );
      expect(custom.toE164('123 456'), '+999123456');
      expect(custom.toE164('12345'), isNull);
    });

    test('toE164 is consistent with isValidPhoneNumber for every country', () {
      final PhoneNumberUtil util = PhoneNumberUtil.instance;
      for (final Country c in CountryRepository.all) {
        final PhoneMetadata? m = util.getMetadataForRegion(regionCode: c.code);
        final String example = m?.mobile.exampleNumber ?? '';
        if (m == null || example.isEmpty) {
          continue;
        }
        final String expected = '+${m.countryCode}$example';
        final String national = util.format(
          util.parse(expected, null),
          PhoneNumberFormat.national,
        );
        expect(c.toE164(national), expected, reason: '${c.code} $national');
        expect(c.toE164(expected), expected, reason: c.code);
      }
    });

    test(
      "accepts every country's example numbers, and only for that country",
      () {
        final PhoneNumberUtil util = PhoneNumberUtil.instance;
        int checked = 0;
        for (final Country c in CountryRepository.all) {
          final PhoneMetadata? m = util.getMetadataForRegion(
            regionCode: c.code,
          );
          final String example = m?.mobile.exampleNumber ?? '';
          if (m == null || example.isEmpty) {
            continue;
          }
          checked++;
          expect(
            c.isValidPhoneNumber(example, mobileOnly: true),
            isTrue,
            reason: '${c.code} $example',
          );
          expect(
            c.isValidPhoneNumber('+${m.countryCode}$example'),
            isTrue,
            reason: '${c.code} +${m.countryCode}$example',
          );
          // The way people write it locally, e.g. with Nigeria's leading 0.
          final String national = util.format(
            util.parse('+${m.countryCode}$example', null),
            PhoneNumberFormat.national,
          );
          expect(
            c.isValidPhoneNumber(national),
            isTrue,
            reason: '${c.code} $national',
          );
          // Typing only what follows a dial code like +1876 also works.
          final String dialDigits = c.dialCode.substring(1);
          final String extra = dialDigits.substring('${m.countryCode}'.length);
          if (extra.isNotEmpty && example.startsWith(extra)) {
            expect(
              c.isValidPhoneNumber(example.substring(extra.length)),
              isTrue,
              reason: '${c.code} local',
            );
          }
        }
        expect(checked, greaterThan(230));
        // Nigeria's example number is invalid for its neighbours.
        final String ngExample =
            util.getMetadataForRegion(regionCode: 'NG')!.mobile.exampleNumber;
        for (final String other in <String>['GH', 'BJ', 'CM', 'GB']) {
          expect(
            CountryRepository.byCode(
              other,
            )!.isValidPhoneNumber('+234$ngExample'),
            isFalse,
            reason: other,
          );
        }
      },
    );
  });

  group('CountryRepository.resolve', () {
    List<String> codesOf(List<Country> list) =>
        list.map((Country c) => c.code).toList();

    test('filters case-insensitively', () {
      expect(
        codesOf(
          CountryRepository.resolve(
            const CountryListConfig(countryFilter: <String>['ng', 'GB']),
          ),
        ),
        unorderedEquals(<String>['NG', 'GB']),
      );
    });

    test('excludes case-insensitively', () {
      expect(
        codesOf(
          CountryRepository.resolve(
            const CountryListConfig(excludeCountry: <String>['in']),
          ),
        ),
        isNot(contains('IN')),
      );
    });

    test('throws when the filter matches nothing', () {
      expect(
        () => CountryRepository.resolve(
          const CountryListConfig(countryFilter: <String>['ZZ']),
        ),
        throwsArgumentError,
      );
    });

    test('adds and replaces custom entries', () {
      const Country custom = Country(
        name: 'Customland',
        code: 'XX',
        emoji: '',
        image: '',
        dialCodes: <String>['+999'],
      );
      final List<Country> list = CountryRepository.resolve(
        CountryListConfig(
          customCountryEntries: <Country>[
            custom,
            CountryRepository.byCode('NG')!.copyWith(name: 'Naija'),
          ],
        ),
      );
      expect(list, contains(custom));
      expect(list.where((Country c) => c.code == 'NG').single.name, 'Naija');
    });

    test('sorts alphabetically by default, ignoring accents', () {
      final List<String> keys =
          CountryRepository.resolve(
            null,
          ).map((Country c) => sortKey(c.name, 'en')).toList();
      expect(keys, List<String>.of(keys)..sort());
      // Accented names sort with their base letter, not after Z.
      final List<String> names =
          CountryRepository.resolve(null).map((Country c) => c.name).toList();
      expect(
        names.indexOf('Åland Islands'),
        lessThan(names.indexOf('Albania')),
      );
      expect(names.last, isNot('Åland Islands'));
    });

    test('sorts by dial code', () {
      final List<Country> list = CountryRepository.resolve(
        const CountryListConfig(sortingBehavior: SortingBehavior.byDialCode),
      );
      expect(list.first.dialCode, '+1');
      expect(
        codesOf(list).indexOf('EG'),
        lessThan(codesOf(list).indexOf('ZA')),
      );
    });

    test('comparator takes precedence', () {
      final List<Country> list = CountryRepository.resolve(
        CountryListConfig(
          comparator: (Country a, Country b) => b.code.compareTo(a.code),
        ),
      );
      expect(list.first.code, 'ZW');
    });
  });

  group('CountryRepository.favourites', () {
    test('keeps the given order and ignores unknown codes', () {
      expect(
        CountryRepository.favourites(CountryRepository.all, <String>[
          'gb',
          'ZZ',
          'NG',
        ]).map((Country c) => c.code),
        <String>['GB', 'NG'],
      );
    });
  });

  group('CountryRepository.search', () {
    const List<Country> all = CountryRepository.all;

    test('matches dial codes with or without +', () {
      expect(
        CountryRepository.search(all, '234').map((Country c) => c.code),
        contains('NG'),
      );
      expect(
        CountryRepository.search(all, '+234').map((Country c) => c.code),
        contains('NG'),
      );
    });

    test('does not match dial codes for text queries', () {
      expect(
        CountryRepository.search(all, 'nigeria').map((Country c) => c.code),
        <String>['NG'],
      );
    });
  });

  group('localization', () {
    String fileFor(Locale l) =>
        CountryCodeSelectorLocalizations.translationFileFor(l);

    test('picks the most specific bundled translation', () {
      expect(fileFor(const Locale('fr')), 'fr');
      expect(fileFor(const Locale('fr', 'CA')), 'fr_CA');
      expect(fileFor(const Locale('fr', 'BE')), 'fr');
      expect(fileFor(const Locale('zh')), 'zh');
      expect(fileFor(const Locale('zh', 'TW')), 'zh_Hant');
      expect(fileFor(const Locale('zh', 'HK')), 'zh_Hant_HK');
      expect(
        fileFor(
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ),
        'zh_Hant',
      );
      expect(
        fileFor(
          const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
        ),
        'sr_Latn',
      );
      expect(fileFor(const Locale('pt', 'BR')), 'pt');
      expect(fileFor(const Locale('pt', 'PT')), 'pt_PT');
      expect(fileFor(const Locale('pt', 'AO')), 'pt_PT');
      expect(fileFor(const Locale('es', 'ES')), 'es');
      expect(fileFor(const Locale('es', 'MX')), 'es_419');
      expect(fileFor(const Locale('en', 'US')), 'en');
      expect(fileFor(const Locale('en', 'GB')), 'en_001');
      expect(fileFor(const Locale('en', 'AU')), 'en_AU');
      expect(fileFor(const Locale('tl')), 'fil');
      expect(fileFor(const Locale('xx')), 'en');
    });

    test('supports every bundled language and its aliases', () {
      const CountryCodeSelectorLocalizationsDelegate delegate =
          CountryCodeSelectorLocalizationsDelegate();
      for (final String l in <String>['en', 'yo', 'ha', 'ig', 'fil', 'tl']) {
        expect(delegate.isSupported(Locale(l)), isTrue, reason: l);
      }
      expect(delegate.isSupported(const Locale('xx')), isFalse);
    });

    test(
      'every generated translation file is bundled and complete enough',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final Set<String> files =
            Directory('assets/i18n')
                .listSync()
                .map((FileSystemEntity f) => f.uri.pathSegments.last)
                .where((String name) => name.endsWith('.json'))
                .map((String name) => name.substring(0, name.length - 5))
                .toSet();
        expect(files, kTranslationLocales);

        for (final String id in kTranslationLocales) {
          final Map<String, dynamic> names =
              jsonDecode(File('assets/i18n/$id.json').readAsStringSync())
                  as Map<String, dynamic>;
          final int named =
              CountryRepository.all
                  .where((Country c) => names.containsKey(c.code))
                  .length;
          expect(
            named,
            greaterThanOrEqualTo(CountryRepository.all.length * 0.75),
            reason: id,
          );
        }
      },
    );

    test('loads regional translations', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      Future<String> nameOf(Locale l, String code) async =>
          (await CountryCodeSelectorLocalizations.delegate.load(
            l,
          )).translate(code);
      expect(await nameOf(const Locale('zh'), 'TW'), '台湾');
      expect(await nameOf(const Locale('zh', 'TW'), 'TW'), '台灣');
      expect(await nameOf(const Locale('yo'), 'NG'), isNot('Nigeria'));
    });

    test('every language file is bundled', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final CountryCodeSelectorLocalizations l10n =
          await CountryCodeSelectorLocalizations.delegate.load(
            const Locale('fr'),
          );
      expect(l10n.translate('DE'), 'Allemagne');
    });

    test('falls back to English when a file is missing', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final CountryCodeSelectorLocalizations l10n =
          CountryCodeSelectorLocalizations(const Locale('xx'));
      await l10n.load(const Locale('xx'));
      expect(l10n.translate('DE'), 'Germany');
    });
  });

  group('CountryCodeSelectorDropDown', () {
    testWidgets('works in a non-English locale', (WidgetTester tester) async {
      Country? selected;
      await _pumpApp(
        tester,
        _app(
          CountryCodeSelectorDropDown(
            selectInitialCountry: 'DE',
            onSelectValue: (Country c) => selected = c,
          ),
          locale: const Locale('fr'),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(selected?.code, 'DE');
      expect(selected?.name, 'Allemagne');
    });

    testWidgets('does not require India to be in the list', (
      WidgetTester tester,
    ) async {
      Country? selected;
      await _pumpApp(
        tester,
        _app(
          CountryCodeSelectorDropDown(
            countryListConfig: CountryListConfig(
              excludeCountry: <String>['IN'],
            ),
            onSelectValue: (Country c) => selected = c,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(selected, isNotNull);
      expect(selected?.code, isNot('IN'));
    });
  });

  group('UI strings', () {
    String select(Locale l) =>
        CountryCodeSelectorLocalizations.uiString(l, kSelectCountryKey);

    test('fall back to the language, then English', () {
      expect(select(const Locale('fr')), 'Sélectionnez un pays');
      expect(select(const Locale('fr', 'CA')), 'Sélectionnez un pays');
      expect(select(const Locale('pt', 'PT')), 'Selecione um país');
      expect(select(const Locale('zh', 'TW')), '選擇國家/地區');
      expect(select(const Locale('zh', 'HK')), '選擇國家/地區');
      expect(
        select(
          const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
        ),
        'Izaberite zemlju',
      );
      expect(select(const Locale('yo')), 'Select country');
      expect(select(const Locale('xx')), 'Select country');
    });

    test('every entry is complete and matches a bundled translation', () {
      for (final MapEntry<String, Map<String, String>> e
          in kUiStrings.entries) {
        expect(
          e.value.keys,
          unorderedEquals(<String>[kSelectCountryKey, kNoCountryFoundKey]),
          reason: e.key,
        );
        expect(kTranslationLocales, contains(e.key), reason: e.key);
      }
    });
  });

  group('dialog', () {
    testWidgets('renders the default search icon and finds by dial code', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, _app(const CountryCodeSelectorDialog()));
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField), '234');
      await tester.pumpAndSettle();
      expect(find.text('Nigeria'), findsOneWidget);
    });

    testWidgets('translates its own text', (WidgetTester tester) async {
      await _pumpApp(
        tester,
        _app(const CountryCodeSelectorDialog(), locale: const Locale('fr')),
      );
      expect(find.text('Sélectionnez un pays'), findsOneWidget);
      expect(find.text('Rechercher'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('Aucun pays trouvé'), findsOneWidget);
    });

    testWidgets('keeps English names when enableLocalization is false', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        _app(
          const CountryCodeSelectorDialog(
            layoutConfig: LayoutConfig(enableLocalization: false),
          ),
          locale: const Locale('fr'),
        ),
      );
      expect(find.text('Albania'), findsOneWidget);
      expect(find.text('Sélectionnez un pays'), findsOneWidget);
    });

    testWidgets('shows localized names before searching', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        _app(const CountryCodeSelectorDialog(), locale: const Locale('fr')),
      );
      // Albania is near the top of the list, so it's built without scrolling.
      expect(find.text('Albanie'), findsOneWidget);
      expect(find.text('Albania'), findsNothing);
    });
  });

  group('cupertino bottom sheet', () {
    testWidgets('without a confirm button, returns the shown country', (
      WidgetTester tester,
    ) async {
      Country? result;
      await _pumpApp(
        tester,
        _app(
          Builder(
            builder:
                (BuildContext context) => TextButton(
                  onPressed: () async {
                    result =
                        await CountryCodeSelector.showCountryCodeSelectorCupertinoBottomSheet(
                          context: context,
                          showDoneButton: false,
                          setInitialValue: const Country(
                            name: 'Nigeria',
                            code: 'NG',
                            emoji: '',
                            image: '',
                            dialCodes: <String>['+234'],
                          ),
                        );
                  },
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('+234'), findsOneWidget);
      expect(find.textContaining('Instance of'), findsNothing);

      await tester.tapAt(const Offset(10, 10)); // dismiss via the barrier
      await tester.pumpAndSettle();
      expect(result?.code, 'NG');
    });
  });

  group('CountryCodeSelector lookups', () {
    Future<BuildContext> contextFor(WidgetTester tester, Locale locale) async {
      late BuildContext captured;
      await _pumpApp(
        tester,
        _app(
          Builder(
            builder: (BuildContext context) {
              captured = context;
              return const SizedBox();
            },
          ),
          locale: locale,
        ),
      );
      return captured;
    }

    testWidgets('getDefaultCountry uses the device region', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localeTestValue = const Locale('fr', 'FR');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final BuildContext context = await contextFor(tester, const Locale('fr'));
      expect(
        CountryCodeSelector.getDefaultCountry(context: context).name,
        'France',
      );
    });

    testWidgets('getDefaultCountry falls back to the US', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localeTestValue = const Locale('en');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final BuildContext context = await contextFor(tester, const Locale('en'));
      expect(
        CountryCodeSelector.getDefaultCountry(context: context).code,
        'US',
      );
    });

    testWidgets('getCountryByCountryCode localizes and falls back', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await contextFor(tester, const Locale('fr'));
      expect(
        CountryCodeSelector.getCountryByCountryCode(
          context: context,
          countryCode: 'de',
        ).name,
        'Allemagne',
      );
      expect(
        CountryCodeSelector.getCountryByCountryCode(
          context: context,
          countryCode: 'ZZ',
        ).code,
        'US',
      );
    });
  });

  group('CountryTile', () {
    final Country ng = CountryRepository.byCode('NG')!;

    Future<void> pumpTile(
      WidgetTester tester,
      LayoutConfig config, {
      TextDirection direction = TextDirection.ltr,
    }) {
      return _pumpApp(
        tester,
        _app(
          Directionality(
            textDirection: direction,
            child: CountryTile(country: ng, layoutConfig: config),
          ),
        ),
      );
    }

    double x(WidgetTester tester, Finder f) => tester.getCenter(f).dx;

    testWidgets('shows the dial code, not the ISO code', (
      WidgetTester tester,
    ) async {
      await pumpTile(tester, const LayoutConfig());
      expect(find.text('+234'), findsOneWidget);
      expect(find.text('NG'), findsNothing);
    });

    for (final (DisplayOrder order, List<String> expected) in <
      (DisplayOrder, List<String>)
    >[
      (DisplayOrder.flagCodeAndCountryName, <String>['flag', 'code', 'name']),
      (DisplayOrder.codeFlagAndCountryName, <String>['code', 'flag', 'name']),
      (DisplayOrder.nameCodeAndFlag, <String>['name', 'code', 'flag']),
      (DisplayOrder.codeCountryNameAndFlag, <String>['code', 'name', 'flag']),
    ]) {
      testWidgets('lays out $order', (WidgetTester tester) async {
        await pumpTile(tester, LayoutConfig(elementsOrder: order));
        final Map<String, double> pos = <String, double>{
          'flag': x(tester, find.byType(CountryFlag)),
          'code': x(tester, find.text('+234')),
          'name': x(tester, find.text('Nigeria')),
        };
        final List<String> actual =
            pos.keys.toList()
              ..sort((String a, String b) => pos[a]!.compareTo(pos[b]!));
        expect(actual, expected);
      });
    }

    testWidgets('follows right-to-left reading order', (
      WidgetTester tester,
    ) async {
      await pumpTile(
        tester,
        const LayoutConfig(),
        direction: TextDirection.rtl,
      );
      expect(
        x(tester, find.byType(CountryFlag)),
        greaterThan(x(tester, find.text('Nigeria'))),
      );
      expect(
        tester.widget<Text>(find.text('+234')).textDirection,
        TextDirection.ltr,
      );
    });

    testWidgets('draws emoji and round flags', (WidgetTester tester) async {
      await pumpTile(tester, const LayoutConfig(flagMode: FlagMode.emoji));
      expect(find.text(ng.emoji), findsOneWidget);

      await pumpTile(tester, const LayoutConfig(flagMode: FlagMode.round));
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('sizes flags exactly as configured', (
      WidgetTester tester,
    ) async {
      await pumpTile(
        tester,
        const LayoutConfig(
          flagMode: FlagMode.round,
          flagWidth: 30,
          flagHeight: 24,
        ),
      );
      expect(tester.getSize(find.byType(CountryFlag)), const Size(24, 24));

      await pumpTile(tester, const LayoutConfig(flagWidth: 30, flagHeight: 18));
      expect(tester.getSize(find.byType(CountryFlag)), const Size(30, 18));
    });

    testWidgets('falls back to the emoji without an image', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        _app(
          CountryTile(
            country: const Country(
              name: 'Customland',
              code: 'XX',
              emoji: '🏳️',
              image: '',
              dialCodes: <String>['+999'],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('🏳️'), findsOneWidget);
    });

    testWidgets('uses the theme extension', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              CountrySelectorThemeData(
                countryNameTextStyle: TextStyle(color: Color(0xFF00AA00)),
              ),
            ],
          ),
          home: Scaffold(body: CountryTile(country: ng)),
        ),
      );
      expect(
        tester.widget<Text>(find.text('Nigeria')).style?.color,
        const Color(0xFF00AA00),
      );
    });
  });

  group('search list', () {
    testWidgets('accepts a plain widget from emptySearchBuilder', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        _app(
          CountryCodeSelectorDialog(
            emptySearchBuilder:
                (BuildContext context) => const Text('nothing here'),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('nothing here'), findsOneWidget);
    });

    testWidgets('hides favourites while searching', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        _app(
          const CountryCodeSelectorDialog(favouriteCountries: <String>['NG']),
        ),
      );
      expect(find.text('Nigeria'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'alb');
      await tester.pumpAndSettle();
      expect(find.text('Nigeria'), findsNothing);
      expect(find.text('Albania'), findsOneWidget);
    });
  });

  group('controlled dropdown', () {
    testWidgets('shows value and does not report it on start', (
      WidgetTester tester,
    ) async {
      final List<Country> reported = <Country>[];
      await _pumpApp(
        tester,
        _app(
          CountryCodeSelectorDropDown(
            value: CountryRepository.byCode('DE'),
            onSelectValue: reported.add,
          ),
        ),
      );
      expect(find.text('Germany'), findsOneWidget);
      expect(reported, isEmpty);
    });
  });

  testWidgets('cupertino confirm button returns the selection', (
    WidgetTester tester,
  ) async {
    Country? result;
    await _pumpApp(
      tester,
      _app(
        Builder(
          builder:
              (BuildContext context) => TextButton(
                onPressed: () async {
                  result =
                      await CountryCodeSelector.showCountryCodeSelectorCupertinoBottomSheet(
                        context: context,
                        setInitialValue: CountryRepository.byCode('GB'),
                      );
                },
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result?.code, 'GB');
  });

  testWidgets('cupertino sheet with a confirm button cancels on dismiss', (
    WidgetTester tester,
  ) async {
    Country? result = CountryRepository.byCode('NG');
    await _pumpApp(
      tester,
      _app(
        Builder(
          builder:
              (BuildContext context) => TextButton(
                onPressed: () async {
                  result =
                      await CountryCodeSelector.showCountryCodeSelectorCupertinoBottomSheet(
                        context: context,
                        setInitialValue: CountryRepository.byCode('GB'),
                      );
                },
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  group('CountryCodeSelectorWidget', () {
    testWidgets('shows the initial country and updates from the picker', (
      WidgetTester tester,
    ) async {
      Country? changed;
      await _pumpApp(
        tester,
        _app(
          Center(
            child: CountryCodeSelectorWidget(
              initialCountryCode: 'NG',
              onChanged: (Country c) => changed = c,
            ),
          ),
        ),
      );
      expect(find.text('+234'), findsOneWidget);

      await tester.tap(find.byType(CountryCodeSelectorWidget));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'albania');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Albania'));
      await tester.pumpAndSettle();

      expect(changed?.code, 'AL');
      expect(find.text('+355'), findsOneWidget);
    });
  });

  group('custom builder', () {
    /// A minimal custom UI: a search field, one button per country, and
    /// texts showing the data the builder receives.
    Widget customUi(BuildContext context, CountrySelectorData data) {
      return Material(
        child: Column(
          children: <Widget>[
            TextField(onChanged: data.search),
            Text('selected: ${data.selected?.name}'),
            Text('length: ${data.selectedPhoneNumberLength}'),
            Text(
              'favourites: ${data.favourites.map((Country c) => c.code).join(',')}',
            ),
            Text('count: ${data.countries.length}/${data.allCountries.length}'),
            TextButton(onPressed: data.confirm, child: const Text('confirm')),
            TextButton(onPressed: data.cancel, child: const Text('cancel')),
            Expanded(
              child: ListView(
                children: <Widget>[
                  for (final Country c in data.countries)
                    TextButton(
                      key: ValueKey<String>(c.code),
                      onPressed: () => data.select(c),
                      child: Text(c.name),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    /// Opens the custom sheet and returns a getter for its result.
    Future<Future<Country?> Function()> openSheet(
      WidgetTester tester, {
      Country? initialCountry,
      Locale locale = const Locale('en'),
    }) async {
      Country? result;
      bool done = false;
      await _pumpApp(
        tester,
        _app(
          Builder(
            builder:
                (BuildContext context) => TextButton(
                  onPressed: () async {
                    result =
                        await CountryCodeSelector.showCountryCodeSelectorBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          initialCountry: initialCountry,
                          favouriteCountries: const <String>['NG', 'GH'],
                          customBuilder: customUi,
                        );
                    done = true;
                  },
                  child: const Text('open'),
                ),
          ),
          locale: locale,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return () async => done ? result : throw StateError('still open');
    }

    testWidgets('gets the countries, favourites and search', (
      WidgetTester tester,
    ) async {
      await openSheet(tester);

      final int total = CountryRepository.all.length;
      expect(find.text('count: $total/$total'), findsOneWidget);
      expect(find.text('favourites: NG,GH'), findsOneWidget);
      expect(find.text('selected: null'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '+234');
      await tester.pumpAndSettle();
      expect(find.text('count: 1/$total'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('NG')), findsOneWidget);
    });

    testWidgets('select updates the selection and phone length; confirm '
        'returns it', (WidgetTester tester) async {
      final Future<Country?> Function() result = await openSheet(tester);

      // Without a selection, confirm does nothing.
      await tester.tap(find.text('confirm'));
      await tester.pumpAndSettle();
      expect(find.text('selected: null'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nigeria');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('NG')));
      await tester.pumpAndSettle();
      expect(find.text('selected: Nigeria'), findsOneWidget);
      expect(find.textContaining('length: ['), findsOneWidget);
      expect(find.textContaining('10'), findsWidgets);

      await tester.tap(find.text('confirm'));
      await tester.pumpAndSettle();
      final Country? picked = await result();
      expect(picked?.code, 'NG');
      expect(picked?.phoneNumberLength, contains(10));
    });

    testWidgets('starts at initialCountry, localized; cancel returns null', (
      WidgetTester tester,
    ) async {
      final Future<Country?> Function() result = await openSheet(
        tester,
        initialCountry: CountryRepository.byCode('DE'),
        locale: const Locale('fr'),
      );
      expect(find.text('selected: Allemagne'), findsOneWidget);

      await tester.tap(find.text('cancel'));
      await tester.pumpAndSettle();
      expect(await result(), isNull);
    });

    testWidgets('works inline with onConfirm', (WidgetTester tester) async {
      Country? confirmed;
      await _pumpApp(
        tester,
        _app(
          CountrySelectorBuilder(
            countryListConfig: const CountryListConfig(
              countryFilter: <String>['GB', 'FR'],
            ),
            onConfirm: (Country c) => confirmed = c,
            builder:
                (BuildContext context, CountrySelectorData data) => Column(
                  children: <Widget>[
                    for (final Country c in data.countries)
                      TextButton(
                        onPressed: () => data.confirm(c),
                        child: Text(c.name),
                      ),
                  ],
                ),
          ),
        ),
      );
      expect(find.byType(TextButton), findsNWidgets(2));
      await tester.tap(find.text('France'));
      await tester.pumpAndSettle();
      expect(confirmed?.code, 'FR');
      expect(find.text('France'), findsOneWidget); // nothing was popped
    });
  });

  group('pinUserCountry', () {
    /// The countries in the pinned section, read from the rows above the
    /// divider.
    List<String> pinnedCodes(WidgetTester tester) {
      final double dividerY = tester.getTopLeft(find.byType(Divider)).dy;
      return tester
          .widgetList<CountryTile>(find.byType(CountryTile))
          .where(
            (CountryTile t) =>
                tester.getTopLeft(find.byWidget(t)).dy < dividerY,
          )
          .map((CountryTile t) => t.country.code)
          .toList();
    }

    void deviceLocale(WidgetTester tester, Locale locale) {
      tester.platformDispatcher.localeTestValue = locale;
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    }

    testWidgets('is off by default', (WidgetTester tester) async {
      deviceLocale(tester, const Locale('fr', 'FR'));
      await _pumpApp(tester, _app(const CountryCodeSelectorDialog()));
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('pins the device country first, before favourites, once', (
      WidgetTester tester,
    ) async {
      deviceLocale(tester, const Locale('fr', 'FR'));
      await _pumpApp(
        tester,
        _app(
          const CountryCodeSelectorDialog(
            pinUserCountry: true,
            favouriteCountries: <String>['GB', 'FR', 'NG'],
          ),
        ),
      );
      expect(pinnedCodes(tester), <String>['FR', 'GB', 'NG']);
    });

    testWidgets("prefers the app locale's region", (WidgetTester tester) async {
      deviceLocale(tester, const Locale('fr', 'FR'));
      await _pumpApp(
        tester,
        MaterialApp(
          locale: const Locale('en', 'NG'),
          supportedLocales: const <Locale>[Locale('en', 'NG')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            CountryCodeSelectorLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const Scaffold(
            body: CountryCodeSelectorDialog(pinUserCountry: true),
          ),
        ),
      );
      expect(pinnedCodes(tester), <String>['NG']);
    });

    testWidgets('pins nothing without a region or when excluded', (
      WidgetTester tester,
    ) async {
      deviceLocale(tester, const Locale('en'));
      await _pumpApp(
        tester,
        _app(const CountryCodeSelectorDialog(pinUserCountry: true)),
      );
      expect(find.byType(Divider), findsNothing);

      deviceLocale(tester, const Locale('fr', 'FR'));
      await _pumpApp(
        tester,
        _app(
          const CountryCodeSelectorDialog(
            pinUserCountry: true,
            countryListConfig: CountryListConfig(
              excludeCountry: <String>['FR'],
            ),
          ),
        ),
      );
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('getDefaultCountry still falls back to the US', (
      WidgetTester tester,
    ) async {
      deviceLocale(tester, const Locale('en'));
      late BuildContext context;
      await _pumpApp(
        tester,
        _app(
          Builder(
            builder: (BuildContext c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(CountryRepository.userCountry(context), isNull);
      expect(
        CountryCodeSelector.getDefaultCountry(context: context).code,
        'US',
      );
    });

    testWidgets('custom builder gets userCountry, localized, and pins it', (
      WidgetTester tester,
    ) async {
      deviceLocale(tester, const Locale('de', 'DE'));
      CountrySelectorData? data;
      await _pumpApp(
        tester,
        _app(
          CountrySelectorBuilder(
            pinUserCountry: true,
            favouriteCountries: const <String>['GB'],
            builder: (BuildContext context, CountrySelectorData d) {
              data = d;
              return const SizedBox();
            },
          ),
          locale: const Locale('fr'),
        ),
      );
      expect(data!.userCountry?.code, 'DE');
      expect(data!.userCountry?.name, 'Allemagne');
      expect(data!.favourites.map((Country c) => c.code), <String>['DE', 'GB']);
    });

    testWidgets('custom builder exposes userCountry even when not pinned', (
      WidgetTester tester,
    ) async {
      deviceLocale(tester, const Locale('de', 'DE'));
      CountrySelectorData? data;
      await _pumpApp(
        tester,
        _app(
          CountrySelectorBuilder(
            builder: (BuildContext context, CountrySelectorData d) {
              data = d;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(data!.userCountry?.code, 'DE');
      expect(data!.favourites, isEmpty);
    });
  });

  group('accent and Arabic folding', () {
    test('foldForSearch removes accents and marks', () {
      expect(foldForSearch('États-Unis'), 'etats-unis');
      expect(foldForSearch('Sénégal'), 'senegal');
      expect(foldForSearch('Việt Nam'), 'viet nam');
      expect(foldForSearch('Curaçao'), 'curacao');
      expect(foldForSearch('Ελλάδα'), 'ελλαδα');
      expect(foldForSearch('Ёлка'), 'елка');
      expect(foldForSearch('İzmir'), 'izmir');
      expect(foldForSearch('Straße Øst Łódź'), 'strasse ost lodz');
    });

    test(
      'foldForSearch normalizes Arabic hamza, taa marbuta, yaa and tashkeel',
      () {
        expect(foldForSearch('الإمارات'), 'الامارات');
        expect(foldForSearch('أ آ إ'), 'ا ا ا');
        expect(foldForSearch('جمهورية'), 'جمهوريه');
        expect(foldForSearch('مصرى'), 'مصري');
        expect(foldForSearch('مَرْحَبًا'), 'مرحبا');
      },
    );

    test('foldForSearch leaves other scripts intact', () {
      expect(foldForSearch('日本'), '日本');
      expect(foldForSearch('भारत'), 'भारत');
    });

    test('sortKey ignores a leading ال only in Arabic', () {
      expect(sortKey('البرازيل', 'ar'), 'برازيل');
      expect(sortKey('البرازيل', 'fa'), 'البرازيل');
      expect(sortKey('Égypte', 'fr'), 'egypte');
    });

    Future<List<Country>> resolvedIn(WidgetTester tester, Locale locale) async {
      late List<Country> list;
      await _pumpApp(
        tester,
        _app(
          Builder(
            builder: (BuildContext context) {
              list = CountryRepository.resolve(null, context: context);
              return const SizedBox();
            },
          ),
          locale: locale,
        ),
      );
      return list;
    }

    List<String> codes(List<Country> list) =>
        list.map((Country c) => c.code).toList();

    testWidgets('French: search ignores accents, É sorts with the E names', (
      WidgetTester tester,
    ) async {
      final List<Country> fr = await resolvedIn(tester, const Locale('fr'));
      expect(codes(CountryRepository.search(fr, 'etats')), contains('US'));
      expect(codes(CountryRepository.search(fr, 'senegal')), <String>['SN']);
      expect(codes(CountryRepository.search(fr, 'ÉTATS')), contains('US'));

      final List<String> order = codes(fr);
      // Dominique < Égypte < Équateur < France, and Égypte isn't after Zimbabwe.
      expect(order.indexOf('DM'), lessThan(order.indexOf('EG')));
      expect(order.indexOf('EG'), lessThan(order.indexOf('EC')));
      expect(order.indexOf('EC'), lessThan(order.indexOf('FR')));
      expect(order.indexOf('EG'), lessThan(order.indexOf('ZW')));
    });

    testWidgets('Arabic: search ignores hamza and the article, sorting '
        'ignores the leading ال', (WidgetTester tester) async {
      final List<Country> ar = await resolvedIn(tester, const Locale('ar'));
      // With and without the article, with and without hamza.
      for (final String query in <String>['امارات', 'الامارات', 'الإمارات']) {
        expect(
          codes(CountryRepository.search(ar, query)),
          contains('AE'),
          reason: query,
        );
      }

      final List<String> order = codes(ar);
      // البرازيل sorts under ب: باكستان < البرازيل < بنما.
      expect(order.indexOf('PK'), lessThan(order.indexOf('BR')));
      expect(order.indexOf('BR'), lessThan(order.indexOf('PA')));
      // الجزائر sorts under ج, after بنما.
      expect(order.indexOf('PA'), lessThan(order.indexOf('DZ')));
    });

    test('Arabic header says country or region', () {
      expect(
        CountryCodeSelectorLocalizations.uiString(
          const Locale('ar'),
          kSelectCountryKey,
        ),
        'اختر البلد أو المنطقة',
      );
    });
  });
}
