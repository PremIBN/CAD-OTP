/// Offline phonetic transliteration for simple English/Latin words into
/// selected Indic scripts.
///
/// This is NOT translation. Example: "Task" -> "टास्क" (hi/mr),
/// "ટાસ્ક" (gu), "ಟಾಸ್ಕ" (kn), "டாஸ்க" (ta), "టాస్క" (te).
class TransliterationService {
  static bool _isAsciiLetter(int c) =>
      (c >= 65 && c <= 90) || (c >= 97 && c <= 122);

  static String transliterate(String input, String languageCode) {
    final lang = languageCode.toLowerCase();
    if (lang == 'en') return input;
    if (input.isEmpty) return input;

    final scheme = _schemeFor(lang);
    if (scheme == null) return input;

    // Preferred spellings for common UI (same English pronunciation, target script).
    final glossed = _applyUiGlossary(input, lang);
    // Transliterate remaining Latin letter runs only (allows mixed Indic + English).
    return _transliterateAsciiRuns(glossed, scheme);
  }

  /// Replace known English UI phrases/words with fixed script forms, longest first.
  static String _applyUiGlossary(String input, String lang) {
    final g = _glossaryMapFor(lang);
    if (g == null || g.isEmpty) return input;

    final phraseEntries = g.entries.where((e) => e.key.contains(' ')).toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    final wordEntries = g.entries.where((e) => !e.key.contains(' ')).toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    var s = input;
    for (final e in phraseEntries) {
      final re = RegExp(RegExp.escape(e.key), caseSensitive: false);
      s = s.replaceAll(re, e.value);
    }
    for (final e in wordEntries) {
      final re = RegExp(r'\b' + RegExp.escape(e.key) + r'\b', caseSensitive: false);
      s = s.replaceAllMapped(re, (_) => e.value);
    }
    return s;
  }

  static Map<String, String>? _glossaryMapFor(String lang) {
    switch (lang) {
      case 'mr':
        return _uiGlossaryMr;
      case 'hi':
        return _uiGlossaryHi;
      case 'gu':
        return _uiGlossaryGu;
      case 'kn':
        return _uiGlossaryKn;
      case 'ta':
        return _uiGlossaryTa;
      case 'te':
        return _uiGlossaryTe;
      default:
        return null;
    }
  }

  /// Devanagari (Hindi): tuned to common UI pronunciation.
  static const Map<String, String> _uiGlossaryHi = {

  "attendance": "अटेंडन्स",
  "date": "डेट",
  "day": "डे",
  "time": "टाइम",
  "current time": "करंट टाइम",
  "view swipes": "व्यू स्वाइप्स",
  "total hours": "टोटल आवर्स",
  "sign in": "साइन इन",
  "sign out": "साइन आउट",
  "due today": "ड्यू टुडे",
  "over due": "ओवरड्यू",
  "overdue": "ओवरड्यू",
  "due soon": "ड्यू सून",
  "not started yet": "नॉट स्टार्टेड येट",
  "work in progress": "वर्क इन प्रोग्रेस",
  "need approval": "नीड अप्रूवल",
  "future task": "फ्यूचर टास्क",
  "completed": "कम्प्लीटेड",
  "closed": "क्लोज्ड",
  "pending from client": "पेंडिंग फ्रॉम क्लायंट",
  "invoiced": "इनवॉइस्ड",
  "notes": "नोट्स",
  "efforts": "एफ़र्ट्स",
  "service type": "सर्विस टाइप",
  "assigned to": "असाइन टू",
  "assignor": "असाइनर",
  "reviewer": "रिव्यूअर",
  "start date": "स्टार्ट डेट",
  "end date": "एंड डेट",
  "mandate number": "मेंडेट नंबर",
  "billable": "बिलेबल",
  "app settings": "ऐप सेटिंग्स",
  "notifications & reminders": "नोटिफिकेशन एवं रिमाइंडर",
  "privacy policy": "प्राइवेसी पॉलिसी",
  "terms & condition": "टर्म्स अँड कंडिशन",
  "terms and condition": "टर्म्स अँड कंडिशन",
  "terms&condition": "टर्म्स अँड कंडिशन",
  "delete my account": "डिलीट माय अकाउंट",
  "name": "नाम",
  "account receivable": "अकाउंट रिसीवेबल",
  "client details": "क्लाइंट डिटेल्स",
  "client info": "क्लाइंट इन्फो",
  "owner details": "ओनर डिटेल्स",
  "financial year": "फाइनेंशियल ईयर",
  "add client": "ऐड क्लाइंट",
  "update client": "अपडेट क्लाइंट",
  "add task": "ऐड टास्क",
  "add sub task": "ऐड सब टास्क",
  "update task": "अपडेट टास्क",
  "update sub task": "अपडेट सब टास्क",
  "sub tasks": "सब टास्क",
  "username": "यूज़रनेम",
  "change password": "चेंज पासवर्ड",
  "edit profile": "एडिट प्रोफ़ाइल",
  "phone number": "फोन नंबर",
  "pan number": "पैन नंबर",
  "file number": "फाइल नंबर",
  "referred by": "रेफ़र्ड बाय",
  "company name": "कंपनी नेम",
  "first name": "फर्स्ट नेम",
  "last name": "लास्ट नेम",
  "client name": "क्लाइंट नेम",
  "client type": "क्लाइंट टाइप",
  "currency type": "करेंसी टाइप",
  "org name": "ऑर्गनाइजेशन नेम",
  "ending date": "एंडिंग डेट",
  "branch name": "ब्रांच नेम",
  "documents": "डॉक्युमेंट्स",
  "document": "डॉक्युमेंट",
  "notification": "नोटिफिकेशन",
  "task": "टास्क",
  "client": "क्लाइंट",
  "priority": "प्रायोरिटी",
  "department": "डिपार्टमेंट",
  "branch": "ब्रांच",
  "segment": "सेगमेंट",
  "settings": "सेटिंग्स",
  "password": "पासवर्ड",
  "profile": "प्रोफ़ाइल",
  "submit": "सबमिट",
  "cancel": "कैंसल",
  "save": "सेव",
  "search": "सर्च",
  "delete": "डिलीट",
  "logout": "लॉगआउट",
  "login": "लॉगिन",
  "yes": "यस",
  "no": "नो",
  "all": "ऑल",
  "internal": "इंटरनल",
  "regular": "रेग्युलर",
  "status": "स्टेटस",
  "email": "ईमेल",
  "employee3": "एम्प्लॉयी 3",
  "employee2": "एम्प्लॉयी 2",
  "employee": "एम्प्लॉयी",
  "home": "होम",
  "about us": "अबाउट अस",
  "camera": "कैमरा",
  "gallery": "गैलरी",
  "no folders or files here.": "यहां कोई फोल्डर या फाइल नहीं है।",
  "no folder and files here": "यहां कोई फोल्डर या फाइल नहीं है।",
  "total overdue outstanding amount": "कुल अतिदेय बकाया राशि",
  "previous year outstanding amount": "पिछले वर्ष की बकाया राशि",
  "total outstanding amount": "कुल बकाया राशि",
  "total received amount": "कुल प्राप्त राशि",
  "total invoice amount": "कुल चालान राशि",
  "indian rupees (inr)": "इंडियन रुपी (₹) (Indian Rupee)",
  "indian rupee (inr)": "इंडियन रुपी (₹) (Indian Rupee)",
  "details": "डिटेल्स",
  "total": "टोटल",
  "currency": "करेंसी"
  };

  /// Devanagari (Marathi): separate map so spellings can diverge from Hindi.
  /// Currently mirrors Hindi spellings; adjust entries as needed for Marathi.
  static const Map<String, String> _uiGlossaryMr = {
    'attendance': 'अटेंडन्स',
    'date': 'डेट',
    'day': 'डे',
    'time': 'टाइम',
    'current time': 'करंट टाइम',
    'view swipes': 'व्ह्यू स्वाइप्स',
    'total hours': 'टोटल आवर्स',
    'sign in': 'साइन इन',
    'sign out': 'साइन आउट',
    'due today': 'ड्यू टुडे',
    'over due': 'ओव्हरड्यू',
    'overdue': 'ओव्हरड्यू',
    'due soon': 'ड्यू सून',
    'not started yet': 'नॉट स्टार्टेड येट',
    'work in progress': 'वर्क इन प्रोग्रेस',
    'need approval': 'नीड अप्रुव्हल',
    'future task': 'फ्यूचर टास्क',
    'completed': 'कम्प्लीटेड',
    'closed': 'क्लोज्ड',
    'pending from client': 'पेंडिंग फ्रॉम क्लायंट',
    'invoiced': 'इनवॉइस्ड',
    'notes': 'नोट्स',
    'efforts': 'एफोर्ट्स',
    'service type': 'सर्विस टाईप',
    'assigned to': 'असाइन टू',
    'assignor': 'असाइनर',
    'reviewer': 'रिव्यूअर',
    'start date': 'स्टार्ट डेट',
    'end date': 'एंड डेट',
    'mandate number': 'मेंडेट नंबर',
    'billable': 'बिलेबल',
    'app settings': 'ॲप सेटिंग्स',
    'notifications & reminders': 'नोटिफिकेशन आणि रिमाइंडर',
    'privacy policy': 'प्रायव्हसी पॉलिसी',
    'terms & condition': 'टर्म्स अँड कंडिशन',
    'delete my account': 'डिलीट माय अकाउंट',
    'name': 'नाव',
    'account receivable': 'अकाउंट रिसीवेबल',
    'client details': 'क्लायंट डिटेल्स',
    'client info': 'क्लायंट इन्फो',
    'owner details': 'ओनर डिटेल्स',
    'financial year': 'फायनान्शियल इयर',
    'add client': 'ऐड क्लायंट',
    'update client': 'अपडेट क्लायंट',
    'add task': 'ऐड टास्क',
    'add sub task': 'ऐड सब टास्क',
    'update task': 'अपडेट टास्क',
    'update sub task': 'अपडेट सब टास्क',
    'sub tasks': 'सब टास्क',
    'username': 'यूज़रनेम',
    'change password': 'चेंज पासवर्ड',
    'edit profile': 'एडिट प्रोफाईल',
    'phone number': 'फोन नंबर',
    'pan number': 'पैन नंबर',
    'file number': 'फाइल नंबर',
    'referred by': 'रेफर बाय',
    'company name': 'कंपनी नेम',
    'first name': 'फर्स्ट नेम',
    'last name': 'लास्ट नेम',
    'client name': 'क्लायंट नेम',
    'please select client supply type': 'कृपया क्लायंट सप्लाय प्रकार निवडा',
    'please select branch name': 'कृपया ब्रांच नाव निवडा',
    'please select group type': 'कृपया गट प्रकार निवडा',
    'please select industry type': 'कृपया उद्योग प्रकार निवडा',
    'please select firm type': 'कृपया फर्म प्रकार निवडा',
    'please select std code': 'कृपया एसटीडी कोड निवडा',
    'please select client type': 'कृपया क्लायंट प्रकार निवडा',
    'select client joining date': 'क्लायंट सामील होण्याची तारीख निवडा',
    'client joining date': 'क्लायंट सामील होण्याची तारीख',
    'client supply type': 'क्लायंट सप्लाय प्रकार',
    'client type': 'क्लायंट प्रकार',
    'std code': 'एसटीडी कोड',
    'firm type': 'फर्म प्रकार',
    'industry type': 'उद्योग प्रकार',
    'group type': 'गट प्रकार',
    'currency type': 'करेंसी टाइप',
    'org name': 'ऑर्गनायझेशन नेम',
    'ending date': 'एंडिंग डेट',
    'branch name': 'ब्रांच नेम',
    'documents': 'डॉक्युमेंट्स',
    'document': 'डॉक्युमेंट',
    'notification': 'नोटिफिकेशन',
    'task': 'टास्क',
    'client': 'क्लायंट',
    'priority': 'प्रायोरिटी',
    'department': 'डिपार्टमेंट',
    'branch': 'ब्रांच',
    'segment': 'सेगमेंट',
    'settings': 'सेटिंग्स',
    'password': 'पासवर्ड',
    'profile': 'प्रोफाइल',
    'submit': 'सबमिट',
    'cancel': 'कॅन्सल',
    'save': 'सेव',
    'search': 'सर्च',
    'delete': 'डिलीट',
    'logout': 'लॉगआउट',
    'login': 'लॉगिन',
    'yes': 'यस',
    'no': 'नो',
    'all': 'ऑल',
    'internal': 'इंटरनल',
    'regular': 'रेग्युलर',
    'status': 'स्टेटस',
    'email': 'ईमेल',
    'employee3': 'एम्प्लॉयी 3',
    'employee2': 'एम्प्लॉयी 2',
    'employee': 'एम्प्लॉयी',
    'home': 'होम',
    'about us': 'अबाउट अस',
    'camera': 'कॅमेरा',
    'gallery': 'गॅलरी',
    'no folders or files here.': 'येथे कोणताही फोल्डर किंवा फाइल नाही.',
    'no folder and files here': 'येथे कोणताही फोल्डर किंवा फाइल नाही.',
    'total overdue outstanding amount': 'एकूण थकबाकी देय रक्कम',
    'previous year outstanding amount': 'मागील वर्षाची थकबाकी रक्कम',
    'total outstanding amount': 'एकूण थकबाकी रक्कम',
    'total received amount': 'एकूण प्राप्त रक्कम',
    'total invoice amount': 'एकूण चलन रक्कम',
    'indian rupees (inr)': 'भारतीय रुपया (₹) (Indian Rupee)',
    'indian rupee (inr)': 'भारतीय रुपया (₹) (Indian Rupee)',
    'details': 'तपशील',
    'total': 'एकूण',
    'currency': 'चलन',
  };

  static const Map<String, String> _uiGlossaryGu = {
    'attendance': 'અટેન્ડન્સ',
    'date': 'ડેટ',
    'day': 'ડે',
    'time': 'ટાઇમ',
    'current time': 'કરંટ ટાઇમ',
    'view swipes': 'વ્યૂ સ્વાઇપ્સ',
    'total hours': 'ટોટલ અવર્સ',
    'sign in': 'સાઇન ઇન',
    'sign out': 'સાઇન આઉટ',
    'due today': 'ડ્યુ ટુડે',
    'over due': 'ઓવરડ્યુ',
    'overdue': 'ઓવરડ્યુ',
    'due soon': 'ડ્યુ સૂન',
    'not started yet': 'નોટ સ્ટાર્ટેડ યેટ',
    'work in progress': 'વર્ક ઇન પ્રોગ્રેસ',
    'need approval': 'નીડ એપ્રુવલ',
    'future task': 'ફ્યુચર ટાસ્ક',
    'completed': 'કમ્પ્લીટેડ',
    'closed': 'ક્લોઝ્ડ',
    'pending from client': 'પેન્ડિંગ ફ્રોમ ક્લાયન્ટ',
    'invoiced': 'ઇનવોઇસ્ડ',
    'notes': 'નોટ્સ',
    'efforts': 'એફોર્ટ્સ',
    'service type': 'સર્વિસ ટાઇપ',
    'status': 'સ્ટેટસ',
    'assigned to': 'અસાઇન ટુ',
    'assignor': 'અસાઇનર',
    'reviewer': 'રિવ્યુઅર',
    'client name': 'ક્લાયન્ટ નેમ',
    'start date': 'સ્ટાર્ટ ડેટ',
    'end date': 'એન્ડ ડેટ',
    'branch': 'બ્રાંચ',
    'department': 'ડિપાર્ટમેન્ટ',
    'priority': 'પ્રાયોરિટી',
    'financial year': 'ફાઇનાન્શિયલ યર',
    'mandate number': 'મેન્ડેટ નંબર',
    'billable': 'બિલેબલ',
    'app settings': 'એપ સેટિંગ્સ',
    'notifications & reminders': 'નોટિફિકેશન અને રિમાઇન્ડર',
    'change password': 'ચેન્જ પાસવર્ડ',
    'privacy policy': 'પ્રાઇવસી પોલિસી',
    'terms & condition': 'ટર્મ્સ એન્ડ કન્ડીશન',
    'delete my account': 'ડિલીટ માય અકાઉન્ટ',
    'name': 'નામ',
    'account receivable': 'અકાઉન્ટ રિસીવેબલ',
    'client details': 'ક્લાયન્ટ ડિટેલ્સ',
    'documents': 'ડોક્યુમેન્ટ્સ',
    'document': 'ડોક્યુમેન્ટ',
    'task': 'ટાસ્ક',
    'client': 'ક્લાયન્ટ',
    'notification': 'નોટિફિકેશન',
    'submit': 'સબમિટ',
    'cancel': 'કેન્સલ',
    'save': 'સેવ',
    'search': 'સર્ચ',
    'login': 'લોગિન',
    'logout': 'લોગઆઉટ',
    'settings': 'સેટિંગ્સ',
    'password': 'પાસવર્ડ',
    'home': 'હોમ',
    'yes': 'યસ',
    'no': 'નો',
    'all': 'ઓલ',
    'internal': 'ઇન્ટર્નલ',
    'regular': 'રેગ્યુલર',
    'segment': 'સેગમેન્ટ',
    'email': 'ઇમેઇલ',
    'employee3': 'એમ્પ્લોયી 3',
    'employee2': 'એમ્પ્લોયી 2',
    'employee': 'એમ્પ્લોયી',
    'no folders or files here.': 'અહીં કોઈ ફોલ્ડર અથવા ફાઇલ નથી.',
    'no folder and files here': 'અહીં કોઈ ફોલ્ડર અથવા ફાઇલ નથી.',
    'total overdue outstanding amount': 'કુલ વિલંબિત બાકી રકમ',
    'previous year outstanding amount': 'ગત વર્ષની બાકી રકમ',
    'total outstanding amount': 'કુલ બાકી રકમ',
    'total received amount': 'કુલ પ્રાપ્ત રકમ',
    'total invoice amount': 'કુલ ઇન્વૉઇસ રકમ',
    'indian rupees (inr)': 'ભારતીય રૂપિયો (₹) (Indian Rupee)',
    'indian rupee (inr)': 'ભારતીય રૂપિયો (₹) (Indian Rupee)',
    'details': 'વિગતો',
    'total': 'કુલ',
    'currency': 'ચલણ',
  };

  static const Map<String, String> _uiGlossaryKn = {
    'attendance': 'ಅಟೆಂಡನ್ಸ್',
    'date': 'ಡೇಟ್',
    'day': 'ಡೇ',
    'time': 'ಟೈಮ್',
    'current time': 'ಕರಂಟ್ ಟೈಮ್',
    'view swipes': 'ವ್ಯೂ ಸ್ವೈಪ್ಸ್',
    'total hours': 'ಟೋಟಲ್ ಅವರ್ಸ್',
    'sign in': 'ಸೈನ್ ಇನ್',
    'sign out': 'ಸೈನ್ ಔಟ್',
    'due today': 'ಡ್ಯೂ ಟುಡೇ',
    'over due': 'ಓವರ್ ಡ್ಯೂ',
    'overdue': 'ಓವರ್ ಡ್ಯೂ',
    'due soon': 'ಡ್ಯೂ ಸೂನ್',
    'not started yet': 'ನಾಟ್ ಸ್ಟಾರ್ಟೆಡ್ ಯೆಟ್',
    'work in progress': 'ವರ್ಕ್ ಇನ್ ಪ್ರೋಗ್ರೆಸ್',
    'need approval': 'ನೀಡ್ ಅಪ್ರೂವಲ್',
    'future task': 'ಫ್ಯೂಚರ್ ಟಾಸ್ಕ್',
    'completed': 'ಕಂಪ್ಲೀಟೆಡ್',
    'closed': 'ಕ್ಲೋಸ್ಡ್',
    'pending from client': 'ಪೆಂಡಿಂಗ್ ಫ್ರಮ್ ಕ್ಲೈಂಟ್',
    'invoiced': 'ಇನ್‌ವಾಯ್ಸ್‌ಡ್',
    'notes': 'ನೋಟ್ಸ್',
    'efforts': 'ಎಫರ್ಟ್ಸ್',
    'service type': 'ಸರ್ವಿಸ್ ಟೈಪ್',
    'assigned to': 'ಅಸೈನ್ ಟು',
    'assignor': 'ಅಸೈನರ್',
    'reviewer': 'ರಿವ್ಯೂಅರ್',
    'start date': 'ಸ್ಟಾರ್ಟ್ ಡೇಟ್',
    'end date': 'ಎಂಡ್ ಡೇಟ್',
    'mandate number': 'ಮ್ಯಾಂಡೇಟ್ ನಂಬರ್',
    'billable': 'ಬಿಲ್ಲೇಬಲ್',
    'app settings': 'ಆಪ್ ಸೆಟ್ಟಿಂಗ್ಸ್',
    'notifications & reminders': 'ನೋಟಿಫಿಕೇಶನ್ ಮತ್ತು ರಿಮೈಂಡರ್',
    'privacy policy': 'ಪ್ರೈವಸಿ ಪಾಲಿಸಿ',
    'terms & condition': 'ಟರ್ಮ್ಸ್ ಅಂಡ್ ಕಂಡೀಶನ್',
    'delete my account': 'ಡಿಲೀಟ್ ಮೈ ಅಕೌಂಟ್',
    'name': 'ನೇಮ್',
    'account receivable': 'ಅಕೌಂಟ್ ರಿಸೀವೆಬಲ್',
    'client details': 'ಕ್ಲೈಂಟ್ ಡೀಟೇಲ್ಸ್',
    'documents': 'ಡಾಕ್ಯುಮೆಂಟ್ಸ್',
    'document': 'ಡಾಕ್ಯುಮೆಂಟ್',
    'task': 'ಟಾಸ್ಕ್',
    'client': 'ಕ್ಲೈಂಟ್',
    'notification': 'ನೋಟಿಫಿಕೇಶನ್',
    'submit': 'ಸಬ್ಮಿಟ್',
    'cancel': 'ಕ್ಯಾನ್ಸಲ್',
    'save': 'ಸೇವ್',
    'search': 'ಸರ್ಚ್',
    'login': 'ಲಾಗಿನ್',
    'logout': 'ಲಾಗ್ಔಟ್',
    'settings': 'ಸೆಟ್ಟಿಂಗ್ಸ್',
    'password': 'ಪಾಸ್ವರ್ಡ್',
    'home': 'ಹೋಮ್',
    'yes': 'ಯಸ್',
    'no': 'ನೋ',
    'all': 'ಆಲ್',
    'internal': 'ಇಂಟರ್ನಲ್',
    'regular': 'ರೆಗ್ಯುಲರ್',
    'status': 'ಸ್ಟೇಟಸ್',
    'priority': 'ಪ್ರಯಾರಿಟಿ',
    'department': 'ಡಿಪಾರ್ಟ್ಮೆಂಟ್',
    'branch': 'ಬ್ರಾಂಚ್',
    'segment': 'ಸೆಗ್ಮೆಂಟ್',
    'email': 'ಇಮೇಲ್',
    'employee3': 'ಎಂಪ್ಲಾಯೀ 3',
    'employee2': 'ಎಂಪ್ಲಾಯೀ 2',
    'employee': 'ಎಂಪ್ಲಾಯೀ',
    'no folders or files here.': 'ಇಲ್ಲಿ ಯಾವುದೇ ಫೋಲ್ಡರ್ ಅಥವಾ ಫೈಲ್ ಇಲ್ಲ.',
    'no folder and files here': 'ಇಲ್ಲಿ ಯಾವುದೇ ಫೋಲ್ಡರ್ ಅಥವಾ ಫೈಲ್ ಇಲ್ಲ.',
    'total overdue outstanding amount': 'ಒಟ್ಟು ವಿಲಂಬಿತ ಬಾಕಿ ಮೊತ್ತ',
    'previous year outstanding amount': 'ಹಿಂದಿನ ವರ್ಷದ ಬಾಕಿ ಮೊತ್ತ',
    'total outstanding amount': 'ಒಟ್ಟು ಬಾಕಿ ಮೊತ್ತ',
    'total received amount': 'ಒಟ್ಟು ಸ್ವೀಕರಿಸಿದ ಮೊತ್ತ',
    'total invoice amount': 'ಒಟ್ಟು ಇನ್‌ವಾಯ್ಸ್ ಮೊತ್ತ',
    'indian rupees (inr)': 'ಭಾರತೀಯ ರೂಪಾಯಿ (₹) (Indian Rupee)',
    'indian rupee (inr)': 'ಭಾರತೀಯ ರೂಪಾಯಿ (₹) (Indian Rupee)',
    'details': 'ವಿವರಗಳು',
    'total': 'ಒಟ್ಟು',
    'currency': 'ಕರೆನ್ಸಿ',
  };

  static const Map<String, String> _uiGlossaryTa = {
    'attendance': 'அடெண்டன்ஸ்',
    'date': 'டேட்',
    'day': 'டே',
    'time': 'டைம்',
    'current time': 'கரண்ட் டைம்',
    'view swipes': 'வியூ ஸ்வைப்ப்ஸ்',
    'total hours': 'டோட்டல் அவர்ஸ்',
    'sign in': 'சைன் இன்',
    'sign out': 'சைன் அவுட்',
    'due today': 'ட்யூ டுடே',
    'over due': 'ஓவர் ட்யூ',
    'overdue': 'ஓவர் ட்யூ',
    'due soon': 'ட்யூ சூன்',
    'not started yet': 'நாட் ஸ்டார்டெட் யெட்',
    'work in progress': 'வொர்க் இன் ப்ரோக்ரெஸ்',
    'need approval': 'நீட் அப்ரூவல்',
    'future task': 'ஃப்யூச்சர் டாஸ்க்',
    'completed': 'கம்ப்ளீட்டெட்',
    'closed': 'க்ளோஸ்ட்',
    'pending from client': 'பெண்டிங் ஃப்ரம் கிளையன்ட்',
    'invoiced': 'இன்வாய்ஸ்ட்',
    'notes': 'நோட்ஸ்',
    'efforts': 'எஃபர்ட்ஸ்',
    'service type': 'சர்விஸ் டைப்',
    'assigned to': 'அசைன் டூ',
    'assignor': 'அசைனர்',
    'reviewer': 'ரிவ்யூஅர்',
    'start date': 'ஸ்டார்ட் டேட்',
    'end date': 'எண்ட் டேட்',
    'mandate number': 'மேன்டேட் நம்பர்',
    'billable': 'பில்லேபல்',
    'app settings': 'ஆப் செட்டிங்ஸ்',
    'notifications & reminders': 'நோட்டிஃபிகேஷன் மற்றும் ரிமைண்டர்',
    'privacy policy': 'ப்ரைவேசி பாலிசி',
    'terms & condition': 'டெர்ம்ஸ் அண்ட் கண்டிஷன்',
    'delete my account': 'டிலீட் மை அக்கவுண்ட்',
    'name': 'நேம்',
    'account receivable': 'அக்கவுண்ட் ரிசீவபிள்',
    'client details': 'கிளையன்ட் டீடெயில்ஸ்',
    'documents': 'டாக்குமெண்ட்ஸ்',
    'document': 'டாக்குமெண்ட்',
    'task': 'டாஸ்க்',
    'client': 'கிளையன்ட்',
    'notification': 'நோட்டிஃபிகேஷன்',
    'submit': 'சப்மிட்',
    'cancel': 'கேன்சல்',
    'save': 'சேவ்',
    'search': 'செர்ச்',
    'login': 'லாகின்',
    'logout': 'லாக்அவுட்',
    'settings': 'செட்டிங்ஸ்',
    'password': 'பாஸ்வேர்ட்',
    'home': 'ஹோம்',
    'yes': 'யெஸ்',
    'no': 'நோ',
    'all': 'ஆல்',
    'internal': 'இன்டர்னல்',
    'regular': 'ரெகுலர்',
    'status': 'ஸ்டேட்டஸ்',
    'priority': 'பிரயாரிட்டி',
    'department': 'டிபார்ட்மென்ட்',
    'branch': 'பிராஞ்ச்',
    'segment': 'செக்மென்ட்',
    'email': 'இமெயில்',
    'employee3': 'எம்ப்ளாயி 3',
    'employee2': 'எம்ப்ளாயி 2',
    'employee': 'எம்ப்ளாயி',
    'no folders or files here.': 'இங்கு கோப்புறை அல்லது கோப்பு எதுவும் இல்லை.',
    'no folder and files here': 'இங்கு கோப்புறை அல்லது கோப்பு எதுவும் இல்லை.',
    'total overdue outstanding amount': 'மொத்த தாமத நிலுவைத் தொகை',
    'previous year outstanding amount': 'முந்தைய ஆண்டு நிலுவைத் தொகை',
    'total outstanding amount': 'மொத்த நிலுவைத் தொகை',
    'total received amount': 'மொத்த பெற்ற தொகை',
    'total invoice amount': 'மொத்த விலைப்பட்டியல் தொகை',
    'indian rupees (inr)': 'இந்திய ரூபாய் (₹) (Indian Rupee)',
    'indian rupee (inr)': 'இந்திய ரூபாய் (₹) (Indian Rupee)',
    'details': 'விவரங்கள்',
    'total': 'மொத்தம்',
    'currency': 'நாணயம்',
  };

  static const Map<String, String> _uiGlossaryTe = {
    'attendance': 'అటెండన్స్',
    'date': 'డేట్',
    'day': 'డే',
    'time': 'టైమ్',
    'current time': 'కరెంట్ టైమ్',
    'view swipes': 'వ్యూ స్వైప్స్',
    'total hours': 'టోటల్ అవర్స్',
    'sign in': 'సైన్ ఇన్',
    'sign out': 'సైన్ ఔట్',
    'due today': 'డ్యూ టుడే',
    'over due': 'ఓవర్ డ్యూ',
    'overdue': 'ఓవర్ డ్యూ',
    'due soon': 'డ్యూ సూన్',
    'not started yet': 'నాట్ స్టార్టెడ్ యెట్',
    'work in progress': 'వర్క్ ఇన్ ప్రోగ్రెస్',
    'need approval': 'నీడ్ అప్రూవల్',
    'future task': 'ఫ్యూచర్ టాస్క్',
    'completed': 'కంప్లీటెడ్',
    'closed': 'క్లోజ్డ్',
    'pending from client': 'పెండింగ్ ఫ్రం క్లయింట్',
    'invoiced': 'ఇన్వాయ్స్‌డ్',
    'notes': 'నోట్స్',
    'efforts': 'ఎఫోర్ట్స్',
    'service type': 'సర్వీస్ టైప్',
    'assigned to': 'అసైన్ టు',
    'assignor': 'అసైనర్',
    'reviewer': 'రివ్యూ అర్',
    'start date': 'స్టార్ట్ డేట్',
    'end date': 'ఎండ్ డేట్',
    'mandate number': 'మ్యాండేట్ నంబర్',
    'billable': 'బిల్లేబల్',
    'app settings': 'ఆప్ సెట్టింగ్స్',
    'notifications & reminders': 'నోటిఫికేషన్ మరియు రిమైండర్',
    'privacy policy': 'ప్రైవసీ పాలసీ',
    'terms & condition': 'టర్మ్స్ అండ్ కండిషన్',
    'delete my account': 'డిలీట్ మై అకౌంట్',
    'name': 'నేమ్',
    'account receivable': 'అకౌంట్ రిసీవబుల్',
    'client details': 'క్లయింట్ డీటైల్స్',
    'documents': 'డాక్యుమెంట్స్',
    'document': 'డాక్యుమెంట్',
    'task': 'టాస్క్',
    'client': 'క్లయింట్',
    'notification': 'నోటిఫికేషన్',
    'submit': 'సబ్మిట్',
    'cancel': 'క్యాన్సల్',
    'save': 'సేవ్',
    'search': 'సెర్చ్',
    'login': 'లాగిన్',
    'logout': 'లాగౌట్',
    'settings': 'సెట్టింగ్స్',
    'password': 'పాస్వర్డ్',
    'home': 'హోమ్',
    'yes': 'యస్',
    'no': 'నో',
    'all': 'ఆల్',
    'internal': 'ఇంటర్నల్',
    'regular': 'రెగ్యులర్',
    'status': 'స్టేటస్',
    'priority': 'ప్రయారిటీ',
    'department': 'డిపార్ట్మెంట్',
    'branch': 'బ్రాంచ్',
    'segment': 'సెగ్మెంట్',
    'email': 'ఇమెయిల్',
    'employee3': 'ఎంప్లాయీ 3',
    'employee2': 'ఎంప్లాయీ 2',
    'employee': 'ఎంప్లాయీ',
    'no folders or files here.': 'ఇక్కడ ఎలాంటి ఫోల్డర్ లేదా ఫైల్ లేదు.',
    'no folder and files here': 'ఇక్కడ ఎలాంటి ఫోల్డర్ లేదా ఫైల్ లేదు.',
    'total overdue outstanding amount': 'మొత్తం ఆలస్యం బకాయి మొత్తం',
    'previous year outstanding amount': 'గత సంవత్సరం బకాయి మొత్తం',
    'total outstanding amount': 'మొత్తం బకాయి మొత్తం',
    'total received amount': 'మొత్తం అందిన మొత్తం',
    'total invoice amount': 'మొత్తం ఇన్వాయిస్ మొత్తం',
    'indian rupees (inr)': 'భారతీయ రూపాయి (₹) (Indian Rupee)',
    'indian rupee (inr)': 'భారతీయ రూపాయి (₹) (Indian Rupee)',
    'details': 'వివరాలు',
    'total': 'మొత్తం',
    'currency': 'కరెన్సీ',
  };

  static String _transliterateAsciiRuns(String input, _Scheme scheme) {
    final out = StringBuffer();
    int i = 0;
    while (i < input.length) {
      final c = input.codeUnitAt(i);
      if (!_isAsciiLetter(c)) {
        out.writeCharCode(c);
        i++;
        continue;
      }
      final start = i;
      while (i < input.length && _isAsciiLetter(input.codeUnitAt(i))) {
        i++;
      }
      final word = input.substring(start, i);
      out.write(_transliterateWord(word, scheme));
    }
    return out.toString();
  }

  static _Scheme? _schemeFor(String lang) {
    switch (lang) {
      case 'hi':
      case 'mr':
        return _Schemes.devanagari;
      case 'gu':
        return _Schemes.gujarati;
      case 'kn':
        return _Schemes.kannada;
      case 'ta':
        return _Schemes.tamil;
      case 'te':
        return _Schemes.telugu;
      default:
        return null;
    }
  }

  static String _transliterateWord(String word, _Scheme s) {
    final lower = word.toLowerCase();
    final tokens = _tokenize(lower);
    if (tokens.isEmpty) return word;

    final buf = StringBuffer();
    bool prevWasConsonant = false;

    for (int t = 0; t < tokens.length; t++) {
      final tok = tokens[t];
      final isVowel = s.vowels.containsKey(tok);
      final isCons = s.consonants.containsKey(tok);

      if (isCons) {
        final cons = s.consonants[tok]!;
        if (prevWasConsonant) {
          // Close previous consonant with virama to form a cluster.
          buf.write(s.virama);
        }
        buf.write(cons);
        prevWasConsonant = true;
        continue;
      }

      if (isVowel) {
        final nextToPrevWasCons = prevWasConsonant;
        if (nextToPrevWasCons) {
          final matra = s.matras[tok];
          if (matra != null) buf.write(matra);
        } else {
          buf.write(s.vowels[tok]!);
        }
        prevWasConsonant = false;
        continue;
      }

      // Unknown token: keep as-is (rare).
      if (prevWasConsonant) {
        // End the consonant with implicit 'a' (do nothing).
        prevWasConsonant = false;
      }
      buf.write(tok);
    }

    // If word ends in consonant, add virama so "task" becomes टास्क (not टासक).
    if (prevWasConsonant) {
      buf.write(s.virama);
    }

    return buf.toString();
  }

  /// Greedy tokenization for simple English -> Indic phonetics.
  /// This is intentionally small and tuned for common UI words.
  static List<String> _tokenize(String s) {
    final tokens = <String>[];
    int i = 0;
    while (i < s.length) {
      String? tok;

      // Common digraphs/trigraphs (order matters).
      const multi = [
        'sh', 'ch', 'th', 'dh', 'ph', 'kh', 'gh', 'bh', 'jh',
        'aa', 'ee', 'ii', 'oo', 'uu',
        'ng', 'ny',
      ];
      for (final m in multi) {
        if (i + m.length <= s.length && s.substring(i, i + m.length) == m) {
          tok = m;
          break;
        }
      }

      tok ??= s[i];
      tokens.add(tok);
      i += tok.length;
    }
    return tokens;
  }
}

class _Scheme {
  final Map<String, String> vowels; // independent
  final Map<String, String> matras; // dependent on consonant
  final Map<String, String> consonants;
  final String virama;

  const _Scheme({
    required this.vowels,
    required this.matras,
    required this.consonants,
    required this.virama,
  });
}

class _Schemes {
  static const devanagari = _Scheme(
    virama: '्',
    vowels: {
      'a': 'अ', 'aa': 'आ', 'i': 'इ', 'ii': 'ई', 'u': 'उ', 'uu': 'ऊ',
      'e': 'ए', 'o': 'ओ',
    },
    matras: {
      'a': '', 'aa': 'ा', 'i': 'ि', 'ii': 'ी', 'u': 'ु', 'uu': 'ू',
      'e': 'े', 'o': 'ो',
    },
    consonants: {
      'k': 'क', 'g': 'ग', 'h': 'ह',
      'kh': 'ख', 'gh': 'घ',
      'c': 'क', 'ch': 'च', 'j': 'ज', 'jh': 'झ',
      't': 'ट', 'd': 'ड', 'th': 'थ', 'dh': 'ध',
      'n': 'न', 'ng': 'ङ', 'ny': 'ञ',
      'p': 'प', 'ph': 'फ', 'b': 'ब', 'bh': 'भ',
      'm': 'म', 'y': 'य', 'r': 'र', 'l': 'ल', 'v': 'व', 'w': 'व',
      's': 'स', 'sh': 'श', 'z': 'ज',
      'f': 'फ', 'q': 'क', 'x': 'क्स',
    },
  );

  static const gujarati = _Scheme(
    virama: '્',
    vowels: {
      'a': 'અ', 'aa': 'આ', 'i': 'ઇ', 'ii': 'ઈ', 'u': 'ઉ', 'uu': 'ઊ',
      'e': 'એ', 'o': 'ઓ',
    },
    matras: {
      'a': '', 'aa': 'ા', 'i': 'િ', 'ii': 'ી', 'u': 'ુ', 'uu': 'ૂ',
      'e': 'ે', 'o': 'ો',
    },
    consonants: {
      'k': 'ક', 'g': 'ગ', 'h': 'હ',
      'kh': 'ખ', 'gh': 'ઘ',
      'c': 'ક', 'ch': 'ચ', 'j': 'જ', 'jh': 'ઝ',
      't': 'ટ', 'd': 'ડ', 'th': 'થ', 'dh': 'ધ',
      'n': 'ન', 'ng': 'ઙ', 'ny': 'ઞ',
      'p': 'પ', 'ph': 'ફ', 'b': 'બ', 'bh': 'ભ',
      'm': 'મ', 'y': 'ય', 'r': 'ર', 'l': 'લ', 'v': 'વ', 'w': 'વ',
      's': 'સ', 'sh': 'શ', 'z': 'જ',
      'f': 'ફ', 'q': 'ક', 'x': 'ક્સ',
    },
  );

  static const kannada = _Scheme(
    virama: '್',
    vowels: {
      'a': 'ಅ', 'aa': 'ಆ', 'i': 'ಇ', 'ii': 'ಈ', 'u': 'ಉ', 'uu': 'ಊ',
      'e': 'ಏ', 'o': 'ಓ',
    },
    matras: {
      'a': '', 'aa': 'ಾ', 'i': 'ಿ', 'ii': 'ೀ', 'u': 'ು', 'uu': 'ೂ',
      'e': 'ೇ', 'o': 'ೋ',
    },
    consonants: {
      'k': 'ಕ', 'g': 'ಗ', 'h': 'ಹ',
      'kh': 'ಖ', 'gh': 'ಘ',
      'c': 'ಕ', 'ch': 'ಚ', 'j': 'ಜ', 'jh': 'ಝ',
      't': 'ಟ', 'd': 'ಡ', 'th': 'ಥ', 'dh': 'ಧ',
      'n': 'ನ', 'ng': 'ಙ', 'ny': 'ಞ',
      'p': 'ಪ', 'ph': 'ಫ', 'b': 'ಬ', 'bh': 'ಭ',
      'm': 'ಮ', 'y': 'ಯ', 'r': 'ರ', 'l': 'ಲ', 'v': 'ವ', 'w': 'ವ',
      's': 'ಸ', 'sh': 'ಶ', 'z': 'ಜ',
      'f': 'ಫ', 'q': 'ಕ', 'x': 'ಕ್ಸ',
    },
  );

  static const tamil = _Scheme(
    virama: '்',
    vowels: {
      'a': 'அ', 'aa': 'ஆ', 'i': 'இ', 'ii': 'ஈ', 'u': 'உ', 'uu': 'ஊ',
      'e': 'ஏ', 'o': 'ஓ',
    },
    matras: {
      'a': '', 'aa': 'ா', 'i': 'ி', 'ii': 'ீ', 'u': 'ு', 'uu': 'ூ',
      'e': 'ே', 'o': 'ோ',
    },
    consonants: {
      'k': 'க', 'g': 'க', 'h': 'ஹ',
      'kh': 'க', 'gh': 'க',
      'c': 'க', 'ch': 'ச', 'j': 'ஜ', 'jh': 'ஜ',
      't': 'ட', 'd': 'ட', 'th': 'த', 'dh': 'த',
      'n': 'ந', 'ng': 'ங', 'ny': 'ஞ',
      'p': 'ப', 'ph': 'ப', 'b': 'ப', 'bh': 'ப',
      'm': 'ம', 'y': 'ய', 'r': 'ர', 'l': 'ல', 'v': 'வ', 'w': 'வ',
      's': 'ஸ', 'sh': 'ஷ', 'z': 'ஜ',
      'f': 'ஃப', 'q': 'க', 'x': 'க்ஸ',
    },
  );

  static const telugu = _Scheme(
    virama: '్',
    vowels: {
      'a': 'అ', 'aa': 'ఆ', 'i': 'ఇ', 'ii': 'ఈ', 'u': 'ఉ', 'uu': 'ఊ',
      'e': 'ఏ', 'o': 'ఓ',
    },
    matras: {
      'a': '', 'aa': 'ా', 'i': 'ి', 'ii': 'ీ', 'u': 'ు', 'uu': 'ూ',
      'e': 'ే', 'o': 'ో',
    },
    consonants: {
      'k': 'క', 'g': 'గ', 'h': 'హ',
      'kh': 'ఖ', 'gh': 'ఘ',
      'c': 'క', 'ch': 'చ', 'j': 'జ', 'jh': 'ఝ',
      't': 'ట', 'd': 'డ', 'th': 'థ', 'dh': 'ధ',
      'n': 'న', 'ng': 'ఙ', 'ny': 'ఞ',
      'p': 'ప', 'ph': 'ఫ', 'b': 'బ', 'bh': 'భ',
      'm': 'మ', 'y': 'య', 'r': 'ర', 'l': 'ల', 'v': 'వ', 'w': 'వ',
      's': 'స', 'sh': 'శ', 'z': 'జ',
      'f': 'ఫ', 'q': 'క', 'x': 'క్స',
    },
  );
}

