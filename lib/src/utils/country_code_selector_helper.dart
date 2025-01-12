import 'dart:convert';

import 'package:flutter/material.dart';

import '../../country_code_selector.dart';

/// A service class responsible for handling country data, including fetching
/// a list of countries and retrieving default or specific country information.
///
/// This class uses JSON data for countries, and provides methods to return
/// country objects localized to the user's device locale. It also integrates
/// additional features such as phone number length retrieval for each country.
class CountryCodeSelector {
  // Private constructor to prevent instantiation
  CountryCodeSelector._();

  /// Retrieves the list of countries by parsing the predefined JSON data.
  ///
  /// The method reads the JSON data from the constant string, parses it, and
  /// converts it into a list of `Country` objects.
  ///
  /// Returns a [Future] that resolves to a [List] of [Country] objects.
  static Future<List<Country>> getCountries() async {
    // JSON data is stored as a string in constants.
    const String rawData = StringConstants.countryJson;

    // Parse the string into a list of dynamic objects.
    final List<dynamic> parsed = json.decode(rawData) as List<dynamic>;

    // Map the dynamic objects to Country objects and return.
    return Future.wait(parsed.map((dynamic json) async {
      final Country country = Country.fromJson(json as Map<String, dynamic>);
      return CountryService.loadCountryWithPhoneNumberLength(country);
    }).toList());
  }

  /// Retrieves the default country based on the user's device locale.
  ///
  /// This method reads a predefined JSON dataset of country information and tries to
  /// match the device's current locale to a country by its ISO code. If a match is found,
  /// the country name is localized using the app's localization system. It also includes
  /// the phone number length for the country by calling [loadCountryWithPhoneNumberLength].
  ///
  /// If no matching country is found for the device's locale, the method throws an exception.
  /// If the device does not have a country code, it defaults to 'US'.
  ///
  /// Example usage:
  /// ```dart
  /// Country country = await getDefaultCountry(context: context);
  /// print(country.name); // Output: localized country name
  /// ```
  ///
  /// Returns a [Future] that resolves to a [Country] object with localized name and phone number length.
  ///
  /// Throws an [Exception] if no country is found for the locale.
  static Future<Country> getDefaultCountry(
      {required BuildContext context}) async {
    // Read the predefined JSON data from constants.
    const String rawData = StringConstants.countryJson;

    // Parse the JSON string into a list of dynamic country objects.
    final List<dynamic> countryList = json.decode(rawData) as List<dynamic>;

    // Retrieve the device's locale.
    final Locale deviceLocale = Localizations.localeOf(context);

    // Get the device's ISO country code or fallback to 'US' if not available.
    final String deviceIsoCode = deviceLocale.countryCode ?? 'US';

    // Find the country that corresponds to the device's ISO code in the dataset.
    final Map<String, dynamic> countryJson = countryList
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (Map<String, dynamic> country) =>
              country['code'].toString().toUpperCase() ==
              deviceIsoCode.toUpperCase(),
          orElse: () =>
              throw Exception('Country for locale $deviceIsoCode not found.'),
        );

    // Create a Country object from the JSON data.
    final Country country = Country.fromJson(countryJson);

    // Localize the country name using the current locale.
    final String localizedCountryName =
        CountryCodeSelectorLocalizations.of(context)?.translate(country.code) ??
            country.name;

    // Return the Country object with the localized name and phone number length.
    final Country localizedCountry =
        country.copyWith(name: localizedCountryName);
    return CountryService.loadCountryWithPhoneNumberLength(localizedCountry);
  }

  /// Retrieves a specific country by its ISO country code.
  ///
  /// This method takes in a [context] and [countryCode], and searches the predefined
  /// JSON dataset for a country that matches the provided country code. If found,
  /// the method localizes the country's name.
  ///
  /// [context] is required to access localization and other Flutter-specific resources.
  ///
  /// [countryCode] must be a valid ISO country code (e.g., 'US', 'GB').
  ///
  /// Returns a [Future] that resolves to a [Country] object or `null` if not found.
  static Future<Country> getCountryByCountryCode(
      {required BuildContext context, required String countryCode}) {
    try {
      // Find the country that matches the given country code.
      final Map<String, dynamic> countryJson =
          CountryService.countryList.cast<Map<String, dynamic>>().firstWhere(
                (Map<String, dynamic> country) =>
                    country['code'].toString().toUpperCase() ==
                    countryCode.toUpperCase(),
                orElse: () =>
                    throw Exception('Country with code $countryCode not found'),
              );

      // Create a Country object and localize the name.
      final Country country = Country.fromJson(countryJson);
      final String localizedCountryName =
          CountryCodeSelectorLocalizations.of(context)
                  ?.translate(country.code) ??
              country.name;

      // Return the country with the localized name.
      return CountryService.loadCountryWithPhoneNumberLength(
          country.copyWith(name: localizedCountryName));
    } catch (e) {
      // Return default if the country is not found.
      return getDefaultCountry(context: context);
    }
  }

  /// Displays a country code selector dialog.
  ///
  /// This function opens a customizable dialog that allows users to select a country code.
  /// It supports features like favorite countries, search functionality, and UI customization.
  ///
  /// Parameters:
  /// - [context]: The build context in which the dialog will be displayed.
  /// - [layoutConfig]: An optional configuration for the layout of the country selector.
  /// - [closeIconWidget]: A widget to display as the close icon in the dialog.
  /// - [countryListConfig]: Configuration for the country list, such as sorting or filtering.
  /// - [searchStyle]: Style customization for the search bar, including text styling.
  /// - [favouriteCountries]: A list of country codes to display at the top as favorites.
  /// - [isDismissible]: Determines whether the dialog can be dismissed by tapping outside. Defaults to `true`.
  /// - [backgroundColor]: The background color of the dialog.
  /// - [borderRadius]: The border radius for the dialog corners.
  /// - [useSafeArea]: Whether to use `SafeArea` for positioning the dialog. Defaults to `true`.
  /// - [alignment]: The alignment of the dialog relative to the screen.
  /// - [clipBehavior]: How the dialog content should be clipped. Defaults to `Clip.none`.
  /// - [insetPadding]: Padding applied around the dialog.
  /// - [shadowColor]: The color of the shadow behind the dialog.
  /// - [header]: An optional widget to display as a header inside the dialog.
  /// - [barrierColor]: The color of the barrier behind the dialog.
  /// - [countryTilePadding]: Padding applied to each country tile in the list.
  /// - [showSearchBar]: Determines whether the search bar is displayed.
  /// - [size]: Specifies the size of the dialog.
  /// - [emptySearchBuilder]: A builder function to display a widget when the search yields no results.
  ///
  /// Returns:
  /// - A `Future<Country?>` that resolves to the selected country or `null` if no selection is made.
  ///
  /// Example:
  /// ```dart
  /// Country? selectedCountry = await showCountryCodeSelectorDialog(
  ///   context: context,
  ///   favouriteCountries: ['US', 'MY'],
  ///   showSearchBar: true,
  ///   backgroundColor: Colors.white,
  /// );
  /// print(selectedCountry?.name);
  /// ```
  static Future<Country?> showCountryCodeSelectorDialog({
    required BuildContext context,
    LayoutConfig? layoutConfig,
    Widget? closeIconWidget,
    CountryListConfig? countryListConfig,
    SearchStyle? searchStyle,

    /// favourite countries will be placed on the top of list.
    List<String>? favouriteCountries,
    bool? isDismissible,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    bool? useSafeArea,
    AlignmentGeometry? alignment,
    Clip? clipBehavior,
    EdgeInsets? insetPadding,
    Color? shadowColor,
    Widget? header,
    Color? barrierColor,
    EdgeInsetsGeometry? countryTilePadding,
    bool? showSearchBar,
    Size? size,
    WidgetBuilder? emptySearchBuilder,
  }) async {
    return showDialog(
      useSafeArea: useSafeArea ?? true,
      barrierDismissible: isDismissible ?? true,
      barrierColor: barrierColor,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            shadowColor: shadowColor,
            insetPadding: insetPadding,
            clipBehavior: clipBehavior ?? Clip.none,
            alignment: alignment,
            child: CountryCodeSelectorDialog(
              searchStyle: searchStyle,
              favouriteCountries: favouriteCountries,
              countryListConfig: countryListConfig,
              closeIconWidget: closeIconWidget,
              layoutConfig: layoutConfig,
              borderRadius: borderRadius,
              backGroundColor:
                  backgroundColor ?? Theme.of(context).dialogBackgroundColor,
              countryTilePadding: countryTilePadding,
              emptySearchBuilder: emptySearchBuilder,
              showSearchBar: showSearchBar,
              size: size,
              header: header,
            ),
          ),
        );
      },
    );
  }

  static Future<Country?> showCountryCodeSelectorBottomSheet(
      {required BuildContext context,
      Color? backgroundColor,
      LayoutConfig? layoutConfig,
      List<String>? favouriteCountries,
      CountryListConfig? countryListConfig,
      SearchStyle? searchStyle,
      Widget? closeIconWidget,
      ShapeBorder? shape,
      Color? barrierColor,
      bool? useSafeArea,
      bool? isDismissible,
      Offset? anchorPoint,
      Clip? clipBehavior,
      bool? showSearchBar,
      BoxConstraints? constraints,
      bool? isScrollControlled,
      Text? header,
      String? barrierLabel,
      WidgetBuilder? emptySearchBuilder,
      double? elevation,
      bool? enableDrag,
      RouteSettings? routeSettings,
      EdgeInsetsGeometry? countryTilePadding,
      double? scrollControlDisabledMaxHeightRatio,
      bool? showDragHandle,
      AnimationController? transitionAnimationController,
      bool? useRootNavigator}) async {
    return showModalBottomSheet(
      backgroundColor:
          backgroundColor ?? Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: shape,
      barrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      useSafeArea: useSafeArea ?? false,
      isDismissible: isDismissible ?? true,
      anchorPoint: anchorPoint,
      constraints: constraints,
      clipBehavior:
          clipBehavior ?? Theme.of(context).bottomSheetTheme.clipBehavior,
      isScrollControlled: isScrollControlled ?? false,
      barrierLabel: barrierLabel,
      elevation: elevation ?? Theme.of(context).bottomSheetTheme.elevation,
      enableDrag: enableDrag ?? true,
      routeSettings: routeSettings,
      scrollControlDisabledMaxHeightRatio:
          scrollControlDisabledMaxHeightRatio ?? 9.0 / 16.0,
      showDragHandle: showDragHandle ?? false,
      transitionAnimationController: transitionAnimationController,
      useRootNavigator: useRootNavigator ?? false,
      context: context,
      builder: (_) {
        return CountryCodeSelectorBottomSheet(
          favouriteCountries: favouriteCountries,
          searchStyle: searchStyle,
          countryListConfig: countryListConfig,
          layoutConfig: layoutConfig,
          showSearchBar: showSearchBar,
          header: header,
          emptySearchBuilder: emptySearchBuilder,
          closeIconWidget: closeIconWidget,
          countryTilePadding: countryTilePadding,
        );
      },
    );
  }

  static Future<Country?> showCountryCodeSelectorCupertinoBottomSheet(
      {required BuildContext context,
      Country? setInitialValue,
      bool? isScrollControlled,
      BoxConstraints? constraints,
      ShapeBorder? shape,
      bool? isDismissible,
      Color? backgroundColor,
      Color? barrierColor,
      double? elevation,
      AnimationController? transitionAnimationController,
      Clip? clipBehavior,
      bool? useRootNavigator,
      bool? showDragHandle,
      bool? useSafeArea,
      double? heightOfPicker,
      Widget? selectionOverlay,
      double? magnification,
      bool? useMagnifier,
      double? squeeze,
      double? offAxisFraction,
      double? itemExtent,
      LayoutConfig? layoutConfig,
      CountryListConfig? countryListConfig,
      double? diameterRatio,
      EdgeInsets? countryTilePadding}) async {
    Country? countryData;
    await showModalBottomSheet<Country>(
      isScrollControlled: isScrollControlled ?? false,
      constraints: constraints,
      context: context,
      shape: shape,
      isDismissible: isDismissible ?? true,
      backgroundColor: backgroundColor ??
          Theme.of(context).bottomSheetTheme.modalBackgroundColor,
      barrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      elevation: elevation ?? Theme.of(context).bottomSheetTheme.modalElevation,
      transitionAnimationController: transitionAnimationController,
      clipBehavior: clipBehavior,
      useRootNavigator: useRootNavigator ?? false,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea ?? false,
      builder: (BuildContext context) {
        return CountryCodeSelectorCupertinoBottomSheet(
          diameterRatio: diameterRatio,
          onChanged: (Country value) {
            countryData = value;
          },
          setInitialValue: setInitialValue,
          useMagnifier: useMagnifier ?? true,
          countryTilePadding: countryTilePadding,
          heightOfPicker: heightOfPicker,
          selectionOverlayWidget: selectionOverlay,
          magnification: magnification ?? 1.0,
          squeeze: squeeze ?? 1.45,
          offAxisFraction: offAxisFraction ?? 0.0,
          itemExtent: itemExtent ?? 32,
          backgroundColor: backgroundColor ??
              Theme.of(context).bottomSheetTheme.modalBackgroundColor,
          layoutConfig: layoutConfig,
          countryListConfig: countryListConfig,
        );
      },
    );
    return countryData;
  }
}
