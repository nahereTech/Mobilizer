import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  static setList({required String key, required String value}) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, <String>[value]);
  }

  static setValue({required String key, required String value}) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static setInt({required String key, required int value}) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static removeValue({required String key}) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static setBool({required String key, required bool value}) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool("key", value);
  }

  static Future<String?> getValue({required String key}) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<int?> getInt({required String key}) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool?> getBool({required String key}) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool("key");
  }

  static Future<List<String>?> getList({required String key}) async {
    var prefs = await SharedPreferences.getInstance();
    //final List<String>? items = prefs.getStringList('items');
    return prefs.getStringList(key);
  }

  static remove({required String key}) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("key");
  }

  static clearCache() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
