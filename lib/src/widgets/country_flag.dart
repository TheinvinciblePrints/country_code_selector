import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../config/layout_config.dart';
import '../models/models.dart';
import '../services/country_repository.dart';

/// Draws a country's flag.
///
/// Bundled countries use the package's SVG flags. A custom [Country] whose
/// [Country.image] is an asset of your app (`.svg` or any image format) is
/// loaded from your app's bundle. If the image is empty or fails to load, the
/// flag emoji is shown instead.
class CountryFlag extends StatelessWidget {
  /// Creates a flag for [country].
  const CountryFlag({
    super.key,
    required this.country,
    this.width = 24,
    this.height = 18,
    this.mode = FlagMode.square,
    this.decoration,
  });

  /// The country whose flag is drawn.
  final Country country;

  /// The width of a [FlagMode.square] flag.
  final double width;

  /// The height of the flag, and the diameter of a [FlagMode.round] flag.
  final double height;

  /// How the flag is drawn.
  final FlagMode mode;

  /// Painted over the flag, e.g. a border. The flag is clipped to it.
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    final double w = mode == FlagMode.square ? width : height;
    final Widget flag = switch (mode) {
      FlagMode.emoji => _emoji(),
      // Images keep their own aspect ratio unless the size is forced; clip
      // so BoxFit.cover crops them to the requested shape.
      FlagMode.round => ClipOval(
          child: SizedBox(width: w, height: height, child: _image(w)),
        ),
      FlagMode.square => ClipRect(
          child: SizedBox(width: w, height: height, child: _image(w)),
        ),
    };
    return ExcludeSemantics(
      child: decoration == null
          ? flag
          : Container(
              decoration: decoration,
              clipBehavior: Clip.antiAlias,
              child: flag,
            ),
    );
  }

  Widget _image(double w) {
    final String image = country.image;
    if (image.isEmpty) {
      return _emoji();
    }
    final bool bundled = CountryRepository.byCode(country.code)?.image == image;
    final String? package = bundled ? 'country_code_selector' : null;
    Widget fallback(BuildContext context, Object error, StackTrace? stack) =>
        _emoji();
    return image.toLowerCase().endsWith('.svg')
        ? SvgPicture.asset(
            image,
            package: package,
            width: w,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: fallback,
          )
        : Image.asset(
            image,
            package: package,
            width: w,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: fallback,
          );
  }

  Widget _emoji() {
    return SizedBox(
      width: mode == FlagMode.square ? width : height,
      height: height,
      child: FittedBox(
        child: Text(country.emoji, textScaler: TextScaler.noScaling),
      ),
    );
  }
}
