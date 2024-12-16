import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../country_code_selector.dart';

class CountryCodeSelectorCupertinoBottomSheet extends StatefulWidget {
  const CountryCodeSelectorCupertinoBottomSheet({
    super.key,
    this.heightOfPicker,
    this.itemExtent,
    this.selectionOverlayWidget,
    this.backgroundColor,
    this.offAxisFraction = 0.2,
    this.squeeze = 1.45,
    this.magnification = 1.0,
    this.useMagnifier = true,
    this.layoutConfig = const LayoutConfig(),
    this.countryListConfig,
    this.countryTilePadding,
    required this.onChanged,
    this.setInitialValue,
    this.diameterRatio,
  });

  final Country? setInitialValue;

  final EdgeInsets? countryTilePadding;

  final LayoutConfig? layoutConfig;

  final CountryListConfig? countryListConfig;

  final ValueChanged<Country> onChanged;

  final double? heightOfPicker;

  final double? itemExtent;

  final Widget? selectionOverlayWidget;

  final Color? backgroundColor;

  final double offAxisFraction;
  final double? diameterRatio;
  final double squeeze;
  final double magnification;
  final bool useMagnifier;

  @override
  State<CountryCodeSelectorCupertinoBottomSheet> createState() =>
      _CountryCodeSelectorCupertinoBottomSheetState();
}

class _CountryCodeSelectorCupertinoBottomSheetState
    extends State<CountryCodeSelectorCupertinoBottomSheet>
    with CountrySelectorMixin {
  Country? selectedItem;
  List<Country> countriesElements = <Country>[];
  int initialItem = 0;

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 14);

  double calculateTextWidth(double size) {
    const int defaultSize = 50;
    return size * defaultSize / _defaultTextStyle.fontSize!;
  }

  @override
  void initState() {
    super.initState();

    countriesElements = countryList
        .map((dynamic json) => Country.fromJson(json as Map<String, dynamic>))
        .toList();

    if (widget.countryListConfig?.comparator != null) {
      countriesElements.sort(widget.countryListConfig?.comparator);
    }

    if (widget.countryListConfig?.countryFilter != null &&
        widget.countryListConfig!.countryFilter!.isNotEmpty) {
      final List<String>? uppercaseFilterElement = widget
          .countryListConfig?.countryFilter
          ?.map((String e) => e.toUpperCase())
          .toList();
      countriesElements = countriesElements
          .where((Country element) =>
              uppercaseFilterElement!.contains(element.code))
          .toList();
      if (countriesElements.isEmpty) {
        throw Exception('Invalid country list');
      }
    }

    if ((widget.countryListConfig?.excludeCountry?.isNotEmpty ?? false) &&
        widget.countryListConfig?.excludeCountry != null) {
      for (int i = 0;
          i < (widget.countryListConfig?.excludeCountry?.length ?? 0);
          i++) {
        for (int j = 0; j < countriesElements.length; j++) {
          if (widget.countryListConfig?.excludeCountry?[i].toUpperCase() ==
              countriesElements[j].code) {
            countriesElements.removeAt(j);
            break;
          }
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    countriesElements = countriesElements
        .map((Country element) => element.localize(context))
        .toList();
    if (widget.setInitialValue != null) {
      for (int i = 0; i < countriesElements.length; i++) {
        if (widget.setInitialValue?.name == countriesElements[i].name) {
          initialItem = i;
        }
      }
    } else {
      initialItem = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: widget.heightOfPicker ?? 250,
          child: CupertinoPicker(
            diameterRatio: widget.diameterRatio ?? 1.07,
            selectionOverlay: widget.selectionOverlayWidget ??
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
            magnification: widget.magnification,
            useMagnifier: widget.useMagnifier,
            squeeze: widget.squeeze,
            offAxisFraction: widget.offAxisFraction,
            itemExtent: widget.itemExtent ?? 32,
            backgroundColor: widget.backgroundColor,
            onSelectedItemChanged: (int value) {
              setState(() {
                HapticFeedback.heavyImpact();
                widget.onChanged(countriesElements[value]);
              });
            },
            scrollController:
                FixedExtentScrollController(initialItem: initialItem),
            children: List<Widget>.generate(
              countriesElements.length,
              (int index) {
                if (widget.layoutConfig?.elementsOrder ==
                    DisplayOrder.flagCodeAndCountryName) {
                  return Padding(
                    padding: widget.countryTilePadding ??
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        if (widget.layoutConfig?.showCountryFlag ?? true)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              decoration: widget.layoutConfig?.flagDecoration,
                              clipBehavior:
                                  widget.layoutConfig?.flagDecoration == null
                                      ? Clip.none
                                      : Clip.hardEdge,
                              child: CountryFlag(
                                assetName: countriesElements[index].image,
                                flagWidth: widget.layoutConfig?.flagWidth,
                                flagHeight: widget.layoutConfig?.flagHeight,
                              ),
                            ),
                          ),
                        if (widget.layoutConfig?.showCountryCode ?? true)
                          SizedBox(
                            width: calculateTextWidth(
                                widget.layoutConfig?.textStyle?.fontSize ??
                                    _defaultTextStyle.fontSize!),
                            child: Text(
                              textAlign: TextAlign.start,
                              countriesElements[index].toString(),
                              overflow: TextOverflow.fade,
                              style: widget.layoutConfig?.textStyle ??
                                  _defaultTextStyle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.left,
                            " ${widget.layoutConfig?.showCountryName ?? true ? countriesElements[index].toCountryStringOnly() : ""}",
                            overflow: TextOverflow.fade,
                            style: widget.layoutConfig?.textStyle ??
                                _defaultTextStyle,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: widget.countryTilePadding ??
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        if (widget.layoutConfig?.showCountryCode ?? true)
                          SizedBox(
                            width: calculateTextWidth(
                                widget.layoutConfig?.textStyle?.fontSize ??
                                    _defaultTextStyle.fontSize!),
                            child: Text(
                              textAlign: TextAlign.start,
                              countriesElements[index].toString(),
                              overflow: TextOverflow.fade,
                              style: widget.layoutConfig?.textStyle ??
                                  _defaultTextStyle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.left,
                            " ${widget.layoutConfig?.showCountryName ?? true ? countriesElements[index].toCountryStringOnly() : ""}",
                            overflow: TextOverflow.fade,
                            style: widget.layoutConfig?.textStyle ??
                                _defaultTextStyle,
                          ),
                        ),
                        if (widget.layoutConfig?.showCountryFlag ?? true)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(left: 16.0),
                              decoration: widget.layoutConfig?.flagDecoration,
                              clipBehavior:
                                  widget.layoutConfig?.flagDecoration == null
                                      ? Clip.none
                                      : Clip.hardEdge,
                              child: CountryFlag(
                                assetName: countriesElements[index].image,
                                flagWidth: widget.layoutConfig?.flagWidth,
                                flagHeight: widget.layoutConfig?.flagHeight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
