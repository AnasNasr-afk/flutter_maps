import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  SharedPrefHelper._();

  static Future<void> removeData(String key) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.remove(key);
    debugPrint('🗑️ Removed key: $key from SharedPreferences');
  }

  static Future<void> clearAllData() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.clear();
    debugPrint('🧹 Cleared all SharedPreferences data');
  }

  static Future<void> setData(String key, dynamic value) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    debugPrint('💾 Saving key: "$key" with value: "$value" (${value.runtimeType})');
    switch (value.runtimeType) {
      case const (String):
        await sharedPref.setString(key, value);
        break;
      case const (bool):
        await sharedPref.setBool(key, value);
        break;
      case const (int):
        await sharedPref.setInt(key, value);
        break;
      case const (double):
        await sharedPref.setDouble(key, value);
        break;
      default:
        debugPrint('❌ Unsupported type for key: $key');
        throw Exception('Unsupported type');
    }
  }

  static Future<String> getString(String key) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final result = sharedPref.getString(key) ?? '';
    debugPrint('📤 Retrieved String key: "$key" → "$result"');
    return result;
  }

  static Future<bool> getBool(String key) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final result = sharedPref.getBool(key) ?? false;
    debugPrint('📤 Retrieved Bool key: "$key" → $result');
    return result;
  }

  static Future<int> getInt(String key) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final result = sharedPref.getInt(key) ?? 0;
    debugPrint('📤 Retrieved Int key: "$key" → $result');
    return result;
  }

  static Future<double> getDouble(String key) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final result = sharedPref.getDouble(key) ?? 0.0;
    debugPrint('📤 Retrieved Double key: "$key" → $result');
    return result;
  }
}
