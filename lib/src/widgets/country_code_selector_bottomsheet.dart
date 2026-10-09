import 'package:flutter/material.dart';

import '../../country_code_selector.dart';
import '../data/ui_strings.dart';

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
  List<Country> favoriteCountries = <Country>[];
  List<Country> filteredElements = <Country>[];
  String _query = '';

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 14);

  bool get _localizeNames => widget.layoutConfig?.enableLocalization ?? true;

  String _uiString(String key) => CountryCodeSelectorLocalizations.uiString(
        Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        key,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve on locale changes so names and alphabetical order follow it.
    countriesElements = CountryRepository.resolve(
      widget.countryListConfig,
      context: _localizeNames ? context : null,
    );
    favoriteCountries = CountryRepository.favourites(
        countriesElements, widget.favouriteCountries);
    filteredElements = CountryRepository.search(countriesElements, _query);
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
                  Text(
                    _uiString(kSelectCountryKey),
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
                      hintText: widget.searchStyle?.hintText ??
                          MaterialLocalizations.of(context).searchFieldLabel,
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
        child: Text(_uiString(kNoCountryFoundKey)),
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

  void _filterElements(String query) {
    setState(() {
      _query = query;
      filteredElements = CountryRepository.search(countriesElements, query);
    });
  }

  void _selectItem(Country e, BuildContext context) {
    Navigator.pop(context, e);
  }
}
