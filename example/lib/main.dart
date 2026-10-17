import 'package:country_code_selector/country_code_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          dividerColor: Colors.transparent,
          cardTheme: const CardThemeData(color: Colors.white),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.black)))),
      supportedLocales: const [
        Locale("af"),
        Locale("am"),
        Locale("ar"),
        Locale("az"),
        Locale("be"),
        Locale("bg"),
        Locale("bn"),
        Locale("bs"),
        Locale("ca"),
        Locale("cs"),
        Locale("da"),
        Locale("de"),
        Locale("el"),
        Locale("en"),
        Locale("es"),
        Locale("et"),
        Locale("fa"),
        Locale("fi"),
        Locale("fr"),
        Locale("gl"),
        Locale("ha"),
        Locale("he"),
        Locale("hi"),
        Locale("hr"),
        Locale("hu"),
        Locale("hy"),
        Locale("id"),
        Locale("is"),
        Locale("it"),
        Locale("ja"),
        Locale("ka"),
        Locale("kk"),
        Locale("km"),
        Locale("ko"),
        Locale("ku"),
        Locale("ky"),
        Locale("lt"),
        Locale("lv"),
        Locale("mk"),
        Locale("ml"),
        Locale("mn"),
        Locale("ms"),
        Locale("nb"),
        Locale("nl"),
        Locale("nn"),
        Locale("no"),
        Locale("pl"),
        Locale("ps"),
        Locale("pt"),
        Locale("ro"),
        Locale("ru"),
        Locale("sd"),
        Locale("sk"),
        Locale("sl"),
        Locale("so"),
        Locale("sq"),
        Locale("sr"),
        Locale("sv"),
        Locale("ta"),
        Locale("tg"),
        Locale("th"),
        Locale("tk"),
        Locale("tr"),
        Locale("tt"),
        Locale("uk"),
        Locale("ug"),
        Locale("ur"),
        Locale("uz"),
        Locale("vi"),
        Locale("zh")
      ],
      localizationsDelegates: [
        CountryCodeSelectorLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextStyle get _defaultTextStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  Widget title({String? title}) {
    return Text(
      title ?? "",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Country? initialDialogDefaultValue;
  Country? initialDialogCustomValue;
  Country? initialBottomDefaultValue;
  Country? initialBottomCustomValue;
  Country? initialCupertinoBottomDefaultValue;
  Country? initialCupertinoBottomCustomValue;
  Country? customBuilderValue;

  @override
  void didChangeDependencies() {
    Country byCode(String code) => CountryCodeSelector.getCountryByCountryCode(
        context: context, countryCode: code);
    initialDialogDefaultValue = byCode("IN");
    initialDialogCustomValue = byCode("ID");
    initialBottomDefaultValue = byCode("IN");
    initialBottomCustomValue = byCode("IS");
    initialCupertinoBottomDefaultValue = byCode("IN");
    initialCupertinoBottomCustomValue = byCode("UY");
    customBuilderValue ??= byCode("NG");
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Country Code Selector',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              Card(
                child: ExpansionTile(
                  expandedCrossAxisAlignment: CrossAxisAlignment.center,
                  collapsedShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  initiallyExpanded: true,
                  title: Text(
                    'Country picker using dialog',
                    style: _defaultTextStyle,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 5),
                            child: Column(
                              children: [
                                title(title: "Default"),
                                ElevatedButton(
                                  onPressed: () async {
                                    CountryCodeSelector
                                        .showCountryCodeSelectorDialog(
                                      context: context,
                                      layoutConfig: const LayoutConfig(
                                          elementsOrder: DisplayOrder
                                              .flagCodeAndCountryName),
                                    ).then(
                                      (value) {
                                        if (value != null) {
                                          initialDialogDefaultValue = value;
                                          debugPrint(
                                              'showCountryPickerDialog default ::${initialDialogDefaultValue?.phoneNumberLength}');
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                  child: initialDialogCustomValue != null
                                      ? ButtonRowWidget(
                                          country: initialDialogDefaultValue)
                                      : const SizedBox.shrink(),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 5),
                              child: Column(
                                children: [
                                  title(title: "Custom"),
                                  ElevatedButton(
                                    onPressed: () {
                                      CountryCodeSelector
                                          .showCountryCodeSelectorDialog(
                                        size: const Size(250, 550),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(25),
                                        ),
                                        context: context,
                                        favouriteCountries: ["+91", "+355"],
                                        layoutConfig: const LayoutConfig(
                                            flagWidth: 24,
                                            flagHeight: 24,
                                            elementsOrder: DisplayOrder
                                                .codeCountryNameAndFlag,
                                            flagMode: FlagMode.round),
                                      ).then(
                                        (value) {
                                          if (value != null) {
                                            initialDialogCustomValue = value;
                                            debugPrint(
                                                'showCountryPickerDialog custom ::${initialDialogCustomValue?.name}');
                                            setState(() {});
                                          }
                                        },
                                      );
                                    },
                                    child: initialDialogCustomValue != null
                                        ? ButtonRowWidget(
                                            country: initialDialogCustomValue)
                                        : const SizedBox.shrink(),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Card(
                child: ExpansionTile(
                  title: Text(
                    'Country picker using bottom sheet',
                    style: _defaultTextStyle,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 5),
                            child: Column(
                              children: [
                                title(title: "Default"),
                                ElevatedButton(
                                  onPressed: () => CountryCodeSelector
                                      .showCountryCodeSelectorBottomSheet(
                                    favouriteCountries: ["India"],
                                    layoutConfig: const LayoutConfig(
                                        elementsOrder: DisplayOrder
                                            .flagCodeAndCountryName),
                                    context: context,
                                  ).then((value) {
                                    if (value != null) {
                                      initialBottomDefaultValue = value;
                                      debugPrint(
                                          'showCountryPickerBottom :: ${initialBottomDefaultValue?.phoneNumberLength}');
                                      setState(() {});
                                    }
                                  }),
                                  child: ButtonRowWidget(
                                      country: initialBottomDefaultValue),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 10),
                              child: Column(
                                children: [
                                  title(title: "Custom"),
                                  ElevatedButton(
                                    onPressed: () => CountryCodeSelector
                                        .showCountryCodeSelectorBottomSheet(
                                      countryListConfig: CountryListConfig(),
                                      showDragHandle: true,
                                      context: context,
                                      favouriteCountries: ["+91", "+376"],
                                      layoutConfig: const LayoutConfig(
                                        flagWidth: 24,
                                        flagHeight: 24,
                                        elementsOrder:
                                            DisplayOrder.codeCountryNameAndFlag,
                                        flagMode: FlagMode.round,
                                      ),
                                    ).then((value) {
                                      if (value != null) {
                                        initialBottomCustomValue = value;
                                        debugPrint(
                                            'showCountryPickerBottom :: ${initialBottomCustomValue?.name}');
                                        setState(() {});
                                      }
                                    }),
                                    child: ButtonRowWidget(
                                        country: initialBottomCustomValue),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Card(
                child: ExpansionTile(
                  title: Text(
                    'Country picker using cupertino bottom sheet',
                    style: _defaultTextStyle,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 5),
                            child: Column(
                              children: [
                                title(title: "Default"),
                                ElevatedButton(
                                  onPressed: () {
                                    CountryCodeSelector
                                        .showCountryCodeSelectorCupertinoBottomSheet(
                                      context: context,
                                      setInitialValue:
                                          initialCupertinoBottomDefaultValue,
                                    ).then(
                                      (value) {
                                        if (value != null) {
                                          initialCupertinoBottomDefaultValue =
                                              value;
                                          debugPrint(
                                              'showCountryPickerCupertinoBottom :: ${initialCupertinoBottomDefaultValue?.name ?? ""}');
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                  child: ButtonRowWidget(
                                      country:
                                          initialCupertinoBottomDefaultValue),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 5),
                              child: Column(
                                children: [
                                  title(title: "Custom"),
                                  ElevatedButton(
                                    onPressed: () {
                                      CountryCodeSelector
                                          .showCountryCodeSelectorCupertinoBottomSheet(
                                        setInitialValue:
                                            initialCupertinoBottomCustomValue,
                                        isScrollControlled: true,
                                        context: context,
                                        diameterRatio: 0.8,
                                        layoutConfig: const LayoutConfig(
                                          flagWidth: 24,
                                          flagHeight: 24,
                                          elementsOrder: DisplayOrder
                                              .codeCountryNameAndFlag,
                                          flagMode: FlagMode.round,
                                        ),
                                      ).then(
                                        (value) {
                                          if (value != null) {
                                            initialCupertinoBottomCustomValue =
                                                value;
                                            debugPrint(
                                                'showCountryPickerCupertinoBottom :: ${initialCupertinoBottomCustomValue?.name ?? ""}');
                                            setState(() {});
                                          }
                                        },
                                      );
                                    },
                                    child: ButtonRowWidget(
                                        country:
                                            initialCupertinoBottomCustomValue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Card(
                child: ExpansionTile(
                  title: Text('Country picker using drop down',
                      style: _defaultTextStyle),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 15),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: CountryCodeSelectorDropDown(
                          underline: const SizedBox.shrink(),
                          layoutConfig: const LayoutConfig(
                            showCountryName: true,
                            showCountryCode: true,
                            showCountryFlag: true,
                            flagMode: FlagMode.round,
                            flagWidth: 18,
                            flagHeight: 18,
                            elementsOrder: DisplayOrder.flagCodeAndCountryName,
                          ),
                          onSelectValue: (Country value) {
                            debugPrint('CountryPickerDropDown ::${value.name}');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: ExpansionTile(
                  title: Text('Custom bottom sheet (customBuilder)',
                      style: _defaultTextStyle),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 15),
                      child: ElevatedButton(
                        onPressed: () async {
                          final Country? value = await CountryCodeSelector
                              .showCountryCodeSelectorBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            initialCountry: customBuilderValue,
                            favouriteCountries: const ['NG', 'GH', 'KE'],
                            // Puts the user's own country first.
                            pinUserCountry: true,
                            customBuilder: (context, data) =>
                                CustomCountrySheet(data: data),
                          );
                          if (value != null) {
                            setState(() => customBuilderValue = value);
                          }
                        },
                        child: ButtonRowWidget(country: customBuilderValue),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: ExpansionTile(
                  title: Text('Phone number field', style: _defaultTextStyle),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 5, 16, 15),
                      child: PhoneNumberField(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// common elevated child widget...
class ButtonRowWidget extends StatelessWidget {
  const ButtonRowWidget({super.key, this.country});

  final Country? country;

  @override
  Widget build(BuildContext context) {
    final Country? country = this.country;
    if (country == null) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CountryFlag(country: country),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            "${country.dialCode} ${country.name}",
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

/// A bottom sheet designed entirely by the app, using the data from
/// `customBuilder`: the filtered countries, the selection and its phone
/// number length, and the search/select/confirm/cancel callbacks.
class CustomCountrySheet extends StatelessWidget {
  const CustomCountrySheet({super.key, required this.data});

  final CountrySelectorData data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Country? selected = data.selected;
    final List<int>? lengths = data.selectedPhoneNumberLength;
    final bool searching = data.query.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Where are you calling from?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: data.cancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: data.search,
            decoration: InputDecoration(
              hintText: 'Country, code or +dial code',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (!searching && data.favourites.isNotEmpty) ...[
                _sectionLabel(context, 'Suggested'),
                for (final Country c in data.favourites) _tile(context, c),
                _sectionLabel(context, 'All countries'),
              ],
              for (final Country c in data.countries) _tile(context, c),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected == null
                        ? 'Pick a country'
                        : '${selected.name} (${selected.dialCode})'
                            '${lengths == null ? '' : ' · ${lengths.join(' or ')} digits'}',
                  ),
                ),
                FilledButton(
                  onPressed: selected == null ? null : data.confirm,
                  child: const Text('Use this'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  Widget _tile(BuildContext context, Country country) {
    final bool isSelected = country == data.selected;
    return ListTile(
      leading: CountryFlag(country: country, mode: FlagMode.round, height: 28),
      title: Text(country.name),
      subtitle: Text(country.dialCode),
      trailing: isSelected
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : null,
      selected: isSelected,
      onTap: () => data.select(country),
    );
  }
}

/// A phone number field with a country button as its prefix, validated with
/// `Country.isValidPhoneNumber` while the user types.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({super.key});

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _controller = TextEditingController();
  Country _country = CountryRepository.byCode('NG')!;

  bool get _isValid =>
      _country.isValidPhoneNumber(_controller.text, mobileOnly: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<int>? lengths = _country.phoneNumberLength;
    return TextFormField(
      key: _fieldKey,
      controller: _controller,
      keyboardType: TextInputType.phone,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Mobile number',
        // Once valid, show the E.164 form an app would send to its backend.
        helperText: _isValid
            ? 'Saved as ${_country.toE164(_controller.text)}'
            : lengths == null
                ? null
                : '${lengths.join(' or ')} digits after ${_country.dialCode}',
        prefixIcon: CountryCodeSelectorWidget(
          initialCountryCode: 'NG',
          favouriteCountries: const ['NG', 'GH', 'KE'],
          pinUserCountry: true,
          onChanged: (Country value) {
            setState(() => _country = value);
            // Re-check what was typed against the new country.
            _fieldKey.currentState?.validate();
          },
        ),
        suffixIcon: _isValid
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
      onChanged: (_) => setState(() {}),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        return _isValid ? null : 'Not a valid ${_country.name} mobile number';
      },
    );
  }
}
