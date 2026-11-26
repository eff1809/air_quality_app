import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _lastCityKey = 'last_city';
  static const _historyKey = 'search_history';
  static const _maxHistory = 5;

  Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, city);
  }

  Future<String?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey);
  }

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  // Kota terbaru di posisi paling depan, tanpa duplikat, maksimal 5
  Future<void> addToHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.removeWhere((c) => c.toLowerCase() == city.toLowerCase());
    list.insert(0, city);
    await prefs.setStringList(_historyKey, list.take(_maxHistory).toList());
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}