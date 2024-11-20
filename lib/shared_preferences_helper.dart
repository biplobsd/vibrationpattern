import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<void> saveMap(String key, Map<String, List<int>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(data);
    await prefs.setString(key, encodedData);
  }

  static Future<Map<String, List<int>>?> loadMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(key);

    if (jsonData == null) return null;

    final decodedData = jsonDecode(jsonData) as Map<String, dynamic>;

    return decodedData.map(
        (key, value) => MapEntry(key, List<int>.from(value as List<dynamic>)));
  }

  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
