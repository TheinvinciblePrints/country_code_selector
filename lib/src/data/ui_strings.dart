// Translations of the selector's own UI text.
//
// Keyed like the files in assets/i18n/ (language, or language_Script). A
// locale without an entry falls back to its language, then to English. The
// search hint isn't here: it comes from Flutter's MaterialLocalizations.
//
// To add a language, add an entry with both keys.

/// Key for the default header of the dialog and bottom sheet.
const String kSelectCountryKey = 'select_country';

/// Key for the default text shown when a search has no results.
const String kNoCountryFoundKey = 'no_country_found';

/// UI strings by translation id.
const Map<String, Map<String, String>> kUiStrings =
    <String, Map<String, String>>{
      'ar': <String, String>{
        kSelectCountryKey: 'اختر الدولة',
        kNoCountryFoundKey: 'لم يتم العثور على أي دولة',
      },
      'bg': <String, String>{
        kSelectCountryKey: 'Изберете държава',
        kNoCountryFoundKey: 'Не е намерена държава',
      },
      'bn': <String, String>{
        kSelectCountryKey: 'দেশ নির্বাচন করুন',
        kNoCountryFoundKey: 'কোনো দেশ পাওয়া যায়নি',
      },
      'ca': <String, String>{
        kSelectCountryKey: 'Selecciona un país',
        kNoCountryFoundKey: "No s'ha trobat cap país",
      },
      'cs': <String, String>{
        kSelectCountryKey: 'Vyberte zemi',
        kNoCountryFoundKey: 'Nebyla nalezena žádná země',
      },
      'da': <String, String>{
        kSelectCountryKey: 'Vælg land',
        kNoCountryFoundKey: 'Intet land fundet',
      },
      'de': <String, String>{
        kSelectCountryKey: 'Land auswählen',
        kNoCountryFoundKey: 'Kein Land gefunden',
      },
      'el': <String, String>{
        kSelectCountryKey: 'Επιλέξτε χώρα',
        kNoCountryFoundKey: 'Δεν βρέθηκε χώρα',
      },
      'en': <String, String>{
        kSelectCountryKey: 'Select country',
        kNoCountryFoundKey: 'No country found',
      },
      'es': <String, String>{
        kSelectCountryKey: 'Selecciona un país',
        kNoCountryFoundKey: 'No se encontró ningún país',
      },
      'fa': <String, String>{
        kSelectCountryKey: 'کشور را انتخاب کنید',
        kNoCountryFoundKey: 'کشوری یافت نشد',
      },
      'fi': <String, String>{
        kSelectCountryKey: 'Valitse maa',
        kNoCountryFoundKey: 'Maata ei löytynyt',
      },
      'fil': <String, String>{
        kSelectCountryKey: 'Pumili ng bansa',
        kNoCountryFoundKey: 'Walang nahanap na bansa',
      },
      'fr': <String, String>{
        kSelectCountryKey: 'Sélectionnez un pays',
        kNoCountryFoundKey: 'Aucun pays trouvé',
      },
      'he': <String, String>{
        kSelectCountryKey: 'בחירת מדינה',
        kNoCountryFoundKey: 'לא נמצאה מדינה',
      },
      'hi': <String, String>{
        kSelectCountryKey: 'देश चुनें',
        kNoCountryFoundKey: 'कोई देश नहीं मिला',
      },
      'hr': <String, String>{
        kSelectCountryKey: 'Odaberite državu',
        kNoCountryFoundKey: 'Nije pronađena nijedna država',
      },
      'hu': <String, String>{
        kSelectCountryKey: 'Válasszon országot',
        kNoCountryFoundKey: 'Nem található ország',
      },
      'id': <String, String>{
        kSelectCountryKey: 'Pilih negara',
        kNoCountryFoundKey: 'Negara tidak ditemukan',
      },
      'it': <String, String>{
        kSelectCountryKey: 'Seleziona un paese',
        kNoCountryFoundKey: 'Nessun paese trovato',
      },
      'ja': <String, String>{
        kSelectCountryKey: '国を選択',
        kNoCountryFoundKey: '国が見つかりません',
      },
      'ko': <String, String>{
        kSelectCountryKey: '국가 선택',
        kNoCountryFoundKey: '국가를 찾을 수 없습니다',
      },
      'ms': <String, String>{
        kSelectCountryKey: 'Pilih negara',
        kNoCountryFoundKey: 'Tiada negara ditemui',
      },
      'nb': <String, String>{
        kSelectCountryKey: 'Velg land',
        kNoCountryFoundKey: 'Fant ingen land',
      },
      'nl': <String, String>{
        kSelectCountryKey: 'Selecteer een land',
        kNoCountryFoundKey: 'Geen land gevonden',
      },
      'no': <String, String>{
        kSelectCountryKey: 'Velg land',
        kNoCountryFoundKey: 'Fant ingen land',
      },
      'pl': <String, String>{
        kSelectCountryKey: 'Wybierz kraj',
        kNoCountryFoundKey: 'Nie znaleziono kraju',
      },
      'pt': <String, String>{
        kSelectCountryKey: 'Selecione um país',
        kNoCountryFoundKey: 'Nenhum país encontrado',
      },
      'ro': <String, String>{
        kSelectCountryKey: 'Selectați țara',
        kNoCountryFoundKey: 'Nu a fost găsită nicio țară',
      },
      'ru': <String, String>{
        kSelectCountryKey: 'Выберите страну',
        kNoCountryFoundKey: 'Страна не найдена',
      },
      'sk': <String, String>{
        kSelectCountryKey: 'Vyberte krajinu',
        kNoCountryFoundKey: 'Nenašla sa žiadna krajina',
      },
      'sr': <String, String>{
        kSelectCountryKey: 'Изаберите земљу',
        kNoCountryFoundKey: 'Није пронађена ниједна земља',
      },
      'sr_Latn': <String, String>{
        kSelectCountryKey: 'Izaberite zemlju',
        kNoCountryFoundKey: 'Nije pronađena nijedna zemlja',
      },
      'sv': <String, String>{
        kSelectCountryKey: 'Välj land',
        kNoCountryFoundKey: 'Inget land hittades',
      },
      'sw': <String, String>{
        kSelectCountryKey: 'Chagua nchi',
        kNoCountryFoundKey: 'Hakuna nchi iliyopatikana',
      },
      'ta': <String, String>{
        kSelectCountryKey: 'நாட்டைத் தேர்ந்தெடுக்கவும்',
        kNoCountryFoundKey: 'நாடு எதுவும் கிடைக்கவில்லை',
      },
      'th': <String, String>{
        kSelectCountryKey: 'เลือกประเทศ',
        kNoCountryFoundKey: 'ไม่พบประเทศ',
      },
      'tr': <String, String>{
        kSelectCountryKey: 'Ülke seçin',
        kNoCountryFoundKey: 'Ülke bulunamadı',
      },
      'uk': <String, String>{
        kSelectCountryKey: 'Виберіть країну',
        kNoCountryFoundKey: 'Країну не знайдено',
      },
      'ur': <String, String>{
        kSelectCountryKey: 'ملک منتخب کریں',
        kNoCountryFoundKey: 'کوئی ملک نہیں ملا',
      },
      'vi': <String, String>{
        kSelectCountryKey: 'Chọn quốc gia',
        kNoCountryFoundKey: 'Không tìm thấy quốc gia',
      },
      'zh': <String, String>{
        kSelectCountryKey: '选择国家/地区',
        kNoCountryFoundKey: '未找到国家/地区',
      },
      'zh_Hant': <String, String>{
        kSelectCountryKey: '選擇國家/地區',
        kNoCountryFoundKey: '找不到國家/地區',
      },
    };
