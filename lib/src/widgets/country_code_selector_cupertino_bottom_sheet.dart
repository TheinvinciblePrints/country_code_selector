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
    extends State<CountryCodeSelectorCupertinoBottomSheet> {
  List<Country> countriesElements = <Country>[];
  FixedExtentScrollController? _scrollController;
  Country? _current;

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 14);

  double calculateTextWidth(double size) {
    const int defaultSize = 50;
    return size * defaultSize / _defaultTextStyle.fontSize!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve on locale changes so names and alphabetical order follow it.
    countriesElements = CountryRepository.resolve(
      widget.countryListConfig,
      context: context,
    );
    final int index = _current == null && widget.setInitialValue == null
        ? 0
        : countriesElements.indexOf((_current ?? widget.setInitialValue)!);
    final int item = index < 0 ? 0 : index;

    if (_scrollController == null) {
      _scrollController = FixedExtentScrollController(initialItem: item);
      // Report the item shown on open, so closing without scrolling still
      // returns a country.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _select(item);
        }
      });
    } else {
      // The order may have changed; keep the same country selected.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController!.hasClients) {
          _scrollController!.jumpToItem(item);
        }
      });
    }
  }

  void _select(int index) {
    _current = countriesElements[index];
    widget.onChanged(_current!);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
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
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
            magnification: widget.magnification,
            useMagnifier: widget.useMagnifier,
            squeeze: widget.squeeze,
            offAxisFraction: widget.offAxisFraction,
            itemExtent: widget.itemExtent ?? 32,
            backgroundColor: widget.backgroundColor,
            onSelectedItemChanged: (int value) {
              HapticFeedback.heavyImpact();
              _select(value);
            },
            scrollController: _scrollController,
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
                              countriesElements[index].code,
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
                              countriesElements[index].code,
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
