import 'package:flutter/material.dart';

import '../config/config.dart';
import '../models/models.dart';
import '../services/country_repository.dart';
import 'country_tile.dart';

/// A [DropdownButton] of countries.
///
/// Pass [value] to control the selection from outside (update it in
/// [onSelectValue]); otherwise the dropdown keeps its own selection, starting
/// at [selectInitialCountry].
class CountryCodeSelectorDropDown extends StatefulWidget {
  /// Creates a country dropdown.
  const CountryCodeSelectorDropDown({
    super.key,
    this.value,
    this.iconSize = 24,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.menuMaxHeight,
    this.underline,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.icon,
    this.itemHeight = kMinInteractiveDimension,
    this.onTapDropdownMenuButton,
    this.backgroundColor,
    this.selectedItemBuilder,
    this.layoutConfig = const LayoutConfig(),
    this.countryListConfig,
    required this.onSelectValue,
    this.selectInitialCountry,
  });

  /// The selected country, when the parent controls the selection.
  final Country? value;

  /// The background of the menu. Defaults to
  /// [CountrySelectorThemeData.backgroundColor].
  final Color? backgroundColor;

  /// How each country row looks.
  final LayoutConfig? layoutConfig;

  /// Which countries to show, and in which order.
  final CountryListConfig? countryListConfig;

  /// See [DropdownButton.iconSize].
  final double iconSize;

  /// See [DropdownButton.borderRadius].
  final BorderRadius? borderRadius;

  /// See [DropdownButton.padding].
  final EdgeInsetsGeometry? padding;

  /// See [DropdownButton.menuMaxHeight].
  final double? menuMaxHeight;

  /// See [DropdownButton.iconDisabledColor].
  final Color? iconDisabledColor;

  /// See [DropdownButton.iconEnabledColor].
  final Color? iconEnabledColor;

  /// Builds the closed dropdown's display of the selected country. Defaults
  /// to the same row as the menu.
  final Widget Function(Country)? selectedItemBuilder;

  /// Called when the user selects a country, and once after the first frame
  /// with the initial country when [value] is null.
  final ValueChanged<Country> onSelectValue;

  /// See [DropdownButton.itemHeight].
  final double? itemHeight;

  /// Defaults to an [Icon] with the [Icons.arrow_drop_down].
  final Widget? icon;

  /// Defaults to a 0.0 width bottom border with color 0xFFBDBDBD.
  final Widget? underline;

  /// See [DropdownButton.onTap].
  final VoidCallback? onTap;

  /// See [DropdownMenuItem.onTap].
  final VoidCallback? onTapDropdownMenuButton;

  /// ISO code of the initially selected country when [value] is null.
  /// Defaults to the first country in the list.
  final String? selectInitialCountry;

  @override
  State<CountryCodeSelectorDropDown> createState() =>
      _CountryCodeDropdownState();
}

class _CountryCodeDropdownState extends State<CountryCodeSelectorDropDown> {
  List<Country> _countries = <Country>[];
  Country? _selected;

  LayoutConfig get _layout => widget.layoutConfig ?? const LayoutConfig();

  @override
  void initState() {
    super.initState();
    if (widget.value == null) {
      // Report the initial selection after the first frame so a parent
      // calling setState in onSelectValue doesn't trigger a
      // setState-during-build error.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selected != null) {
          widget.onSelectValue(_selected!);
        }
      });
    }
  }

  /// Returns the country matching [code], or the first country in the list.
  Country _findCountry(String? code) {
    final String? upperCode = code?.toUpperCase();
    return _countries.firstWhere(
      (Country element) => element.code.toUpperCase() == upperCode,
      orElse: () => _countries.first,
    );
  }

  /// The entry in the list for the selected country, so the dropdown can
  /// find it among its items and show it localized.
  Country get _shown => _findCountry(
    widget.value?.code ?? _selected?.code ?? widget.selectInitialCountry,
  );

  @override
  void didUpdateWidget(covariant CountryCodeSelectorDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectInitialCountry != widget.selectInitialCountry &&
        widget.selectInitialCountry != null) {
      _selected = _findCountry(widget.selectInitialCountry);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve on locale changes so names and alphabetical order follow it.
    _countries = CountryRepository.resolve(
      widget.countryListConfig,
      context: _layout.enableLocalization ? context : null,
    );
    _selected = _shown;
  }

  @override
  Widget build(BuildContext context) {
    final CountrySelectorThemeData theme = CountrySelectorThemeData.of(context);
    return DropdownButton<Country>(
      selectedItemBuilder:
          (BuildContext context) => <Widget>[
            for (final Country c in _countries)
              widget.selectedItemBuilder?.call(c) ??
                  CountryTile(country: c, layoutConfig: _layout),
          ],
      dropdownColor: widget.backgroundColor ?? theme.backgroundColor,
      iconSize: widget.iconSize,
      onTap: widget.onTap,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      menuMaxHeight: widget.menuMaxHeight,
      underline: widget.underline,
      style: _layout.textStyle,
      iconDisabledColor: widget.iconDisabledColor,
      iconEnabledColor: widget.iconEnabledColor,
      icon: widget.icon,
      itemHeight: widget.itemHeight,
      isExpanded: true,
      value: _shown,
      items: <DropdownMenuItem<Country>>[
        for (final Country c in _countries)
          DropdownMenuItem<Country>(
            onTap: widget.onTapDropdownMenuButton,
            value: c,
            child: CountryTile(country: c, layoutConfig: _layout),
          ),
      ],
      onChanged: (Country? value) {
        if (value == null) {
          return;
        }
        setState(() => _selected = value);
        widget.onSelectValue(value);
      },
    );
  }
}
