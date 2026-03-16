class PreferenceHelper {
  static const String userToken = 'userToken';
  static const String loginDetailID = 'loginDetailID';
  static const String isSignIn = 'isSignIn';
  static const String userName = 'userName';
  static const String userEmail = 'userEmail';
  static const String fullName = 'fullName';
  static const String userData = 'userData';
  static const String financialYearID = 'FinancialYearID';
  static const String taskStatus = 'taskStatus';
  static const String taskType = 'taskType';
  static const String mandateNumber = "mandateNumber";
  static const String showOtherTaskDetails = "showOtherTaskDetails";
  static const String currency = "currency";
  static const String fcmToken = "fcmToken";
  static const String restrictTillDays = "restrictTillDays";

/*  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _memoryPrefs = <String, dynamic>{};

  static Future<SharedPreferences> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static void setString(String key, String value) {
    _prefs!.setString(key, value);
    _memoryPrefs[key] = value;
  }

  static void setInt(String key, int value) {
    _prefs!.setInt(key, value);
    _memoryPrefs[key] = value;
  }

  static void setDouble(String key, double value) {
    _prefs!.setDouble(key, value);
    _memoryPrefs[key] = value;
  }

  static void setBool(String key, bool value) {
    _prefs!.setBool(key, value);
    _memoryPrefs[key] = value;
  }

  static String? getString(String key, {String? def}) {
    String? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    val ??= _prefs!.getString(key);
    val ??= def;
    _memoryPrefs[key] = val;
    return val;
  }

  static int getInt(String key, {int? def}) {
    int? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    val ??= _prefs!.getInt(key);
    val ??= def;
    _memoryPrefs[key] = val;
    return val!;
  }

  static double getDouble(String key, {double? def}) {
    double? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    val ??= _prefs!.getDouble(key);
    val ??= def;
    _memoryPrefs[key] = val;
    return val!;
  }

  static bool getBool(String key, {bool def = false}) {
    bool? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    val ??= _prefs!.getBool(key);
    val ??= def;
    _memoryPrefs[key] = val;
    return val;
  }

  static void clear() {
    _memoryPrefs.remove(isSignIn);
    _memoryPrefs.remove(userToken);
    _memoryPrefs.clear();
    _prefs!.remove(isSignIn);
    _prefs!.remove(userToken);
    _prefs!.clear();
  }
  */
}

