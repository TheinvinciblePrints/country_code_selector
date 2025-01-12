import 'package:flutter/material.dart';

import '../../country_code_selector.dart';

class CountryCodeSelectorBottomSheet extends StatefulWidget {
  const CountryCodeSelectorBottomSheet(
      {super.key,
      this.favouriteCountries,
      this.layoutConfig,
      this.countryListConfig,
      this.searchStyle,
      this.header,
      this.showSearchBar,
      this.countryTilePadding,
      this.emptySearchBuilder,
      this.closeIconWidget});

  /// add your favorites countries
  final List<String>? favouriteCountries;

  final LayoutConfig? layoutConfig;
  final CountryListConfig? countryListConfig;
  final SearchStyle? searchStyle;
  final Text? header;
  final bool? showSearchBar;
  final EdgeInsetsGeometry? countryTilePadding;
  final WidgetBuilder? emptySearchBuilder;
  final Widget? closeIconWidget;

  @override
  State<CountryCodeSelectorBottomSheet> createState() =>
      _CountryCodeSelectorBottomSheetState();
}

class _CountryCodeSelectorBottomSheetState
    extends State<CountryCodeSelectorBottomSheet> {
  List<Country> countriesElements = <Country>[];
  Country? selectedItem;
  List<Country> favoriteCountries = <Country>[];
  List<Country> filteredElements = <Country>[];
  double? setWidthOfDialog;

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 14);

  @override
  void initState() {
    countriesElements = CountryService.countryList
        .map((dynamic element) =>
            Country.fromJson(element as Map<String, dynamic>))
        .toList();
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

    super.initState();
  }

  @override
  void didChangeDependencies() {
    countriesElements =
        countriesElements.map((Country e) => e.localize(context)).toList();
    super.didChangeDependencies();
  }

  double calculateSize(double size) {
    const int defaultSize = 50;
    return size * defaultSize / _defaultTextStyle.fontSize!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                  const TextStyle(fontSize: 14, height: 16 / 14),
              textAlignVertical: TextAlignVertical.center,
              onChanged: (String value) {
                _filterElements(value);
              },
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
                            Image.asset(
                              color: Colors.grey.shade400,
                              'assets/icons/search.png',
                              package: 'country_code_selector',
                            ),
                      ),
                      hintText: widget.searchStyle?.hintText ?? 'Search',
                      hintStyle:
                          TextStyle(fontSize: 14, color: Colors.grey.shade400)),
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
                            _selectItem(favoriteCountries[index], context);
                          },
                          child: Padding(
                            padding: widget.countryTilePadding ??
                                const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                            child: buildList(context, favoriteCountries[index]),
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
                        _selectItem(filteredElements[index], context);
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
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return SliverFillRemaining(
      child: Center(
        child: Text(CountryCodeSelectorLocalizations.of(context)
                ?.translate('no_country') ??
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
              width: calculateSize(widget.layoutConfig?.textStyle?.fontSize ??
                  _defaultTextStyle.fontSize!),
              child: Text(
                textAlign: TextAlign.start,
                e.code,
                overflow: TextOverflow.fade,
                style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
              ),
            ),
          Expanded(
            child: Text(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.left,
              " ${widget.layoutConfig?.showCountryName ?? true ? e.toCountryStringOnly() : ""}",
              overflow: TextOverflow.fade,
              style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
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
              width: calculateSize(widget.layoutConfig?.textStyle?.fontSize ??
                  _defaultTextStyle.fontSize!),
              child: Text(
                textAlign: TextAlign.start,
                e.code,
                overflow: TextOverflow.fade,
                style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
              ),
            ),
          Expanded(
            child: Text(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.left,
              " ${widget.layoutConfig?.showCountryName ?? true ? e.toCountryStringOnly() : ""}",
              overflow: TextOverflow.fade,
              style: widget.layoutConfig?.textStyle ?? _defaultTextStyle,
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

  Future<void> _selectItem(Country e, BuildContext context) async {
    final Country selectedCountry =
        await CountryService.loadCountryWithPhoneNumberLength(e);
    if (context.mounted) {
      Navigator.pop(context, selectedCountry);
    }
  }
}
