import '../data/text_folding_table.dart';

/// The first code point (the zero) of each run of ten decimal digits that
/// [normalizeDigits] converts to 0-9.
const List<int> _digitZeros = <int>[
  0x0660, // Arabic-Indic ٠
  0x06F0, // Extended Arabic-Indic (Persian, Urdu) ۰
  0x07C0, // N'Ko
  0x0966, // Devanagari
  0x09E6, // Bengali
  0x0A66, // Gurmukhi
  0x0AE6, // Gujarati
  0x0B66, // Oriya
  0x0BE6, // Tamil
  0x0C66, // Telugu
  0x0CE6, // Kannada
  0x0D66, // Malayalam
  0x0E50, // Thai
  0x0ED0, // Lao
  0x0F20, // Tibetan
  0x1040, // Myanmar
  0x17E0, // Khmer
  0x1810, // Mongolian
  0xFF10, // Full-width ０ (Chinese, Japanese and Korean input)
];

/// Returns [text] with digits from other scripts converted to 0-9, and a
/// full-width plus sign converted to `+`, so "٠٨٠٣" typed on an Arabic
/// keyboard reads as "0803". Other characters are unchanged.
String normalizeDigits(String text) {
  final StringBuffer out = StringBuffer();
  for (final int rune in text.runes) {
    if (rune == 0xFF0B) {
      out.write('+');
      continue;
    }
    int? ascii;
    for (final int zero in _digitZeros) {
      if (rune >= zero && rune <= zero + 9) {
        ascii = 0x30 + rune - zero;
        break;
      }
    }
    out.writeCharCode(ascii ?? rune);
  }
  return out.toString();
}

/// Returns [text] lowercased with accents and other marks removed, so that
/// what users type matches names however they're written: "etats" matches
/// "États-Unis", and "امارات" matches "الإمارات".
///
/// Covers Latin, Greek, Cyrillic, Hebrew and Arabic; other scripts are only
/// lowercased. Digits from other scripts become 0-9 (see [normalizeDigits]).
String foldForSearch(String text) {
  final StringBuffer out = StringBuffer();
  for (final int rune in normalizeDigits(text).toLowerCase().runes) {
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
