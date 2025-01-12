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
  void initState() {
    _getListOfCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          dividerColor: Colors.transparent,
          cardTheme: const CardTheme(color: Colors.white),
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

  void _getListOfCountries() async {
    final ab = await CountryCodeSelector.getCountries();

    debugPrint('CountryCodeSelector :: ${ab.length}');
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

  @override
  void didChangeDependencies() {
    Future.wait([
      CountryCodeSelector.getCountryByCountryCode(
          context: context, countryCode: "IN"),
      CountryCodeSelector.getCountryByCountryCode(
          context: context, countryCode: "ID"),
      CountryCodeSelector.getCountryByCountryCode(
          context: context, countryCode: "IN"),
      CountryCodeSelector.getCountryByCountryCode(
          context: context, countryCode: "IS"),
      CountryCodeSelector.getCountryByCountryCode(
          context: context, countryCode: "IN"),
      CountryCodeSelector.getCountryByCountryCode(
          context: context, countryCode: "UY"),
    ]).then((values) {
      initialDialogDefaultValue = values[0];
      initialDialogCustomValue = values[1];
      initialBottomDefaultValue = values[2];
      initialBottomCustomValue = values[3];
      initialCupertinoBottomDefaultValue = values[4];
      initialCupertinoBottomCustomValue = values[5];
      setState(() {});
    });
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
                                  child: ButtonRowWidget(
                                    dialCode: initialDialogDefaultValue
                                        ?.dialCodes.first,
                                    flagUri: initialDialogDefaultValue?.image,
                                    name: initialDialogDefaultValue?.name,
                                  ),
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
                                            flagDecoration: BoxDecoration(
                                                shape: BoxShape.circle)),
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
                                    child: ButtonRowWidget(
                                      dialCode: initialDialogCustomValue
                                          ?.dialCodes.first,
                                      flagUri: initialDialogCustomValue?.image,
                                      name: initialDialogCustomValue?.name,
                                    ),
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
                                    dialCode: initialBottomDefaultValue
                                        ?.dialCodes.first,
                                    flagUri: initialBottomDefaultValue?.image,
                                    name: initialBottomDefaultValue?.name,
                                  ),
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
                                        flagDecoration: BoxDecoration(
                                            shape: BoxShape.circle),
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
                                      name: initialBottomCustomValue?.name,
                                      flagUri: initialBottomCustomValue?.image,
                                      dialCode: initialBottomCustomValue
                                          ?.dialCodes.first,
                                    ),
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
                                    dialCode: initialCupertinoBottomDefaultValue
                                        ?.dialCodes.first,
                                    flagUri: initialCupertinoBottomDefaultValue
                                        ?.image,
                                    name: initialCupertinoBottomDefaultValue
                                        ?.name,
                                  ),
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
                                          flagDecoration: BoxDecoration(
                                              shape: BoxShape.circle),
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
                                      dialCode:
                                          initialCupertinoBottomCustomValue
                                              ?.dialCodes.first,
                                      flagUri: initialCupertinoBottomCustomValue
                                          ?.image,
                                      name: initialCupertinoBottomCustomValue
                                          ?.name,
                                    ),
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
                        width: MediaQuery.of(context).size.width * 0.32,
                        child: CountryCodeSelectorDropDown(
                          underline: const SizedBox.shrink(),
                          layoutConfig: const LayoutConfig(
                            showCountryName: true,
                            showCountryCode: true,
                            showCountryFlag: true,
                            flagDecoration:
                                BoxDecoration(shape: BoxShape.circle),
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
            ],
          ),
        ),
      ),
    );
  }
}

// common elevated child widget...
class ButtonRowWidget extends StatelessWidget {
  const ButtonRowWidget({
    super.key,
    this.flagUri,
    this.dialCode,
    this.name,
  });

  final String? flagUri;
  final String? dialCode;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CountryFlag(
          assetName: flagUri != null ? flagUri! : '',
          flagWidth: 24,
          flagHeight: 18,
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Text(
            "${dialCode ?? ""} ${name ?? ""}",
            overflow: TextOverflow.visible,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
