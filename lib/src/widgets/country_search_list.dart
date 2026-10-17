import 'package:flutter/material.dart';

import '../config/config.dart';
import '../data/ui_strings.dart';
import '../models/models.dart';
import '../services/country_repository.dart';
import '../utils/country_code_selector_localizations.dart';
import 'country_tile.dart';

/// The header, search field and country list shared by the dialog and the
/// bottom sheet.
class CountrySearchList extends StatefulWidget {
  /// Creates the shared country list.
  const CountrySearchList({
    super.key,
    required this.onSelected,
    this.countryListConfig,
    this.layoutConfig = const LayoutConfig(),
    this.searchStyle,
    this.favouriteCountries,
    this.pinUserCountry = false,
    this.header,
    this.showSearchBar = true,
    this.countryTilePadding,
    this.emptySearchBuilder,
    this.closeIconWidget,
  });

  /// Called with the tapped country.
  final ValueChanged<Country> onSelected;

  /// Which countries to show, and in which order.
  final CountryListConfig? countryListConfig;

  /// How each country row looks.
  final LayoutConfig layoutConfig;

  /// Customizes the search field.
  final SearchStyle? searchStyle;

  /// ISO codes of countries pinned above the list while not searching.
  final List<String>? favouriteCountries;

  /// Whether to pin the user's country first among the favourites, detected
  /// from the region of the app's or device's locale. Nothing is pinned when
  /// no region is set, or when the country is filtered out. Defaults to false.
  final bool pinUserCountry;

  /// Replaces the default "Select country" header.
  final Widget? header;

  /// Whether to show the search field.
  final bool showSearchBar;

  /// Padding of each country row.
  final EdgeInsetsGeometry? countryTilePadding;

  /// Builds what is shown when a search has no results.
  final WidgetBuilder? emptySearchBuilder;

  /// Replaces the default close button.
  final Widget? closeIconWidget;

  @override
  State<CountrySearchList> createState() => _CountrySearchListState();
}

class _CountrySearchListState extends State<CountrySearchList> {
  List<Country> _countries = <Country>[];
  List<Country> _favourites = <Country>[];
  List<Country> _results = <Country>[];
  String _query = '';

  static const EdgeInsetsGeometry _defaultTilePadding =
      EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve on locale changes so names and alphabetical order follow it.
    _countries = CountryRepository.resolve(
      widget.countryListConfig,
      context: widget.layoutConfig.enableLocalization ? context : null,
    );
    _favourites = CountryRepository.favourites(
      _countries,
      widget.favouriteCountries,
      first:
          widget.pinUserCountry
              ? CountryRepository.userCountry(context)?.code
              : null,
    );
    _results = CountryRepository.search(_countries, _query);
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _results = CountryRepository.search(_countries, query);
    });
  }

  String _uiString(String key) => CountryCodeSelectorLocalizations.uiString(
    Localizations.maybeLocaleOf(context) ?? const Locale('en'),
    key,
  );

  @override
  Widget build(BuildContext context) {
    final CountrySelectorThemeData theme = CountrySelectorThemeData.of(context);
    final bool showFavourites = _query.trim().isEmpty && _favourites.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildHeader(theme),
        if (widget.showSearchBar) _buildSearchField(theme),
        Flexible(
          child: CustomScrollView(
            slivers: <Widget>[
              if (showFavourites) ...<Widget>[
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8),
                  sliver: SliverList.builder(
                    itemCount: _favourites.length,
                    itemBuilder:
                        (BuildContext context, int index) =>
                            _buildTile(_favourites[index]),
                  ),
                ),
                SliverToBoxAdapter(child: Divider(color: theme.dividerColor)),
              ],
              if (_results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      widget.emptySearchBuilder?.call(context) ??
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _uiString(kNoCountryFoundKey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                )
              else
                SliverList.builder(
                  itemCount: _results.length,
                  itemBuilder:
                      (BuildContext context, int index) =>
                          _buildTile(_results[index]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(CountrySelectorThemeData theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 20, end: 4, top: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child:
                widget.header ??
                Text(
                  _uiString(kSelectCountryKey),
                  style: theme.headerTextStyle,
                ),
          ),
          widget.closeIconWidget ??
              IconButton(
                iconSize: 20,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.close),
              ),
        ],
      ),
    );
  }

  Widget _buildSearchField(CountrySelectorThemeData theme) {
    final SearchStyle? style = widget.searchStyle;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: theme.searchBorderColor!),
    );
    return Container(
      margin:
          style?.searchBoxMargin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: style?.searchBoxHeight ?? 40,
      child: TextField(
        style: style?.searchTextStyle ?? theme.searchTextStyle,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        onChanged: _search,
        decoration:
            style?.searchFieldInputDecoration ??
            InputDecoration(
              isCollapsed: true,
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              prefixIcon: style?.searchIcon ?? const Icon(Icons.search),
              hintText:
                  style?.hintText ??
                  MaterialLocalizations.of(context).searchFieldLabel,
              hintStyle: theme.searchHintTextStyle,
            ),
      ),
    );
  }

  Widget _buildTile(Country country) {
    return CountryTile(
      country: country,
      layoutConfig: widget.layoutConfig,
      padding: widget.countryTilePadding ?? _defaultTilePadding,
      onTap: () => widget.onSelected(country),
    );
  }
}
