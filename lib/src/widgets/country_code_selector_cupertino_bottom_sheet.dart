import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/config.dart';
import '../models/models.dart';
import '../services/country_repository.dart';
import 'country_tile.dart';

/// An iOS-style wheel picker of countries, shown by
/// `CountryCodeSelector.showCountryCodeSelectorCupertinoBottomSheet`.
class CountryCodeSelectorCupertinoBottomSheet extends StatefulWidget {
  /// Creates the wheel picker.
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
    this.showDoneButton = true,
    this.onDone,
  });

  /// The country selected when the picker opens. Defaults to the first one.
  final Country? setInitialValue;

  /// Padding of each country row.
  final EdgeInsets? countryTilePadding;

  /// How each country row looks.
  final LayoutConfig? layoutConfig;

  /// Which countries to show, and in which order.
  final CountryListConfig? countryListConfig;

  /// Called with the country under the selection overlay: once when the
  /// picker opens, then whenever it changes.
  final ValueChanged<Country> onChanged;

  /// The height of the wheel. Defaults to 250.
  final double? heightOfPicker;

  /// The height of each row. Defaults to 32.
  final double? itemExtent;

  /// Replaces the default highlight behind the selected row.
  final Widget? selectionOverlayWidget;

  /// The background of the wheel.
  final Color? backgroundColor;

  /// See [CupertinoPicker.offAxisFraction].
  final double offAxisFraction;

  /// See [CupertinoPicker.diameterRatio].
  final double? diameterRatio;

  /// See [CupertinoPicker.squeeze].
  final double squeeze;

  /// See [CupertinoPicker.magnification].
  final double magnification;

  /// See [CupertinoPicker.useMagnifier].
  final bool useMagnifier;

  /// Whether to show a confirm button above the wheel.
  final bool showDoneButton;

  /// Called with the selected country when the confirm button is pressed.
  /// Defaults to popping the route with it.
  final ValueChanged<Country>? onDone;

  @override
  State<CountryCodeSelectorCupertinoBottomSheet> createState() =>
      _CountryCodeSelectorCupertinoBottomSheetState();
}

class _CountryCodeSelectorCupertinoBottomSheetState
    extends State<CountryCodeSelectorCupertinoBottomSheet> {
  List<Country> _countries = <Country>[];
  FixedExtentScrollController? _scrollController;
  Country? _current;

  LayoutConfig get _layout => widget.layoutConfig ?? const LayoutConfig();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve on locale changes so names and alphabetical order follow it.
    _countries = CountryRepository.resolve(
      widget.countryListConfig,
      context: _layout.enableLocalization ? context : null,
    );
    final int index = _current == null && widget.setInitialValue == null
        ? 0
        : _countries.indexOf((_current ?? widget.setInitialValue)!);
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
    _current = _countries[index];
    widget.onChanged(_current!);
  }

  void _done() {
    final Country? current = _current;
    if (current == null) {
      return;
    }
    if (widget.onDone != null) {
      widget.onDone!(current);
    } else {
      Navigator.pop(context, current);
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.showDoneButton)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CupertinoButton(
                onPressed: _done,
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ),
          SizedBox(
            height: widget.heightOfPicker ?? 250,
            child: CupertinoPicker(
              diameterRatio: widget.diameterRatio ?? 1.07,
              selectionOverlay: widget.selectionOverlayWidget ??
                  const CupertinoPickerDefaultSelectionOverlay(),
              magnification: widget.magnification,
              useMagnifier: widget.useMagnifier,
              squeeze: widget.squeeze,
              offAxisFraction: widget.offAxisFraction,
              itemExtent: widget.itemExtent ?? 32,
              backgroundColor: widget.backgroundColor,
              onSelectedItemChanged: (int value) {
                HapticFeedback.selectionClick();
                _select(value);
              },
              scrollController: _scrollController,
              children: <Widget>[
                for (final Country country in _countries)
                  Center(
                    child: CountryTile(
                      country: country,
                      layoutConfig: _layout,
                      padding: widget.countryTilePadding ??
                          const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
