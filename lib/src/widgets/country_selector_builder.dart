import 'package:flutter/material.dart';

import '../config/config.dart';
import '../models/models.dart';
import '../services/country_repository.dart';

/// Builds a fully custom country picker UI from [CountrySelectorData].
typedef CountrySelectorWidgetBuilder =
    Widget Function(BuildContext context, CountrySelectorData data);

/// Everything a custom country picker UI needs: the countries to show, the
/// current selection, and callbacks to search, select, confirm and cancel.
///
/// Passed to the builder of [CountrySelectorBuilder] and to `customBuilder`
/// of `CountryCodeSelector.showCountryCodeSelectorBottomSheet`. A new value is
/// passed on every change, so read it in `build` rather than storing it.
@immutable
class CountrySelectorData {
  /// Creates the data for a custom picker. Created by [CountrySelectorBuilder].
  const CountrySelectorData({
    required this.countries,
    required this.allCountries,
    required this.favourites,
    required this.selected,
    required this.query,
    required this.search,
    required this.select,
    required this.confirm,
    required this.cancel,
  });

  /// The countries matching [query], filtered, sorted and localized as
  /// configured. Equal to [allCountries] while the query is empty.
  final List<Country> countries;

  /// Every country in the list, ignoring [query].
  final List<Country> allCountries;

  /// The favourite countries, in the order they were given.
  final List<Country> favourites;

  /// The selected country, or null if none is selected yet.
  final Country? selected;

  /// The current search text.
  final String query;

  /// Filters [countries] by name, ISO code or dial code. Typically wired to
  /// a `TextField.onChanged`.
  final ValueChanged<String> search;

  /// Selects [country] without closing the picker, e.g. to highlight it
  /// before a confirm button is pressed.
  final ValueChanged<Country> select;

  /// Finishes with `country`, or with [selected] when called without one.
  /// In a bottom sheet this closes it and returns the country. Does nothing
  /// if neither is set.
  final void Function([Country? country]) confirm;

  /// Finishes without a selection. In a bottom sheet this closes it and
  /// returns null.
  final VoidCallback cancel;

  /// How many digits a mobile number of [selected] has after its dial code,
  /// without the national trunk prefix (see [Country.phoneNumberLength]),
  /// e.g. `[10]` for Nigeria. Null if nothing is selected or the lengths are
  /// unknown.
  List<int>? get selectedPhoneNumberLength => selected?.phoneNumberLength;
}

/// Manages the country list, search and selection for a custom picker UI,
/// and builds it with [builder].
///
/// Usable anywhere: in a bottom sheet (see
/// `CountryCodeSelector.showCountryCodeSelectorBottomSheet`), a dialog, or
/// inline on a page with [onConfirm] and [onCancel].
///
/// ```dart
/// CountrySelectorBuilder(
///   onConfirm: (Country country) => setState(() => _country = country),
///   builder: (BuildContext context, CountrySelectorData data) {
///     return Column(
///       children: <Widget>[
///         TextField(onChanged: data.search),
///         Expanded(
///           child: ListView(
///             children: <Widget>[
///               for (final Country country in data.countries)
///                 ListTile(
///                   leading: CountryFlag(country: country),
///                   title: Text(country.name),
///                   trailing: Text(country.dialCode),
///                   selected: country == data.selected,
///                   onTap: () => data.confirm(country),
///                 ),
///             ],
///           ),
///         ),
///       ],
///     );
///   },
/// );
/// ```
class CountrySelectorBuilder extends StatefulWidget {
  /// Creates a custom country picker.
  const CountrySelectorBuilder({
    super.key,
    required this.builder,
    this.countryListConfig,
    this.favouriteCountries,
    this.initialCountry,
    this.enableLocalization = true,
    this.onSelect,
    this.onConfirm,
    this.onCancel,
  });

  /// Builds the UI from the current [CountrySelectorData].
  final CountrySelectorWidgetBuilder builder;

  /// Which countries to offer, and in which order.
  final CountryListConfig? countryListConfig;

  /// ISO codes of the countries in [CountrySelectorData.favourites].
  final List<String>? favouriteCountries;

  /// The country selected at the start.
  final Country? initialCountry;

  /// Whether country names follow the app's locale. When false they stay in
  /// English.
  final bool enableLocalization;

  /// Called when [CountrySelectorData.select] changes the selection.
  final ValueChanged<Country>? onSelect;

  /// Called by [CountrySelectorData.confirm]. Defaults to popping the
  /// current route with the country.
  final ValueChanged<Country>? onConfirm;

  /// Called by [CountrySelectorData.cancel]. Defaults to popping the current
  /// route without a result.
  final VoidCallback? onCancel;

  @override
  State<CountrySelectorBuilder> createState() => _CountrySelectorBuilderState();
}

class _CountrySelectorBuilderState extends State<CountrySelectorBuilder> {
  List<Country> _all = <Country>[];
  List<Country> _favourites = <Country>[];
  List<Country> _results = <Country>[];
  Country? _selected;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve on locale changes so names and alphabetical order follow it.
    _all = CountryRepository.resolve(
      widget.countryListConfig,
      context: widget.enableLocalization ? context : null,
    );
    _favourites = CountryRepository.favourites(_all, widget.favouriteCountries);
    _results = CountryRepository.search(_all, _query);
    // Keep the selection pointing at the entry in the (re)localized list.
    final Country? current = _selected ?? widget.initialCountry;
    _selected =
        current == null
            ? null
            : _all.firstWhere(
              (Country c) => c == current,
              orElse: () => current,
            );
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _results = CountryRepository.search(_all, query);
    });
  }

  void _select(Country country) {
    setState(() => _selected = country);
    widget.onSelect?.call(country);
  }

  void _confirm([Country? country]) {
    final Country? result = country ?? _selected;
    if (result == null) {
      return;
    }
    if (country != null) {
      setState(() => _selected = country);
    }
    if (widget.onConfirm != null) {
      widget.onConfirm!(result);
    } else {
      Navigator.pop(context, result);
    }
  }

  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      CountrySelectorData(
        countries: _results,
        allCountries: _all,
        favourites: _favourites,
        selected: _selected,
        query: _query,
        search: _search,
        select: _select,
        confirm: _confirm,
        cancel: _cancel,
      ),
    );
  }
}
