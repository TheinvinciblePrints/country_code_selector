import '../data/text_folding_table.dart';

/// Returns [text] lowercased with accents and other marks removed, so that
/// what users type matches names however they're written: "etats" matches
/// "États-Unis", and "امارات" matches "الإمارات".
///
/// Covers Latin, Greek, Cyrillic, Hebrew and Arabic; other scripts are only
/// lowercased.
String foldForSearch(String text) {
  final StringBuffer out = StringBuffer();
  for (final int rune in text.toLowerCase().runes) {
    final String? folded = kTextFoldingTable[rune];
    if (folded == null) {
      out.writeCharCode(rune);
    } else {
      out.write(folded);
    }
  }
  return out.toString();
}

/// Returns the key [name] is sorted by in [languageCode].
///
/// It's the folded name, so "Égypte" sorts with the E's rather than after
/// "Zimbabwe". In Arabic a leading definite article "ال" is ignored, as Arabic
/// lists usually do, so "البرازيل" sorts under ب. Search uses
/// [foldForSearch] instead, which keeps the article.
String sortKey(String name, String? languageCode) {
  // Check for the article before folding: folding turns the hamza in names
  // like "ألبانيا" (Albania) into a plain alif, which would then look like
  // the article and be stripped. Thanks to @Aomine3500 for spotting this.
  if (languageCode == 'ar' && name.length > 2 && name.startsWith('ال')) {
    return foldForSearch(name.substring(2));
  }
  return foldForSearch(name);
}
