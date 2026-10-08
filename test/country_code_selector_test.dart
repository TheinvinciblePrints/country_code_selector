import 'dart:convert';

import 'package:country_code_selector/country_code_selector.dart';
import 'package:country_code_selector/src/utils/country_list_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('en'), Locale('fr')],
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
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  group('country data', () {
    test('has no duplicate codes', () {
      final List<String> codes =
          buildCountryList(null).map((Country c) => c.code).toList();
      expect(codes.toSet().length, codes.length);
    });
  });

  group('Country', () {
    test('equality is by code, so localized copies are equal', () {
      const Country a = Country(
          name: 'Germany',
          code: 'DE',
          emoji: '',
          image: '',
          dialCodes: <String>['+49']);
      expect(a.copyWith(name: 'Allemagne'), a);
      expect(a.copyWith(name: 'Allemagne').hashCode, a.hashCode);
    });

    test('fromJson accepts decoded phoneNumberLength', () {
      final Map<String, dynamic> json = jsonDecode(
              '{"name":"X","code":"NG","dialCodes":["+234"],"phoneNumberLength":[10]}')
          as Map<String, dynamic>;
      expect(Country.fromJson(json).phoneNumberLength, <int>[10]);
    });
  });

  group('buildCountryList', () {
    test('filters case-insensitively', () {
      final List<Country> list = buildCountryList(
          CountryListConfig(countryFilter: <String>['ng', 'GB']));
      expect(list.map((Country c) => c.code),
          unorderedEquals(<String>['NG', 'GB']));
    });

    test('excludes before anything else uses the list', () {
      final List<Country> list =
          buildCountryList(CountryListConfig(excludeCountry: <String>['in']));
      expect(list.any((Country c) => c.code == 'IN'), isFalse);
    });
  });

  group('searchCountries', () {
    final List<Country> all = buildCountryList(null);

    test('matches dial codes with or without +', () {
      expect(searchCountries(all, '234').map((Country c) => c.code),
          contains('NG'));
      expect(searchCountries(all, '+234').map((Country c) => c.code),
          contains('NG'));
    });

    test('does not match dial codes for text queries', () {
      expect(searchCountries(all, 'nigeria').map((Country c) => c.code),
          <String>['NG']);
    });
  });

  group('localization', () {
    test('every language file is bundled', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final CountryCodeSelectorLocalizations l10n =
          await CountryCodeSelectorLocalizations.delegate
              .load(const Locale('fr'));
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
          ));
      expect(tester.takeException(), isNull);
      expect(selected?.code, 'DE');
      expect(selected?.name, 'Allemagne');
    });

    testWidgets('does not require India to be in the list',
        (WidgetTester tester) async {
      Country? selected;
      await _pumpApp(
          tester,
          _app(CountryCodeSelectorDropDown(
            countryListConfig:
                CountryListConfig(excludeCountry: <String>['IN']),
            onSelectValue: (Country c) => selected = c,
          )));
      expect(tester.takeException(), isNull);
      expect(selected, isNotNull);
      expect(selected?.code, isNot('IN'));
    });
  });

  group('dialog', () {
    testWidgets('renders the default search icon and finds by dial code',
        (WidgetTester tester) async {
      await _pumpApp(tester, _app(const CountryCodeSelectorDialog()));
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField), '234');
      await tester.pumpAndSettle();
      expect(find.text(' Nigeria'), findsOneWidget);
    });

    testWidgets('shows localized names before searching',
        (WidgetTester tester) async {
      await _pumpApp(
          tester,
          _app(
            const CountryCodeSelectorDialog(),
            locale: const Locale('fr'),
          ));
      // Albania is near the top of the list, so it's built without scrolling.
      expect(find.text(' Albanie'), findsOneWidget);
      expect(find.text(' Albania'), findsNothing);
    });
  });

  group('cupertino bottom sheet', () {
    testWidgets('returns the initial country without scrolling',
        (WidgetTester tester) async {
      Country? result;
      await _pumpApp(
          tester,
          _app(Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () async {
                result = await CountryCodeSelector
                    .showCountryCodeSelectorCupertinoBottomSheet(
                  context: context,
                  setInitialValue: const Country(
                      name: 'Nigeria',
                      code: 'NG',
                      emoji: '',
                      image: '',
                      dialCodes: <String>['+234']),
                );
              },
              child: const Text('open'),
            ),
          )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('NG'), findsOneWidget);
      expect(find.textContaining('Instance of'), findsNothing);

      await tester.tapAt(const Offset(10, 10)); // dismiss via the barrier
      await tester.pumpAndSettle();
      expect(result?.code, 'NG');
    });
  });
}
