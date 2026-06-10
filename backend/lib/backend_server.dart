import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class DemoAccount {
  const DemoAccount({
    required this.id,
    required this.displayName,
    required this.email,
    required this.password,
    required this.avatar,
    required this.color,
  });

  final String id;
  final String displayName;
  final String email;
  final String password;
  final String avatar;
  final String color;

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'avatar': avatar,
        'color': color,
      };
}

const List<DemoAccount> demoAccounts = [
  DemoAccount(
    id: 'user-you',
    displayName: 'You',
    email: 'you@clearsplit.app',
    password: 'demo123',
    avatar: '🙂',
    color: '#2563EB',
  ),
  DemoAccount(
    id: 'user-alex',
    displayName: 'Alex',
    email: 'alex@clearsplit.app',
    password: 'demo123',
    avatar: '🧑',
    color: '#10B981',
  ),
  DemoAccount(
    id: 'user-maya',
    displayName: 'Maya',
    email: 'maya@clearsplit.app',
    password: 'demo123',
    avatar: '👩',
    color: '#8B5CF6',
  ),
  DemoAccount(
    id: 'user-jordan',
    displayName: 'Jordan',
    email: 'jordan@clearsplit.app',
    password: 'demo123',
    avatar: '🧔',
    color: '#EF4444',
  ),
];

DemoAccount? _accountByEmail(String email) {
  for (final account in demoAccounts) {
    if (account.email.toLowerCase() == email.trim().toLowerCase()) {
      return account;
    }
  }
  return null;
}

Map<String, dynamic> _personJson({required String id, required String name, required String avatar, required String color}) {
  return {
    'id': id,
    'name': name,
    'avatar': avatar,
    'color': color,
  };
}

List<String> _uniqueIds(List<String> values) {
  final result = <String>[];
  for (final value in values) {
    if (!result.contains(value)) {
      result.add(value);
    }
  }
  return result;
}

Map<String, dynamic> _seedStateForAccount(DemoAccount account) {
  final now = DateTime.now();
  final meId = account.id;

  return {
    'me': meId,
    'people': [
      _personJson(id: meId, name: account.displayName, avatar: account.avatar, color: account.color),
      _personJson(id: 'alex', name: 'Alex', avatar: '🧑', color: '#10B981'),
      _personJson(id: 'maya', name: 'Maya', avatar: '👩', color: '#8B5CF6'),
      _personJson(id: 'jordan', name: 'Jordan', avatar: '🧔', color: '#EF4444'),
      _personJson(id: 'chloe', name: 'Chloe', avatar: '👱‍♀️', color: '#F59E0B'),
      _personJson(id: 'sam', name: 'Sam', avatar: '👨', color: '#0EA5E9'),
    ],
    'groups': [
      {'id': 'beach', 'name': 'The Beach House', 'emoji': '🏖️', 'members': _uniqueIds([meId, 'alex', 'maya', 'chloe'])},
      {'id': 'apt', 'name': 'The Apartment Crew', 'emoji': '🏠', 'members': _uniqueIds([meId, 'alex', 'jordan', 'sam'])},
      {'id': 'trip', 'name': 'Road Trip 2026', 'emoji': '🚗', 'members': _uniqueIds([meId, 'maya', 'sam'])},
    ],
    'expenses': [
      {
        'id': 'e1',
        'title': 'Five Guys Dinner',
        'amount': 62.5,
        'paidBy': meId,
        'participants': _uniqueIds([meId, 'alex', 'maya', 'jordan', 'sam']),
        'groupId': 'apt',
        'category': '🍔',
        'date': now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        'note': null,
        'settled': false,
        'personal': false,
      },
      {
        'id': 'e2',
        'title': 'Grocery Run',
        'amount': 90,
        'paidBy': 'alex',
        'participants': _uniqueIds([meId, 'alex']),
        'groupId': 'apt',
        'category': '🛒',
        'date': now.subtract(const Duration(hours: 26)).millisecondsSinceEpoch,
        'note': null,
        'settled': false,
        'personal': false,
      },
      {
        'id': 'e3',
        'title': 'Utilities - Oct',
        'amount': 240,
        'paidBy': meId,
        'participants': _uniqueIds([meId, 'alex', 'jordan', 'sam']),
        'groupId': 'apt',
        'category': '⚡',
        'date': now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        'note': null,
        'settled': false,
        'personal': false,
      },
      {
        'id': 'e4',
        'title': 'Cinema Tickets',
        'amount': 48,
        'paidBy': meId,
        'participants': _uniqueIds([meId, 'maya']),
        'groupId': 'trip',
        'category': '🎬',
        'date': now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        'note': null,
        'settled': false,
        'personal': false,
      },
      {
        'id': 'e5',
        'title': 'Beach BBQ',
        'amount': 120,
        'paidBy': 'chloe',
        'participants': _uniqueIds([meId, 'alex', 'maya', 'chloe']),
        'groupId': 'beach',
        'category': '🔥',
        'date': now.subtract(const Duration(days: 9)).millisecondsSinceEpoch,
        'note': null,
        'settled': true,
        'personal': false,
      },
      {
        'id': 'p1',
        'title': 'Morning Coffee',
        'amount': 4.75,
        'paidBy': meId,
        'participants': [meId],
        'groupId': null,
        'category': '☕',
        'date': now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
        'note': 'Food',
        'settled': false,
        'personal': true,
      },
      {
        'id': 'p2',
        'title': 'Metro Card',
        'amount': 30,
        'paidBy': meId,
        'participants': [meId],
        'groupId': null,
        'category': '🚇',
        'date': now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        'note': 'Transport',
        'settled': false,
        'personal': true,
      },
      {
        'id': 'p3',
        'title': 'Spotify',
        'amount': 10.99,
        'paidBy': meId,
        'participants': [meId],
        'groupId': null,
        'category': '🎧',
        'date': now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
        'note': 'Bills',
        'settled': false,
        'personal': true,
      },
      {
        'id': 'p4',
        'title': 'Gym Membership',
        'amount': 45,
        'paidBy': meId,
        'participants': [meId],
        'groupId': null,
        'category': '💪',
        'date': now.subtract(const Duration(days: 6)).millisecondsSinceEpoch,
        'note': 'Health',
        'settled': false,
        'personal': true,
      },
    ],
    'grocery': [
      {'id': 'g1', 'groupId': 'apt', 'name': 'Almond Milk', 'tag': 'DAIRY FREE', 'qty': '2 cartons', 'claimedBy': 'alex', 'boughtBy': null, 'price': null, 'done': false},
      {'id': 'g2', 'groupId': 'apt', 'name': 'Avocados', 'tag': 'PRODUCE', 'qty': 'Pack of 4', 'claimedBy': null, 'boughtBy': null, 'price': null, 'done': false},
      {'id': 'g3', 'groupId': 'apt', 'name': 'Fresh Pasta', 'tag': null, 'qty': null, 'claimedBy': null, 'boughtBy': 'alex', 'price': 12.5, 'done': true},
      {'id': 'g4', 'groupId': 'apt', 'name': 'Greek Yogurt', 'tag': null, 'qty': null, 'claimedBy': null, 'boughtBy': null, 'price': null, 'done': false},
      {'id': 'g5', 'groupId': 'apt', 'name': 'Eggs', 'tag': null, 'qty': 'Dozen', 'claimedBy': null, 'boughtBy': null, 'price': null, 'done': false},
      {'id': 'g6', 'groupId': 'apt', 'name': 'Bread', 'tag': 'BAKERY', 'qty': null, 'claimedBy': null, 'boughtBy': null, 'price': null, 'done': false},
    ],
  };
}

class BackendStore {
  BackendStore(this.file, {this.remote});

  final File file;
  final SupabaseStateSync? remote;
  Map<String, Map<String, dynamic>> _states = <String, Map<String, dynamic>>{};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) {
      return;
    }
    if (await file.exists()) {
      final raw = await file.readAsString();
      if (raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _states = decoded.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)));
      }
    }
    _loaded = true;
  }

  Future<Map<String, dynamic>> stateForAccount(DemoAccount account) async {
    await _ensureLoaded();
    final remoteState = await remote?.fetchState(account.id);
    if (remoteState != null) {
      _states[account.id] = remoteState;
      await _persist();
      return remoteState;
    }

    final existing = _states[account.id];
    if (existing != null) {
      await remote?.saveState(account.id, existing);
      return existing;
    }
    final seeded = _seedStateForAccount(account);
    _states[account.id] = seeded;
    await _persist();
    await remote?.saveState(account.id, seeded);
    return seeded;
  }

  Future<Map<String, dynamic>> stateForUserId(String userId) async {
    await _ensureLoaded();
    final account = demoAccounts.firstWhere((entry) => entry.id == userId, orElse: () => throw StateError('Unknown user'));
    return stateForAccount(account);
  }

  Future<void> saveState(String userId, Map<String, dynamic> state) async {
    await _ensureLoaded();
    _states[userId] = state;
    await _persist();
    await remote?.saveState(userId, state);
  }

  Future<Map<String, dynamic>> updateProfile(
    String userId, {
    required String displayName,
    required String avatar,
    required String color,
  }) async {
    await _ensureLoaded();
    final account = demoAccounts.firstWhere((entry) => entry.id == userId, orElse: () => throw StateError('Unknown user'));
    final state = await stateForAccount(account);
    final people = (state['people'] as List<dynamic>).map((entry) {
      final person = Map<String, dynamic>.from(entry as Map);
      if (person['id'] == state['me']) {
        return {
          ...person,
          'name': displayName,
          'avatar': avatar,
          'color': color,
        };
      }
      return person;
    }).toList();

    final updated = {
      ...state,
      'people': people,
    };
    _states[userId] = updated;
    await _persist();
    await remote?.saveState(userId, updated);
    return updated;
  }

  Future<void> _persist() async {
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(_states));
  }
}

class SupabaseStateSync {
  SupabaseStateSync._({required this.url, required this.key});

  final Uri url;
  final String key;

  static SupabaseStateSync? fromEnvironment() {
    final env = _loadEnv();
    final rawUrl = _normalizeSupabaseUrl(env['SUPABASE_URL'] ?? env['VITE_SUPABASE_URL'], env['VITE_SUPABASE_PROJECT_ID']);
    final key = env['SUPABASE_SERVICE_ROLE_KEY'] ?? env['SUPABASE_ANON_KEY'] ?? env['VITE_SUPABASE_PUBLISHABLE_KEY'];
    if (rawUrl == null || key == null) {
      return null;
    }
    final parsedUrl = Uri.tryParse(rawUrl);
    if (parsedUrl == null || !parsedUrl.hasScheme || parsedUrl.host.isEmpty) {
      return null;
    }
    return SupabaseStateSync._(url: parsedUrl, key: key);
  }

  Future<Map<String, dynamic>?> fetchState(String userId) async {
    final rows = await _get(
      'app_states',
      query: {
        'user_id': 'eq.$userId',
        'select': 'state',
        'limit': '1',
      },
    );
    if (rows.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(rows.first['state'] as Map);
  }

  Future<void> saveState(String userId, Map<String, dynamic> state) async {
    await _post(
      'app_states',
      query: {'on_conflict': 'user_id'},
      body: {
        'user_id': userId,
        'state': state,
      },
      prefer: 'resolution=merge-duplicates,return=minimal',
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String email,
    required String displayName,
    required String avatar,
    required String color,
  }) async {
    await _patch(
      'users',
      query: {'email': 'eq.$email'},
      body: {
        'display_name': displayName,
        'avatar': avatar,
        'color': color,
      },
    );
    await _patch(
      'people',
      query: {'user_id': 'eq.$userId'},
      body: {
        'name': displayName,
        'avatar': avatar,
        'color': color,
      },
    );
  }

  Future<List<Map<String, dynamic>>> _get(String table, {required Map<String, String> query}) async {
    final endpoint = _endpoint(table, query);
    final client = HttpClient();
    try {
      final request = await client.getUrl(endpoint);
      _setHeaders(request.headers);
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      if (response.statusCode >= 400) {
        throw StateError('Supabase read failed for $table (${response.statusCode}): $body');
      }
      final decoded = jsonDecode(body);
      return (decoded as List<dynamic>).map((entry) => Map<String, dynamic>.from(entry as Map)).toList();
    } finally {
      client.close();
    }
  }

  Future<void> _post(String table, {required Map<String, String> query, required Map<String, dynamic> body, required String prefer}) async {
    final endpoint = _endpoint(table, query);
    final client = HttpClient();
    try {
      final request = await client.postUrl(endpoint);
      _setHeaders(request.headers, prefer: prefer);
      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await utf8.decodeStream(response);
      if (response.statusCode >= 400) {
        throw StateError('Supabase save failed for $table (${response.statusCode}): $responseBody');
      }
    } finally {
      client.close();
    }
  }

  Future<void> _patch(String table, {required Map<String, String> query, required Map<String, dynamic> body}) async {
    final endpoint = _endpoint(table, query);
    final client = HttpClient();
    try {
      final request = await client.patchUrl(endpoint);
      _setHeaders(request.headers);
      request.write(jsonEncode(body));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw StateError('Supabase profile sync failed for $table (${response.statusCode}).');
      }
    } finally {
      client.close();
    }
  }

  Uri _endpoint(String table, Map<String, String> query) {
    return url.replace(
      path: '${url.path.replaceAll(RegExp(r'/$'), '')}/rest/v1/$table',
      queryParameters: query,
    );
  }

  void _setHeaders(HttpHeaders headers, {String prefer = 'return=minimal'}) {
    headers
      ..set(HttpHeaders.authorizationHeader, 'Bearer $key')
      ..set('apikey', key)
      ..set(HttpHeaders.contentTypeHeader, 'application/json')
      ..set('Prefer', prefer);
  }
}

String? _normalizeSupabaseUrl(String? rawUrl, String? projectId) {
  if (rawUrl == null || rawUrl.trim().isEmpty) {
    return projectId == null ? null : 'https://$projectId.supabase.co';
  }
  final trimmed = rawUrl.trim();
  if (trimmed.contains('/dashboard/project/')) {
    final id = projectId ?? trimmed.split('/dashboard/project/').last.split('/').first;
    return 'https://$id.supabase.co';
  }
  return trimmed;
}

Map<String, String> _loadEnv() {
  final values = <String, String>{...Platform.environment};
  for (final path in ['.env', '../.env', '../.vscode/.env']) {
    final file = File(path);
    if (!file.existsSync()) {
      continue;
    }
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#') || !trimmed.contains('=')) {
        continue;
      }
      final index = trimmed.indexOf('=');
      values.putIfAbsent(trimmed.substring(0, index), () => trimmed.substring(index + 1));
    }
  }
  return values;
}

Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: const {'Content-Type': 'application/json; charset=utf-8'},
  );
}

Middleware _corsMiddleware() {
  const headers = <String, String>{
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await innerHandler(request);
      return response.change(headers: {...response.headers, ...headers});
    };
  };
}

Future<void> runBackendServer({int port = 8081}) async {
  final supabase = SupabaseStateSync.fromEnvironment();
  final store = BackendStore(File('data/state_store.json'), remote: supabase);
  final router = Router()
    ..get('/health', (Request request) {
      return _jsonResponse({'status': 'ok'});
    })
    ..get('/accounts', (Request request) {
      return _jsonResponse({
        'accounts': demoAccounts.map((account) => account.toJson()).toList(),
      });
    })
    ..post('/auth/login', (Request request) async {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final email = (payload['email'] ?? '').toString().trim();
      final password = (payload['password'] ?? '').toString();
      final account = _accountByEmail(email);
      if (account == null) {
        return _jsonResponse({'message': 'Unknown user.'}, statusCode: 404);
      }
      if (account.password != password) {
        return _jsonResponse({'message': 'Incorrect password.'}, statusCode: 401);
      }

      final state = await store.stateForAccount(account);
      return _jsonResponse({
        'account': account.toJson(),
        'state': state,
      });
    })
    ..get('/state/<userId>', (Request request, String userId) async {
      try {
        final state = await store.stateForUserId(userId);
        return _jsonResponse({'state': state});
      } catch (_) {
        return _jsonResponse({'message': 'Unknown user.'}, statusCode: 404);
      }
    })
    ..put('/state/<userId>', (Request request, String userId) async {
      final decoded = jsonDecode(await request.readAsString());
      if (decoded is! Map) {
        return _jsonResponse({'message': 'Invalid state payload.'}, statusCode: 400);
      }
      final data = Map<String, dynamic>.from(decoded);
      try {
        await store.saveState(userId, data);
        return _jsonResponse({'state': data});
      } catch (_) {
        return _jsonResponse({'message': 'Unable to save state.'}, statusCode: 500);
      }
    })
    ..patch('/profile/<userId>', (Request request, String userId) async {
      final decoded = jsonDecode(await request.readAsString());
      if (decoded is! Map) {
        return _jsonResponse({'message': 'Invalid profile payload.'}, statusCode: 400);
      }
      final data = Map<String, dynamic>.from(decoded);
      final displayName = (data['displayName'] ?? '').toString().trim();
      final avatar = (data['avatar'] ?? '').toString().trim();
      final color = (data['color'] ?? '').toString().trim();
      if (displayName.isEmpty || avatar.isEmpty || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
        return _jsonResponse({'message': 'Invalid profile details.'}, statusCode: 400);
      }

      try {
        final account = demoAccounts.firstWhere((entry) => entry.id == userId);
        final state = await store.updateProfile(userId, displayName: displayName, avatar: avatar, color: color);
        if (supabase != null) {
          try {
            await supabase.updateProfile(
              userId: userId,
              email: account.email,
              displayName: displayName,
              avatar: avatar,
              color: color,
            );
          } catch (error) {
            stderr.writeln(error);
          }
        }
        return _jsonResponse({'state': state});
      } catch (_) {
        return _jsonResponse({'message': 'Unable to update profile.'}, statusCode: 500);
      }
    })
    ..post('/auth/logout', (Request request) {
      return _jsonResponse({'status': 'ok'});
    });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, '127.0.0.1', port);
  print('ClearSplit backend listening on http://${server.address.host}:${server.port}');
}
