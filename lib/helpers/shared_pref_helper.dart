import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // Keys
  static const String _keyUserEmail = 'user_email';
  static const String _keyWaterGoal = 'water_goal';
  static const String _keyPersonalInfoSubmitted = 'personal_info_submitted';
  static const String _keyLastConnectedBleName = 'last_connected_ble_name';
  static const String _keyLastConnectedBleId = 'last_connected_ble_id';

  // Save user email
  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  static Future<void> setWaterGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWaterGoal, goal);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<int?> getUserGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWaterGoal);
  }

  // Personal info submitted
  static Future<void> setPersonalInfoSubmitted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPersonalInfoSubmitted, value);
  }

  static Future<bool> isPersonalInfoSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPersonalInfoSubmitted) ?? false;
  }

  // BLE info
  static Future<void> setLastConnectedBleName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastConnectedBleName, name);
  }

  static Future<void> setLastConnectedBleId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastConnectedBleId, id);
  }

  static Future<String?> getLastConnectedBleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastConnectedBleName);
  }

  static Future<String?> getLastConnectedBleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastConnectedBleId);
  }

  // Clear all stored values
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> clearLastConnectedDeviceData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyLastConnectedBleName);
    await prefs.remove(_keyLastConnectedBleId);
  }
}
