import 'package:flutter/material.dart';

import '../../country_code_selector.dart';

class CountryCodeSelectorDropDown extends StatefulWidget {
  const CountryCodeSelectorDropDown({
    super.key,
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
    this.backGroundColor,
    this.selectedItemBuilder,
    this.layoutConfig = const LayoutConfig(),
    this.countryListConfig,
    required this.onSelectValue,
    this.selectInitialCountry,
  });

  final Color? backGroundColor;
  final LayoutConfig? layoutConfig;
  final CountryListConfig? countryListConfig;
  final double iconSize;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? menuMaxHeight;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;

  /// Selected country widget builder to display. See [selectedItemBuilder] of [DropdownButton]
  final Widget Function(Country)? selectedItemBuilder;

  ///here this [onSelectValue] get the selected country value.
  final ValueChanged<Country> onSelectValue;

  /// See [itemHeight] of [DropdownButton], by default its accept from [kMinInteractiveDimension]
  final double? itemHeight;

  /// Defaults to an [Icon] with the [Icons.arrow_drop_down].
  final Widget? icon;

  /// Defaults to a 0.0 width bottom border with color 0xFFBDBDBD.
  final Widget? underline;

  /// See [onTap] of [DropdownButton]
  final VoidCallback? onTap;

  /// See [onTap] of [DropdownMenuItemButton]
  final VoidCallback? onTapDropdownMenuButton;

  /// set your initial Country
  final String? selectInitialCountry;

  @override
  State<CountryCodeSelectorDropDown> createState() =>
      _CountryCodeDropdownState();
}

class _CountryCodeDropdownState extends State<CountryCodeSelectorDropDown> {
  List<Country> countriesElements = <Country>[];
  List<DropdownMenuItem<Country>> items = <DropdownMenuItem<Country>>[];
  Country? selectedItem;

  TextStyle get _defaultTextStyle => const TextStyle(
        fontSize: 14,
      );

  double calculateSize(double size) {
    const int defaultSize = 80;
    return size * defaultSize / _defaultTextStyle.fontSize!;
  }

  @override
  void initState() {
    super.initState();

    // Report the initial selection after the first frame so a parent calling
    // setState in onSelectValue doesn't trigger a setState-during-build error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && selectedItem != null) {
        widget.onSelectValue(selectedItem!);
      }
    });
  }

  /// Returns the country matching [code], or the first country in the list.
  Country _findCountry(String? code) {
    final String? upperCode = code?.toUpperCase();
    return countriesElements.firstWhere(
      (Country element) => element.code.toUpperCase() == upperCode,
      orElse: () => countriesElements.first,
    );
  }

  @override
  void didUpdateWidget(covariant CountryCodeSelectorDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectInitialCountry != widget.selectInitialCountry &&
        widget.selectInitialCountry != null) {
      selectedItem = _findCountry(widget.selectInitialCountry);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve on locale changes so names and alphabetical order follow it.
    countriesElements = CountryRepository.resolve(
      widget.countryListConfig,
      context: context,
    );
    selectedItem =
        _findCountry(selectedItem?.code ?? widget.selectInitialCountry);
  }

  @override
  Widget build(BuildContext context) {
    items = countriesElements.map<DropdownMenuItem<Country>>((Country e) {
      return DropdownMenuItem<Country>(
          alignment: Alignment.center,
          onTap: widget.onTapDropdownMenuButton,
          value: e,
          child: (widget.layoutConfig?.elementsOrder ==
                  DisplayOrder.flagCodeAndCountryName)
              ? Row(
                  children: <Widget>[
                    if (widget.layoutConfig!.showCountryFlag)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(right: 14),
                          decoration: widget.layoutConfig?.flagDecoration,
                          clipBehavior:
                              widget.layoutConfig?.flagDecoration == null
                                  ? Clip.none
                                  : Clip.hardEdge,
                          child: CountryFlag(
                            assetName: e.image,
                            flagWidth: widget.layoutConfig?.flagWidth,
                            flagHeight: widget.layoutConfig?.flagHeight,
                          ),
                        ),
                      ),
                    if (widget.layoutConfig!.showCountryCode)
                      Flexible(
                        child: SizedBox(
                          width: calculateSize(
                              widget.layoutConfig?.textStyle?.fontSize ??
                                  Theme.of(context)
                                      .dropdownMenuTheme
                                      .textStyle
                                      ?.fontSize ??
                                  _defaultTextStyle.fontSize!),
                          child: Text(
                            e.code,
                            style: widget.layoutConfig?.textStyle ??
                                Theme.of(context).dropdownMenuTheme.textStyle ??
                                _defaultTextStyle,
                          ),
                        ),
                      ),
                    if (widget.layoutConfig!.showCountryName)
                      Expanded(
                        child: Text(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.left,
                          e.toCountryStringOnly(),
                          style: widget.layoutConfig?.textStyle ??
                              Theme.of(context).dropdownMenuTheme.textStyle ??
                              _defaultTextStyle,
                        ),
                      ),
                  ],
                )
              : Row(
                  mainAxisAlignment:
                      (widget.layoutConfig?.showCountryName == false)
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.start,
                  children: <Widget>[
                    if (widget.layoutConfig!.showCountryCode)
                      Flexible(
                        child: SizedBox(
                          width: calculateSize(
                              widget.layoutConfig?.textStyle?.fontSize ??
                                  Theme.of(context)
                                      .dropdownMenuTheme
                                      .textStyle
                                      ?.fontSize ??
                                  _defaultTextStyle.fontSize!),
                          child: Text(e.code,
                              style: widget.layoutConfig?.textStyle ??
                                  Theme.of(context)
                                      .dropdownMenuTheme
                                      .textStyle ??
                                  _defaultTextStyle),
                        ),
                      ),
                    if (widget.layoutConfig!.showCountryName)
                      Expanded(
                        child: Text(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.left,
                          e.toCountryStringOnly(),
                          overflow: TextOverflow.fade,
                          style: widget.layoutConfig?.textStyle ??
                              Theme.of(context).dropdownMenuTheme.textStyle ??
                              _defaultTextStyle,
                        ),
                      ),
                    if (widget.layoutConfig!.showCountryFlag)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(left: 14.0),
                          decoration: widget.layoutConfig?.flagDecoration,
                          clipBehavior:
                              widget.layoutConfig?.flagDecoration == null
                                  ? Clip.none
                                  : Clip.hardEdge,
                          child: CountryFlag(
                            assetName: e.image,
                            flagWidth: widget.layoutConfig?.flagWidth,
                            flagHeight: widget.layoutConfig?.flagHeight,
                          ),
                        ),
                      ),
                  ],
                ));
    }).toList();
    return DropdownButton<Country>(
      selectedItemBuilder: widget.selectedItemBuilder != null
          ? (BuildContext context) {
              return countriesElements
                  .map((Country c) => widget.selectedItemBuilder!(c))
                  .toList();
            }
          : null,
      dropdownColor: widget.backGroundColor,
      alignment: Alignment.bottomRight,
      iconSize: widget.iconSize,
      onTap: widget.onTap,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      menuMaxHeight: widget.menuMaxHeight,
      underline: widget.underline,
      style: widget.layoutConfig?.textStyle,
      iconDisabledColor: widget.iconDisabledColor,
      iconEnabledColor: widget.iconEnabledColor,
      icon: widget.icon,
      itemHeight: widget.itemHeight,
      isExpanded: true,
      value: selectedItem,
      items: items,
      onChanged: (Country? value) {
        setState(
          () {
            selectedItem = value;
            widget.onSelectValue(selectedItem!);
          },
        );
      },
    );
  }
}
