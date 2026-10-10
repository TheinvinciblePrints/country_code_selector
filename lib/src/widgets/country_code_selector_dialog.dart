import 'package:flutter/material.dart';

import '../config/config.dart';
import '../models/models.dart';
import 'country_search_list.dart';

/// The content of the dialog shown by
/// `CountryCodeSelector.showCountryCodeSelectorDialog`. Pops the route with
/// the selected [Country].
class CountryCodeSelectorDialog extends StatelessWidget {
  /// Creates the dialog content.
  const CountryCodeSelectorDialog({
    super.key,
    this.showSearchBar,
    this.countryTilePadding,
    this.emptySearchBuilder,
    this.size,
    this.header,
    this.backgroundColor,
    this.borderRadius,
    this.layoutConfig = const LayoutConfig(),
    this.countryListConfig,
    this.favouriteCountries,
    this.searchStyle,
    this.closeIconWidget,
  });

  /// Customizes the search field.
  final SearchStyle? searchStyle;

  /// How each country row looks.
  final LayoutConfig? layoutConfig;

  /// Which countries to show, and in which order.
  final CountryListConfig? countryListConfig;

  /// ISO codes of countries pinned above the list while not searching.
  final List<String>? favouriteCountries;

  /// Replaces the default close button.
  final Widget? closeIconWidget;

  /// The size of the dialog. Defaults to 80% of the screen width and 72% of
  /// its height.
  final Size? size;

  /// The corner radius. Defaults to [CountrySelectorThemeData.borderRadius].
  final BorderRadiusGeometry? borderRadius;

  /// The background. Defaults to [CountrySelectorThemeData.backgroundColor].
  final Color? backgroundColor;

  /// Padding of each country row.
  final EdgeInsetsGeometry? countryTilePadding;

  /// Builds what is shown when a search has no results.
  final WidgetBuilder? emptySearchBuilder;

  /// Whether to show the search field. Defaults to true.
  final bool? showSearchBar;

  /// Replaces the default "Select country" header.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final CountrySelectorThemeData theme = CountrySelectorThemeData.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    return Container(
      width: size?.width ?? screen.width * 0.8,
      height: size?.height ?? screen.height * 0.72,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.backgroundColor,
        borderRadius:
            borderRadius ?? BorderRadius.circular(theme.borderRadius ?? 16),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: CountrySearchList(
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
        ),
      ),
    );
  }
}
