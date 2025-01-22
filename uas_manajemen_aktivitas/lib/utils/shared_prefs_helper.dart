import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefsHelper {
  // Simpan user_id
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Simpan nama
  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  // Simpan email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // Simpan username
  static Future<void> saveUserUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_username', username);
  }

  static Future<String?> getUserUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_username');
  }

  // Hapus semua data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
