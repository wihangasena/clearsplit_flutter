import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final file = File('data/state_store.json');
  if (!await file.exists()) {
    print('state_store.json not found in data/');
    exit(1);
  }

  final content = await file.readAsString();
  final Map<String, dynamic> store = jsonDecode(content) as Map<String, dynamic>;

  final client = HttpClient();
  for (final entry in store.entries) {
    final userId = entry.key;
    final state = entry.value;
    final uri = Uri.parse('http://127.0.0.1:8081/state/$userId');
    try {
      final req = await client.putUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final body = jsonEncode(state);
      req.add(utf8.encode(body));
      final resp = await req.close();
      final respBody = await utf8.decodeStream(resp);
      print('PUT $uri -> ${resp.statusCode}: ${respBody}');
    } catch (e) {
      print('Failed to PUT state for $userId: $e');
    }
    // Attempt to patch profile to sync users/people through the local backend
    try {
      final people = state['people'] as List<dynamic>?;
      if (people != null && people.isNotEmpty) {
        final me = Map<String, dynamic>.from(people.first as Map);
        final profileUri = Uri.parse('http://127.0.0.1:8081/profile/$userId');
        final profileReq = await client.patchUrl(profileUri);
        profileReq.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
        final profileBody = jsonEncode({
          'displayName': me['name'] ?? '',
          'avatar': me['avatar'] ?? '',
          'color': me['color'] ?? '',
        });
        profileReq.add(utf8.encode(profileBody));
        final profileResp = await profileReq.close();
        final profileRespBody = await utf8.decodeStream(profileResp);
        print('PATCH $profileUri -> ${profileResp.statusCode}: ${profileRespBody}');
      }
    } catch (e) {
      print('Failed to PATCH profile for $userId: $e');
    }
  }

  client.close();
}
