import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../app_state.dart';

class BackendClientException implements Exception {
  BackendClientException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackendAuthException extends BackendClientException {
  BackendAuthException(super.message);
}

class BackendSession {
  const BackendSession({
    required this.account,
    required this.state,
    this.accessToken,
  });

  final DemoAccount account;
  final AppData state;
  final String? accessToken;
}

class BackendClient {
  BackendClient({Uri? baseUri}) : _baseUri = baseUri ?? _defaultBaseUri();

  final Uri _baseUri;

  Uri _resolve(String path) => _baseUri.resolve(path);

  Future<BackendSession> signIn({
    required String email,
    required String password,
  }) async {
    return _signInWithBackend(email: email, password: password);
  }

  Future<BackendSession> _signInWithBackend({
    required String email,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await http.post(
        _resolve('/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
    } catch (_) {
      throw BackendClientException(_connectionMessage);
    }

    final payload = _decodeBody(response.body);
    if (response.statusCode != 200) {
      final message = (payload['message'] as String?) ?? 'Login failed.';
      if (response.statusCode == 401 || response.statusCode == 404) {
        throw BackendAuthException(message);
      }
      throw BackendClientException(message);
    }

    return BackendSession(
      account: DemoAccount(
        id: payload['account']['id'] as String,
        displayName: payload['account']['displayName'] as String,
        email: payload['account']['email'] as String,
        password: '',
        avatar: payload['account']['avatar'] as String,
        color: payload['account']['color'] as String,
      ),
      state: AppData.fromJson(
        Map<String, dynamic>.from(payload['state'] as Map),
      ),
    );
  }

  Future<void> saveState({
    required String userId,
    required AppData state,
  }) async {
    final response = await http.put(
      _resolve('/state/$userId'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(state.toJson()),
    );

    if (response.statusCode >= 400) {
      final payload = _decodeBody(response.body);
      final message =
          (payload['message'] as String?) ?? 'Unable to save state.';
      throw BackendClientException(message);
    }
  }

  Future<AppData> updateProfile({
    required String userId,
    required String displayName,
    required String avatar,
    required String color,
  }) async {
    final response = await http.patch(
      _resolve('/profile/$userId'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'displayName': displayName,
        'avatar': avatar,
        'color': color,
      }),
    );

    final payload = _decodeBody(response.body);
    if (response.statusCode >= 400) {
      final message =
          (payload['message'] as String?) ?? 'Unable to update profile.';
      throw BackendClientException(message);
    }

    return AppData.fromJson(Map<String, dynamic>.from(payload['state'] as Map));
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return const <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return Map<String, dynamic>.from(decoded as Map);
  }

  String get _connectionMessage {
    return 'Unable to connect to the backend at $_baseUri. Start the backend with `npm run backend`, or set BACKEND_BASE_URL to the running API URL.';
  }

  static Uri _defaultBaseUri() {
    const configured = String.fromEnvironment('BACKEND_BASE_URL');
    if (configured.isNotEmpty) {
      return Uri.parse(configured);
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return Uri.parse('http://10.0.2.2:8081');
    }

    return Uri.parse('http://127.0.0.1:8081');
  }
}
