import 'package:flutter/material.dart';

/// Configuration class for customizing the layout of the country selector widget.
///
/// This class provides various options for displaying country information
/// such as the flag, country name, and dialing code, as well as allowing
/// customization of styles and theming.
class LayoutConfig {
  /// Creates a layout configuration for the country selector widget.
  ///
  /// [flagHeight] and [flagWidth] define the dimensions of the country flag.
  /// [flagDecoration] allows applying decorations to the flag.
  /// [textStyle] defines the style for displaying text elements like the country name and code.
  /// [elementsOrder] controls the display order of the flag, country code, and name.
  /// [showCountryFlag], [showCountryName], and [showCountryCode] control the visibility of the corresponding elements.
  /// [flagMode] allows switching between round and square flags.
  /// [enableLocalization] enables localization support for country names.
  /// [sortingBehavior] allows customization of sorting for the country list.
  /// [themeMode] defines whether to use system-based theming, light mode, or dark mode.
  /// [lightTheme] and [darkTheme] provide theme configurations for light and dark modes.
  const LayoutConfig({
    this.flagHeight = 18,
    this.flagWidth = 24,
    this.flagDecoration,
    this.textStyle,
    this.elementsOrder = DisplayOrder.flagCodeAndCountryName,
    this.showCountryFlag = true,
    this.showCountryName = true,
    this.showCountryCode = true,
    this.flagMode = FlagMode.round, // Default flag mode to round
    this.enableLocalization = true,
    this.sortingBehavior = SortingBehavior.alphabetical,
    this.themeMode = ThemeMode.system, // Default theme based on system setting
    this.lightTheme,
    this.darkTheme,
  }) : assert(showCountryFlag || showCountryCode || showCountryName,
            'At least one element must be shown in the country list.');

  /// Defines the text style for displaying elements such as the country name and code.
  ///
  /// If null, the default style will be [TextStyle(fontSize: 14)].
  final TextStyle? textStyle;

  /// Defines the order in which the flag, dialing code, and country name are displayed.
  ///
  /// Possible orders are controlled by the [DisplayOrder] enum.
  final DisplayOrder elementsOrder;

  /// Specifies the width of the country flag.
  final double flagWidth;

  /// Specifies the height of the country flag.
  final double flagHeight;

  /// Allows applying decorations to the flag, such as border or shape customization.
  final Decoration? flagDecoration;

  /// Determines whether to show the country name in the list.
  final bool showCountryName;

  /// Determines whether to show the country flag in the list.
  final bool showCountryFlag;

  /// Determines whether to show the country dialing code in the list.
  final bool showCountryCode;

  /// Defines the display mode of the flag, either round or square.
  ///
  /// This is controlled by the [FlagMode] enum.
  final FlagMode flagMode;

  /// Enables localization support for country names.
  ///
  /// When enabled, country names are displayed in the appropriate language
  /// based on the user's locale.
  final bool enableLocalization;

  /// Controls the sorting behavior for the country list.
  ///
  /// The [SortingBehavior] enum provides different options such as
  /// alphabetical sorting or sorting by country code.
  final SortingBehavior sortingBehavior;

  /// Controls the theming of the widget.
  ///
  /// This allows the widget to switch between light and dark mode, or to follow the system's theme setting.
  final ThemeMode themeMode;

  /// Provides the theme configuration for light mode.
  ///
  /// If null, the default light theme will be used.
  final CountrySelectorThemeData? lightTheme;

  /// Provides the theme configuration for dark mode.
  ///
  /// If null, the default dark theme will be used.
  final CountrySelectorThemeData? darkTheme;
}

/// Enum to define the order in which elements (flag, code, name) are displayed.
///
/// It controls the sequence in which the country flag, dialing code, and
/// country name appear in the list.
enum DisplayOrder {
  flagCodeAndCountryName,
  codeFlagAndCountryName,
  nameCodeAndFlag,
}

/// Enum to define the display mode of the flag (square or round).
///
/// This controls whether the country flag is displayed in a round or square format.
enum FlagMode {
  round,
  square,
}

/// Enum to define the sorting behavior of the country list.
///
/// This allows the list to be sorted alphabetically, by country code, or
/// using a custom sorting method.
enum SortingBehavior {
  alphabetical,
  byCode,
  custom,
}

/// Theme data for customizing the appearance of the country selector widget.
///
/// This includes defining the background color and text color for both light
/// and dark themes.
class CountrySelectorThemeData {
  const CountrySelectorThemeData({
    required this.backgroundColor,
    required this.textColor,
  });

  /// The background color of the country selector widget.
  final Color backgroundColor;

  /// The text color used for displaying the country name and code.
  final Color textColor;
}
