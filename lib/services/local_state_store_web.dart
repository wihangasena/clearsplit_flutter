import 'package:shared_preferences/shared_preferences.dart';

const _legacyStorageKey = 'buddysplit.state.v1';
const _currentStorageKey = 'clearsplit.state.v1';

class LocalStateStore {
  Future<String?> readState() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(_currentStorageKey);
    if (current != null) {
      return current;
    }

    final legacy = prefs.getString(_legacyStorageKey);
    if (legacy != null) {
      await prefs.setString(_currentStorageKey, legacy);
      await prefs.remove(_legacyStorageKey);
    }
    return legacy;
  }

  Future<void> writeState(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentStorageKey, value);
  }
}