import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Colors and text styles for the country selectors.
///
/// Add it to your [ThemeData.extensions] to style every selector in the app,
/// with separate values for your light and dark themes:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const <ThemeExtension<dynamic>>[
///       CountrySelectorThemeData(backgroundColor: Colors.white),
///     ],
///   ),
///   darkTheme: ThemeData.dark().copyWith(
///     extensions: const <ThemeExtension<dynamic>>[
///       CountrySelectorThemeData(backgroundColor: Colors.black),
///     ],
///   ),
/// );
/// ```
///
/// Any value left null falls back to the app's [ThemeData], so the selectors
/// follow light and dark mode without configuration.
@immutable
class CountrySelectorThemeData
    extends ThemeExtension<CountrySelectorThemeData> {
  /// Creates a country selector theme.
  const CountrySelectorThemeData({
    this.backgroundColor,
    this.headerTextStyle,
    this.countryNameTextStyle,
    this.dialCodeTextStyle,
    this.searchTextStyle,
    this.searchHintTextStyle,
    this.searchBorderColor,
    this.dividerColor,
    this.borderRadius,
  });

  /// The background of the dialog, bottom sheets and dropdown menu.
  final Color? backgroundColor;

  /// The style of the default "Select country" header.
  final TextStyle? headerTextStyle;

  /// The style of country names.
  final TextStyle? countryNameTextStyle;

  /// The style of dial codes.
  final TextStyle? dialCodeTextStyle;

  /// The style of the text typed into the search field.
  final TextStyle? searchTextStyle;

  /// The style of the search field's hint.
  final TextStyle? searchHintTextStyle;

  /// The border color of the default search field.
  final Color? searchBorderColor;

  /// The color of the divider below the favourite countries.
  final Color? dividerColor;

  /// The corner radius of the dialog.
  final double? borderRadius;

  /// Returns the theme for [context], with every null value filled in from
  /// the app's [ThemeData].
  static CountrySelectorThemeData of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextTheme text = theme.textTheme;
    final CountrySelectorThemeData? custom =
        theme.extension<CountrySelectorThemeData>();
    return CountrySelectorThemeData(
      backgroundColor:
          custom?.backgroundColor ??
          theme.dialogTheme.backgroundColor ??
          colors.surfaceContainerHigh,
      headerTextStyle:
          custom?.headerTextStyle ??
          text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      countryNameTextStyle: custom?.countryNameTextStyle ?? text.bodyLarge,
      dialCodeTextStyle:
          custom?.dialCodeTextStyle ??
          text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
      searchTextStyle: custom?.searchTextStyle ?? text.bodyLarge,
      searchHintTextStyle:
          custom?.searchHintTextStyle ??
          text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
      searchBorderColor: custom?.searchBorderColor ?? colors.outlineVariant,
      dividerColor: custom?.dividerColor ?? colors.outlineVariant,
      borderRadius: custom?.borderRadius ?? 16,
    );
  }

  @override
  CountrySelectorThemeData copyWith({
    Color? backgroundColor,
    TextStyle? headerTextStyle,
    TextStyle? countryNameTextStyle,
    TextStyle? dialCodeTextStyle,
    TextStyle? searchTextStyle,
    TextStyle? searchHintTextStyle,
    Color? searchBorderColor,
    Color? dividerColor,
    double? borderRadius,
  }) {
    return CountrySelectorThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      countryNameTextStyle: countryNameTextStyle ?? this.countryNameTextStyle,
      dialCodeTextStyle: dialCodeTextStyle ?? this.dialCodeTextStyle,
      searchTextStyle: searchTextStyle ?? this.searchTextStyle,
      searchHintTextStyle: searchHintTextStyle ?? this.searchHintTextStyle,
      searchBorderColor: searchBorderColor ?? this.searchBorderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  CountrySelectorThemeData lerp(
    covariant CountrySelectorThemeData? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return CountrySelectorThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      headerTextStyle: TextStyle.lerp(
        headerTextStyle,
        other.headerTextStyle,
        t,
      ),
      countryNameTextStyle: TextStyle.lerp(
        countryNameTextStyle,
        other.countryNameTextStyle,
        t,
      ),
      dialCodeTextStyle: TextStyle.lerp(
        dialCodeTextStyle,
        other.dialCodeTextStyle,
        t,
      ),
      searchTextStyle: TextStyle.lerp(
        searchTextStyle,
        other.searchTextStyle,
        t,
      ),
      searchHintTextStyle: TextStyle.lerp(
        searchHintTextStyle,
        other.searchHintTextStyle,
        t,
      ),
      searchBorderColor: Color.lerp(
        searchBorderColor,
        other.searchBorderColor,
        t,
      ),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
    );
  }
}
