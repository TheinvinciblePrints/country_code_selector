import 'package:flutter/material.dart';

import '../config/config.dart';
import '../models/models.dart';
import '../services/country_repository.dart';
import '../utils/country_code_selector_helper.dart';
import 'country_tile.dart';

/// Which picker [CountryCodeSelectorWidget] opens.
enum CountryPickerType {
  /// A searchable dialog.
  dialog,

  /// A searchable bottom sheet.
  bottomSheet,

  /// An iOS-style wheel in a bottom sheet.
  cupertino,
}

/// A button showing the selected country (by default its flag and dial code)
/// that opens a country picker when tapped. Useful as the prefix of a phone
/// number field:
///
/// ```dart
/// TextField(
///   keyboardType: TextInputType.phone,
///   decoration: InputDecoration(
///     prefixIcon: CountryCodeSelectorWidget(
///       onChanged: (Country country) => setState(() => _country = country),
///     ),
///   ),
/// );
/// ```
///
/// Pass [value] to control the selection from outside; otherwise the widget
/// keeps its own, starting at [initialCountryCode] or the user's country.
class CountryCodeSelectorWidget extends StatefulWidget {
  /// Creates a country selector button.
  const CountryCodeSelectorWidget({
    super.key,
    this.value,
    this.initialCountryCode,
    this.onChanged,
    this.pickerType = CountryPickerType.bottomSheet,
    this.layoutConfig = const LayoutConfig(showCountryName: false),
    this.pickerLayoutConfig,
    this.countryListConfig,
    this.searchStyle,
    this.favouriteCountries,
    this.builder,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.enabled = true,
  });

  /// The selected country, when the parent controls the selection.
  final Country? value;

  /// ISO code of the initially selected country when [value] is null.
  /// Defaults to the user's country (see
  /// [CountryCodeSelector.getDefaultCountry]).
  final String? initialCountryCode;

  /// Called when the user picks a country.
  final ValueChanged<Country>? onChanged;

  /// Which picker opens on tap.
  final CountryPickerType pickerType;

  /// How the button shows the selected country. Defaults to flag and dial
  /// code.
  final LayoutConfig layoutConfig;

  /// How rows look in the picker. Defaults to `const LayoutConfig()`.
  final LayoutConfig? pickerLayoutConfig;

  /// Which countries the picker offers, and in which order.
  final CountryListConfig? countryListConfig;

  /// Customizes the picker's search field.
  final SearchStyle? searchStyle;

  /// ISO codes of countries pinned at the top of the picker.
  final List<String>? favouriteCountries;

  /// Replaces the button's content.
  final Widget Function(BuildContext context, Country country)? builder;

  /// Padding inside the button.
  final EdgeInsetsGeometry padding;

  /// Whether tapping opens the picker.
  final bool enabled;

  @override
  State<CountryCodeSelectorWidget> createState() =>
      _CountryCodeSelectorWidgetState();
}

class _CountryCodeSelectorWidgetState extends State<CountryCodeSelectorWidget> {
  Country? _selected;

  Country get _country => widget.value ?? _selected!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start from the English entry so a locale change re-translates it; a
    // custom country not in the bundled data is kept as is.
    final Country? current =
        _selected == null
            ? (widget.initialCountryCode == null
                ? null
                : CountryRepository.byCode(widget.initialCountryCode!))
            : CountryRepository.byCode(_selected!.code) ?? _selected;
    final Country base =
        current ??
        CountryRepository.byCode(
          CountryCodeSelector.getDefaultCountry(context: context).code,
        )!;
    _selected =
        widget.layoutConfig.enableLocalization ? base.localize(context) : base;
  }

  Future<void> _open() async {
    final LayoutConfig layout =
        widget.pickerLayoutConfig ?? const LayoutConfig();
    final Future<Country?> picker = switch (widget.pickerType) {
      CountryPickerType.dialog =>
        CountryCodeSelector.showCountryCodeSelectorDialog(
          context: context,
          layoutConfig: layout,
          countryListConfig: widget.countryListConfig,
          searchStyle: widget.searchStyle,
          favouriteCountries: widget.favouriteCountries,
        ),
      CountryPickerType.bottomSheet =>
        CountryCodeSelector.showCountryCodeSelectorBottomSheet(
          context: context,
          layoutConfig: layout,
          countryListConfig: widget.countryListConfig,
          searchStyle: widget.searchStyle,
          favouriteCountries: widget.favouriteCountries,
          isScrollControlled: true,
          useSafeArea: true,
        ),
      CountryPickerType.cupertino =>
        CountryCodeSelector.showCountryCodeSelectorCupertinoBottomSheet(
          context: context,
          layoutConfig: layout,
          countryListConfig: widget.countryListConfig,
          setInitialValue: _country,
        ),
    };
    final Country? picked = await picker;
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _selected = picked);
    widget.onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final Country country = _country;
    return InkWell(
      onTap: widget.enabled ? _open : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: widget.padding,
        child:
            widget.builder?.call(context, country) ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: CountryTile(
                    country: country,
                    layoutConfig: widget.layoutConfig,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
      ),
    );
  }
}
