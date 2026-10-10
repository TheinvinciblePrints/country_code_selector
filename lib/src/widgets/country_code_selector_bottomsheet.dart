import 'package:flutter/material.dart';

import '../config/config.dart';
import '../models/models.dart';
import 'country_search_list.dart';

/// The content of the bottom sheet shown by
/// `CountryCodeSelector.showCountryCodeSelectorBottomSheet`. Pops the route
/// with the selected [Country].
class CountryCodeSelectorBottomSheet extends StatelessWidget {
  /// Creates the bottom sheet content.
  const CountryCodeSelectorBottomSheet({
    super.key,
    this.favouriteCountries,
    this.layoutConfig,
    this.countryListConfig,
    this.searchStyle,
    this.header,
    this.showSearchBar,
    this.countryTilePadding,
    this.emptySearchBuilder,
    this.closeIconWidget,
  });

  /// ISO codes of countries pinned above the list while not searching.
  final List<String>? favouriteCountries;

  /// How each country row looks.
  final LayoutConfig? layoutConfig;

  /// Which countries to show, and in which order.
  final CountryListConfig? countryListConfig;

  /// Customizes the search field.
  final SearchStyle? searchStyle;

  /// Replaces the default "Select country" header.
  final Widget? header;

  /// Whether to show the search field. Defaults to true.
  final bool? showSearchBar;

  /// Padding of each country row.
  final EdgeInsetsGeometry? countryTilePadding;

  /// Builds what is shown when a search has no results.
  final WidgetBuilder? emptySearchBuilder;

  /// Replaces the default close button.
  final Widget? closeIconWidget;

  @override
  Widget build(BuildContext context) {
    return CountrySearchList(
      onSelected: (Country country) => Navigator.pop(context, country),
      countryListConfig: countryListConfig,
      layoutConfig: layoutConfig ?? const LayoutConfig(),
      searchStyle: searchStyle,
      favouriteCountries: favouriteCountries,
      header: header,
      showSearchBar: showSearchBar ?? true,
      countryTilePadding: countryTilePadding,
      emptySearchBuilder: emptySearchBuilder,
      closeIconWidget: closeIconWidget,
    );
  }
}
