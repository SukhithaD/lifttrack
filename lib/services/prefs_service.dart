import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _useKgKey = 'useKg';
  static const _notifTimeKey = 'notifTime';
  static const _workoutDaysKey = 'workoutDays';
  static const _notificationsEnabledKey = 'notificationsEnabled';

  static Future<bool> getUseKg() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useKgKey) ?? true;
  }

  static Future<void> setUseKg(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useKgKey, value);
  }

  static Future<String> getNotifTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notifTimeKey) ?? '07:00';
  }

  static Future<void> setNotifTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notifTimeKey, value);
  }

  static Future<List<bool>> getWorkoutDays() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_workoutDaysKey);
    if (saved != null) return saved.map((e) => e == 'true').toList();
    return [true, true, true, false, true, true, false];
  }

  static Future<void> setWorkoutDays(List<bool> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_workoutDaysKey, days.map((e) => e.toString()).toList());
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  // Conversion helpers
  static double kgToLbs(double kg) => kg * 2.205;
  static double lbsToKg(double lbs) => lbs / 2.205;

  static String formatWeight(double kg, bool useKg) {
    if (useKg) return '${_clean(kg)}kg';
    return '${_clean(kgToLbs(kg))}lbs';
  }

  static String _clean(double val) {
    if (val == val.truncateToDouble()) return val.toInt().toString();
    return val.toStringAsFixed(1);
  }
}
