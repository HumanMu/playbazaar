
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static final _prefs = SharedPreferences.getInstance();

  static Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  static Future<void> setDouble(String key, int value) async {
    final prefs = await _prefs;
    await prefs.setInt(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await _prefs;
    await prefs.setInt(key, value);
  }


  // Set a list of strings
  static Future<void> setStringList(String key, List<String> value) async {
    final prefs = await _prefs;
    await prefs.setStringList(key, value);
  }


  // Similar methods for other data types
  static Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _prefs;
    return prefs.getInt(key);
  }

  // Get a list of strings
  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _prefs;
    return prefs.getStringList(key);
  }


}

class SharedPreferencesKeys {
  static const String userLoggedInKey = "LOGGEDINKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userLastNameKey = "USERLASTNAMEKEY";
  static const String appLanguageKey = "APPLANGUAGEKEY";
  static const String userAboutMeKey = "USERABOUTMEKEY";
  static const String userPointKey = "USERPOINTKEY";
  static const String userRoleKey = "USERROLE";
  static const String userCoinsKey = "USERCOINSKEY";

  // Settings
  static const String buttonSounds = "BUTTONSOUNDS";
}
