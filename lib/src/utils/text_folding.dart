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
  final String folded = foldForSearch(name);
  if (languageCode == 'ar' && folded.length > 2 && folded.startsWith('ال')) {
    return folded.substring(2);
  }
  return folded;
}
