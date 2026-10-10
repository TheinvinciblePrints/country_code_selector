import 'package:flutter/material.dart';

import '../config/config.dart';
import '../models/models.dart';
import 'country_flag.dart';

/// A row showing a country's flag, dial code and name, as configured by
/// [layoutConfig].
///
/// Used by every selector; you can use it to build your own.
class CountryTile extends StatelessWidget {
  /// Creates a row for [country].
  const CountryTile({
    super.key,
    required this.country,
    this.layoutConfig = const LayoutConfig(),
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  /// The country to show.
  final Country country;

  /// Which elements to show, in which order, and how.
  final LayoutConfig layoutConfig;

  /// Padding around the row.
  final EdgeInsetsGeometry padding;

  /// Called when the row is tapped. The row isn't tappable when null.
  final VoidCallback? onTap;

  /// Space between the flag, dial code and name.
  static const double spacing = 12;

  @override
  Widget build(BuildContext context) {
    final CountrySelectorThemeData theme = CountrySelectorThemeData.of(context);
    final LayoutConfig config = layoutConfig;
    final TextStyle nameStyle =
        (theme.countryNameTextStyle ?? const TextStyle())
            .merge(config.textStyle);
    final TextStyle dialStyle =
        (theme.dialCodeTextStyle ?? const TextStyle()).merge(config.textStyle);

    final Widget? flag = config.showCountryFlag
        ? CountryFlag(
            country: country,
            width: config.flagWidth,
            height: config.flagHeight,
            mode: config.flagMode,
            decoration: config.flagDecoration,
          )
        : null;

    // A minimum width keeps names aligned between rows; it scales with the
    // font so long codes like +1264 still fit. Without a name there is
    // nothing to align, so the code takes only the space it needs.
    final double dialWidth = config.showCountryName
        ? MediaQuery.textScalerOf(context).scale(dialStyle.fontSize ?? 14) * 3.6
        : 0;
    final Widget? dialCode = config.showCountryCode
        ? ConstrainedBox(
            constraints: BoxConstraints(minWidth: dialWidth),
            child: Text(
              country.dialCode,
              style: dialStyle,
              maxLines: 1,
              // Keeps the + in front in right-to-left languages.
              textDirection: TextDirection.ltr,
              textAlign: Directionality.of(context) == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
            ),
          )
        : null;

    final Widget? name = config.showCountryName
        ? Expanded(
            child: Text(
              country.toCountryStringOnly(),
              style: nameStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : null;

    final List<Widget?> ordered = switch (config.elementsOrder) {
      DisplayOrder.flagCodeAndCountryName => <Widget?>[flag, dialCode, name],
      DisplayOrder.codeFlagAndCountryName => <Widget?>[dialCode, flag, name],
      DisplayOrder.nameCodeAndFlag => <Widget?>[name, dialCode, flag],
      DisplayOrder.codeCountryNameAndFlag => <Widget?>[dialCode, name, flag],
    };
    final List<Widget> visible = ordered.whereType<Widget>().toList();

    final Widget row = Padding(
      padding: padding,
      child: Row(
        // Without a name nothing expands, so the row can shrink to fit, e.g.
        // as a compact flag and dial code button.
        mainAxisSize:
            config.showCountryName ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < visible.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: spacing),
            visible[i],
          ],
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: <String>[
        if (config.showCountryName || !config.showCountryCode) country.name,
        if (config.showCountryCode) country.dialCode,
      ].join(', '),
      excludeSemantics: true,
      child: onTap == null ? row : InkWell(onTap: onTap, child: row),
    );
  }
}
