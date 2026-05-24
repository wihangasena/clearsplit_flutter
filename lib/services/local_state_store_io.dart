import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

const _legacyStorageKey = 'buddysplit.state.v1';
const _currentStorageKey = 'clearsplit.state.v1';

/// Offline-first LocalStateStore.
///
/// - Reads/writes a full JSON app state to `SharedPreferences` as a local cache.
/// - If a Supabase user is signed in, attempts to sync the state to a remote
///   `user_state` table (columns: `user_id` text primary key, `value` jsonb, `updated_at` timestamptz).
class LocalStateStore {
  LocalStateStore() {
    // Listen for auth changes to trigger a sync when the user signs in.
    try {
      Supabase.instance.client.auth.onAuthStateChange((event, session) {
        final user = session?.user;
        if (user != null) {
          _syncFromRemote(user.id);
        }
      });
    } catch (_) {}
  }

  Future<String?> readState() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(_currentStorageKey);
    if (current != null) {
      // Kick off a background remote fetch if signed in, but return local immediately.
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        unawaited(_syncFromRemote(user.id));
      }
      return current;
    }

    // No local value — try legacy key migration first
    final legacy = prefs.getString(_legacyStorageKey);
    if (legacy != null) {
      await prefs.setString(_currentStorageKey, legacy);
      await prefs.remove(_legacyStorageKey);
      return legacy;
    }

    // If signed in, try fetching remote state
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final resp = await supabaseClient()
            .from('user_state')
            .select<List<Map<String, dynamic>>>()
            .eq('user_id', user.id)
            .limit(1)
            .execute();
        if (resp.error == null && resp.data != null && resp.data!.isNotEmpty) {
          final row = resp.data!.first;
          final value = row['value'] as String? ?? (row['value'] != null ? row['value'].toString() : null);
          if (value != null) {
            await prefs.setString(_currentStorageKey, value);
            return value;
          }
        }
      } catch (_) {}
    }

    return null;
  }

  Future<void> writeState(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentStorageKey, value);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }

    // Push to Supabase in the background. Table `user_state` should exist.
    unawaited(_pushToRemote(user.id, value));
  }

  Future<void> _pushToRemote(String userId, String value) async {
    try {
      await supabaseClient().from('user_state').upsert({
        'user_id': userId,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      }).execute();
    } catch (_) {
      // Ignore failures; will retry on next write or sign-in.
    }
  }

  Future<void> _syncFromRemote(String userId) async {
    try {
      final resp = await supabaseClient()
          .from('user_state')
          .select<List<Map<String, dynamic>>>()
          .eq('user_id', userId)
          .limit(1)
          .execute();
      if (resp.error == null && resp.data != null && resp.data!.isNotEmpty) {
        final row = resp.data!.first;
        final value = row['value'] as String? ?? (row['value'] != null ? row['value'].toString() : null);
        if (value != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currentStorageKey, value);
        }
      }
    } catch (_) {}
  }
}

// Helper for unawaited futures when analyzer isn't available
void unawaited(Future<void> f) {}