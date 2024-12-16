import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../country_code_selector.dart';
import 'country_flag.dart';

class CountryCodeSelectorDialog extends StatefulWidget {
  const CountryCodeSelectorDialog({
    super.key,
    this.showSearchBar,
    this.countryTilePadding,
    this.emptySearchBuilder,
    this.size,
    this.header,
    this.backGroundColor,
    this.borderRadius,
    this.listOfCountries,
    this.layoutConfig = const LayoutConfig(),
    this.countryListConfig,
    this.favouriteCountries,
    this.searchStyle,
    this.closeIconWidget,
  });

  /// it is optional argument to set your own custom country list
  final List<Map<String, dynamic>>? listOfCountries;
  final SearchStyle? searchStyle;
  final LayoutConfig? layoutConfig;
  final CountryListConfig? countryListConfig;

  /// add your favorites countries
  final List<String>? favouriteCountries;
  final Widget? closeIconWidget;

  /// size property is used to resize the dialog dimension
  final Size? size;
  final BorderRadiusGeometry? borderRadius;
  final Color? backGroundColor;
  final EdgeInsetsGeometry? countryTilePadding;
  final WidgetBuilder? emptySearchBuilder;
  final bool? showSearchBar;
  final Widget? header;

  @override
  State<CountryCodeSelectorDialog> createState() =>
      _CountryCodeSelectorDialogState();
}

class _CountryCodeSelectorDialogState extends State<CountryCodeSelectorDialog>
    with CountrySelectorMixin {
  List<Country> countriesElements = <Country>[];
  List<Country> favoriteCountries = <Country>[];
  List<Country> filteredElements = <Country>[];

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 14);

  @override
  void initState() {
    super.initState();

    if (widget.listOfCountries == null ||
        (widget.listOfCountries?.isEmpty ?? false)) {
      countriesElements = countryList
          .map((dynamic json) => Country.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      countriesElements = widget.listOfCountries!
          .map((Map<String, dynamic> element) => Country.fromJson(element))
          .toList();
    }

    if (widget.countryListConfig?.comparator != null) {
      countriesElements.sort(widget.countryListConfig?.comparator);
    }

    if (widget.countryListConfig?.countryFilter != null &&
        widget.countryListConfig!.countryFilter!.isNotEmpty) {
      final List<String>? uppercaseFilterElement = widget
          .countryListConfig?.countryFilter
          ?.map((String e) => e.toUpperCase())
          .toList();
      countriesElements = countriesElements
          .where((Country element) =>
              uppercaseFilterElement!.contains(element.code))
          .toList();
      if (countriesElements.isEmpty) {
        throw Exception('Invalid country list');
      }
    }
    filteredElements = countriesElements;
    if (widget.countryListConfig?.excludeCountry != null &&
        widget.countryListConfig!.excludeCountry!.isNotEmpty) {
      for (int i = 0;
          i < (widget.countryListConfig?.excludeCountry?.length ?? 0);
          i++) {
        for (int j = 0; j < countriesElements.length; j++) {
          if (widget.countryListConfig?.excludeCountry?[i].toUpperCase() ==
              countriesElements[j].code) {
            countriesElements.removeAt(j);
            break;
          }
        }
      }
    }
    if (widget.favouriteCountries != null) {
      favoriteCountries = countriesElements
          .where((Country element) =>
              widget.favouriteCountries?.contains(element.code) ?? false)
          .toList();
    }
  }

  @override
  void didChangeDependencies() {
    countriesElements =
        countriesElements.map((Country e) => e.localize(context)).toList();
    super.didChangeDependencies();
  }

  double calculateTextWidth(double size) {
    const int defaultSize = 50;
    return size * defaultSize / _defaultTextStyle.fontSize!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size?.width ?? MediaQuery.of(context).size.width * 0.8,
      height: widget.size?.height ?? MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color:
            widget.backGroundColor ?? Theme.of(context).dialogBackgroundColor,
        borderRadius: widget.borderRadius ??
            const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: widget.header ??
                    const Text(
                      'Select Country',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
              ),
              const Spacer(),
              if (widget.closeIconWidget == null)
                IconButton(
                  iconSize: 20,
                  splashRadius: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                )
              else
                widget.closeIconWidget!,
            ],
          ),
          if (widget.showSearchBar ?? true)
            Container(
              margin: widget.searchStyle?.searchBoxMargin ??
                  const EdgeInsets.only(
                    right: 16,
                    left: 16,
                  ),
              height: widget.searchStyle?.searchBoxHeight ?? 40,
              child: TextField(
                style: widget.searchStyle?.searchTextStyle ??
                    const TextStyle(
                      fontSize: 14,
                      height: 16 / 14,
                    ),
                textAlignVertical: TextAlignVertical.center,
                onChanged: (String value) => _filterElements(value),
                decoration: widget.searchStyle?.searchFieldInputDecoration ??
                    InputDecoration(
                      isCollapsed: true,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(9),
                        child: widget.searchStyle?.searchIcon ??
                            SvgPicture.asset(
                              color: Colors.grey.shade400,
                              'assets/icons/search.png',
                              package: 'mi_country_picker',
                            ),
                      ),
                      hintText: widget.searchStyle?.hintText ?? 'Search',
                      hintStyle:
                          TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    ),
              ),
            ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                if (favoriteCountries.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8),
                    sliver: SliverList.builder(
                      itemCount: favoriteCountries.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == favoriteCountries.length) {
                          return const Divider();
                        } else {
                          return InkWell(
                            onTap: () {
                              _selectItem(favoriteCountries[index]);
                            },
                            child: Padding(
                              padding: widget.countryTilePadding ??
                                  const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                              child:
                                  buildList(context, favoriteCountries[index]),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                if (filteredElements.isEmpty)
                  _buildEmptySearchWidget(context)
                else
                  SliverList.builder(
                    itemCount: filteredElements.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          _selectItem(filteredElements[index]);
                        },
                        child: Padding(
                          padding: widget.countryTilePadding ??
                              const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                          child: buildList(context, filteredElements[index]),
                        ),
                      );
                    },
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }
    return SliverFillRemaining(
      child: Center(
        child: Text(
            CountrySelectorLocalizations.of(context)?.translate('no_country') ??
                'Not found'),
      ),
    );
  }

  Widget buildList(BuildContext context, Country e) {
    if (widget.layoutConfig?.elementsOrder ==
        DisplayOrder.flagCodeAndCountryName) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (widget.layoutConfig?.showCountryFlag ?? true)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: widget.layoutConfig?.flagDecoration,
                clipBehavior: widget.layoutConfig?.flagDecoration == null
                    ? Clip.none
                    : Clip.hardEdge,
                child: CountryFlag(
                  assetName: e.image,
                  flagWidth: widget.layoutConfig?.flagWidth,
                  flagHeight: widget.layoutConfig?.flagHeight,
                ),
              ),
            ),
          if (widget.layoutConfig?.showCountryCode ?? true)
            SizedBox(
              width: calculateTextWidth(
                  widget.layoutConfig?.textStyle?.fontSize ??
                      _defaultTextStyle.fontSize!),
              child: Text(
                e.toString(),
                style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
                textAlign: TextAlign.start,
                overflow: TextOverflow.fade,
              ),
            ),
          Expanded(
            child: Text(
              " ${widget.layoutConfig?.showCountryName ?? true ? e.toCountryStringOnly() : ""}",
              style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.left,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.layoutConfig?.showCountryCode ?? true)
            SizedBox(
              width: calculateTextWidth(
                  widget.layoutConfig?.textStyle?.fontSize ??
                      _defaultTextStyle.fontSize!),
              child: Text(
                e.toString(),
                style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
                textAlign: TextAlign.start,
                overflow: TextOverflow.fade,
              ),
            ),
          Expanded(
            child: Text(
              " ${widget.layoutConfig?.showCountryName ?? true ? e.toCountryStringOnly() : ""}",
              style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.left,
              overflow: TextOverflow.fade,
            ),
          ),
          if (widget.layoutConfig?.showCountryFlag ?? true)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(left: 16.0),
                decoration: widget.layoutConfig?.flagDecoration,
                clipBehavior: widget.layoutConfig?.flagDecoration == null
                    ? Clip.none
                    : Clip.hardEdge,
                child: CountryFlag(
                  assetName: e.image,
                  flagWidth: widget.layoutConfig?.flagWidth,
                  flagHeight: widget.layoutConfig?.flagHeight,
                ),
              ),
            ),
        ],
      );
    }
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = countriesElements
          .where((Country e) =>
              e.code.contains(s) ||
              e.dialCodes.contains(s) ||
              e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(Country e) {
    Navigator.pop(context, e);
  }
}
