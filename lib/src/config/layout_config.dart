import 'package:flutter/material.dart';

/// Configuration class for customizing the layout of the country selector widget.
///
/// This class provides various options for displaying country information
/// such as the flag, country name, and dialing code. Colors and text styles
/// for the whole app are set with [CountrySelectorThemeData].
@immutable
class LayoutConfig {
  /// Creates a layout configuration for the country selector widget.
  ///
  /// [flagHeight] and [flagWidth] define the dimensions of the country flag.
  /// [flagDecoration] allows applying decorations to the flag.
  /// [textStyle] overrides the style of the country name and dial code.
  /// [elementsOrder] controls the display order of the flag, dial code, and name.
  /// [showCountryFlag], [showCountryName], and [showCountryCode] control the visibility of the corresponding elements.
  /// [flagMode] switches between square, round and emoji flags.
  /// [enableLocalization] enables localization support for country names.
  const LayoutConfig({
    this.flagHeight = 18,
    this.flagWidth = 24,
    this.flagDecoration,
    this.textStyle,
    this.elementsOrder = DisplayOrder.flagCodeAndCountryName,
    this.showCountryFlag = true,
    this.showCountryName = true,
    this.showCountryCode = true,
    this.flagMode = FlagMode.square,
    this.enableLocalization = true,
  }) : assert(showCountryFlag || showCountryCode || showCountryName,
            'At least one element must be shown in the country list.');

  /// Overrides the style of the country name and dial code.
  ///
  /// It is merged over [CountrySelectorThemeData.countryNameTextStyle] and
  /// [CountrySelectorThemeData.dialCodeTextStyle].
  final TextStyle? textStyle;

  /// Defines the order in which the flag, dialing code, and country name are displayed.
  ///
  /// Possible orders are controlled by the [DisplayOrder] enum.
  final DisplayOrder elementsOrder;

  /// Specifies the width of the country flag. Round and emoji flags use
  /// [flagHeight] for both dimensions.
  final double flagWidth;

  /// Specifies the height of the country flag.
  final double flagHeight;

  /// Allows applying decorations to the flag, such as a border.
  final Decoration? flagDecoration;

  /// Determines whether to show the country name in the list.
  final bool showCountryName;

  /// Determines whether to show the country flag in the list.
  final bool showCountryFlag;

  /// Determines whether to show the country dialing code (e.g. +234) in the list.
  final bool showCountryCode;

  /// How the flag is drawn. Defaults to [FlagMode.square].
  final FlagMode flagMode;

  /// Enables localization support for country names.
  ///
  /// When enabled (the default), country names are displayed in the language
  /// of the app's locale. When disabled, they stay in English. The selector's
  /// own text, like the header, is translated either way.
  final bool enableLocalization;
}

/// The order in which the flag, dial code and country name are displayed.
///
/// The order follows the reading direction, so in right-to-left languages the
/// first element is on the right.
enum DisplayOrder {
  /// Flag, dial code, name.
  flagCodeAndCountryName,

  /// Dial code, flag, name.
  codeFlagAndCountryName,

  /// Name, dial code, flag.
  nameCodeAndFlag,

  /// Dial code, name, flag.
  codeCountryNameAndFlag,
}

/// How a country flag is drawn.
enum FlagMode {
  /// A circle with the diameter of [LayoutConfig.flagHeight].
  round,

  /// A rectangle of [LayoutConfig.flagWidth] by [LayoutConfig.flagHeight].
  square,

  /// The flag emoji, sized to [LayoutConfig.flagHeight]. Needs no image
  /// assets, but its look depends on the platform's emoji font.
  emoji,
}

/// Customizes the search field of the dialog and bottom sheet.
@immutable
class SearchStyle {
  /// Creates a search field style.
  const SearchStyle({
    this.searchBoxMargin,
    this.searchFieldInputDecoration,
    this.searchTextStyle,
    this.hintText,
    this.searchBoxHeight,
    this.searchIcon,
  });

  /// Replaces the default decoration of the search field entirely.
  final InputDecoration? searchFieldInputDecoration;

  /// The style of the typed text. Overrides
  /// [CountrySelectorThemeData.searchTextStyle].
  final TextStyle? searchTextStyle;

  /// The hint shown in the empty search field. Defaults to the localized
  /// "Search".
  final String? hintText;

  /// The height of the search field. Defaults to 40.
  final double? searchBoxHeight;

  /// The icon at the start of the search field. Defaults to a search icon.
  final Widget? searchIcon;

  /// The margin around the search field.
  final EdgeInsetsGeometry? searchBoxMargin;
}
