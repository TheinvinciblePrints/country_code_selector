import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CountryFlag extends StatelessWidget {
  const CountryFlag(
      {super.key, required this.assetName, this.flagWidth, this.flagHeight});
  final String assetName;
  final double? flagWidth;
  final double? flagHeight;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      package: 'country_code_selector',
      width: flagWidth ?? 24,
      height: flagHeight ?? 18,
      fit: BoxFit.cover,
    );
  }
}
