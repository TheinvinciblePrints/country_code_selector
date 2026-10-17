import 'package:flutter/material.dart';

import '../../country_code_selector.dart';

/// Entry point for looking up countries and showing the country selectors.
class CountryCodeSelector {
  // Private constructor to prevent instantiation
  CountryCodeSelector._();

  /// Returns the country list described by [countryListConfig].
  ///
  /// Names are localized when [context] is given. See
  /// [CountryRepository.resolve].
  static List<Country> getCountries({
    BuildContext? context,
    CountryListConfig? countryListConfig,
  }) {
    return CountryRepository.resolve(countryListConfig, context: context);
  }

  /// Returns the user's country, with a localized name.
  ///
  /// Uses the region of the app's locale ([Localizations.localeOf]) if it has
  /// one, then the region of the device locale, and defaults to the US.
  ///
  /// Example usage:
  /// ```dart
  /// final Country country = CountryCodeSelector.getDefaultCountry(context: context);
  /// print(country.name); // Output: localized country name
  /// ```
  static Country getDefaultCountry({required BuildContext context}) {
    final Country country =
        CountryRepository.userCountry(context) ??
        CountryRepository.byCode('US')!;
    return country.localize(context);
  }

  /// Returns the country with the ISO [countryCode] (e.g. 'US', 'GB'), with a
  /// localized name.
  ///
  /// Falls back to [getDefaultCountry] if the code isn't in the dataset.
  static Country getCountryByCountryCode({
    required BuildContext context,
    required String countryCode,
  }) {
    final Country? country = CountryRepository.byCode(countryCode);
    return country?.localize(context) ?? getDefaultCountry(context: context);
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
  /// - [pinUserCountry]: Pins the user's country, detected from the app's or device's locale region, before the favourites. Defaults to `false`.
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
    bool pinUserCountry = false,
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
              pinUserCountry: pinUserCountry,
              countryListConfig: countryListConfig,
              closeIconWidget: closeIconWidget,
              layoutConfig: layoutConfig,
              borderRadius: borderRadius,
              backgroundColor: backgroundColor,
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

  /// Shows a searchable country list in a modal bottom sheet and returns the
  /// selected country, or `null` if the sheet is dismissed.
  ///
  /// The list options match [showCountryCodeSelectorDialog]; the remaining
  /// parameters are passed to [showModalBottomSheet]. For a full-height sheet
  /// pass `isScrollControlled: true` and `useSafeArea: true`.
  ///
  /// To design the sheet yourself, pass [customBuilder]: it receives a
  /// [CountrySelectorData] with the filtered countries, the selection (start
  /// it with [initialCountry]), its phone number lengths, and callbacks to
  /// search, select, confirm and cancel. The list styling parameters
  /// ([layoutConfig] apart from `enableLocalization`, [searchStyle],
  /// [header], [closeIconWidget], [countryTilePadding], [showSearchBar] and
  /// [emptySearchBuilder]) don't apply then.
  ///
  /// ```dart
  /// final Country? country =
  ///     await CountryCodeSelector.showCountryCodeSelectorBottomSheet(
  ///   context: context,
  ///   initialCountry: CountryRepository.byCode('NG'),
  ///   customBuilder: (BuildContext context, CountrySelectorData data) {
  ///     return ListView(
  ///       children: <Widget>[
  ///         for (final Country c in data.countries)
  ///           ListTile(
  ///             title: Text(c.name),
  ///             selected: c == data.selected,
  ///             onTap: () => data.confirm(c),
  ///           ),
  ///       ],
  ///     );
  ///   },
  /// );
  /// ```
  ///
  /// ```dart
  /// final Country? country =
  ///     await CountryCodeSelector.showCountryCodeSelectorBottomSheet(
  ///   context: context,
  ///   favouriteCountries: <String>['NG', 'GH'],
  /// );
  /// ```
  static Future<Country?> showCountryCodeSelectorBottomSheet({
    required BuildContext context,
    Color? backgroundColor,
    LayoutConfig? layoutConfig,
    List<String>? favouriteCountries,
    bool pinUserCountry = false,
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
    Widget? header,
    String? barrierLabel,
    WidgetBuilder? emptySearchBuilder,
    double? elevation,
    bool? enableDrag,
    RouteSettings? routeSettings,
    EdgeInsetsGeometry? countryTilePadding,
    double? scrollControlDisabledMaxHeightRatio,
    bool? showDragHandle,
    AnimationController? transitionAnimationController,
    bool? useRootNavigator,
    Country? initialCountry,
    CountrySelectorWidgetBuilder? customBuilder,
  }) async {
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
        if (customBuilder != null) {
          return CountrySelectorBuilder(
            builder: customBuilder,
            countryListConfig: countryListConfig,
            favouriteCountries: favouriteCountries,
            pinUserCountry: pinUserCountry,
            initialCountry: initialCountry,
            enableLocalization: layoutConfig?.enableLocalization ?? true,
          );
        }
        return CountryCodeSelectorBottomSheet(
          favouriteCountries: favouriteCountries,
          pinUserCountry: pinUserCountry,
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

  /// Shows an iOS-style wheel of countries in a modal bottom sheet.
  ///
  /// Returns the country confirmed with the OK button, or `null` if the sheet
  /// is dismissed. With `showDoneButton: false` there is no button, so
  /// dismissing returns the country under the selection. [setInitialValue] is selected
  /// when the sheet opens; the picker parameters are passed to
  /// `CupertinoPicker` and the rest to [showModalBottomSheet].
  ///
  /// ```dart
  /// final Country? country = await CountryCodeSelector
  ///     .showCountryCodeSelectorCupertinoBottomSheet(
  ///   context: context,
  ///   setInitialValue: CountryRepository.byCode('NG'),
  /// );
  /// ```
  static Future<Country?> showCountryCodeSelectorCupertinoBottomSheet({
    required BuildContext context,
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
    EdgeInsets? countryTilePadding,
    bool showDoneButton = true,
  }) async {
    Country? countryData;
    final Country? done = await showModalBottomSheet<Country>(
      isScrollControlled: isScrollControlled ?? false,
      constraints: constraints,
      context: context,
      shape: shape,
      isDismissible: isDismissible ?? true,
      backgroundColor:
          backgroundColor ??
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
          backgroundColor:
              backgroundColor ??
              Theme.of(context).bottomSheetTheme.modalBackgroundColor,
          layoutConfig: layoutConfig,
          countryListConfig: countryListConfig,
          showDoneButton: showDoneButton,
        );
      },
    );
    // Without a confirm button, closing the sheet is how the user confirms.
    return done ?? (showDoneButton ? null : countryData);
  }
}
