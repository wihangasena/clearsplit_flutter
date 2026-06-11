import 'package:flutter_test/flutter_test.dart';

import 'package:clearsplit/services/backend_client.dart';

void main() {
  test(
    'backend client throws when local backend is unavailable',
    () async {
      final client = BackendClient(baseUri: Uri.parse('http://127.0.0.1:1'));

      expect(
        client.signIn(
          email: 'you@clearsplit.app',
          password: 'demo123',
        ),
        throwsA(isA<BackendClientException>()),
      );
    },
  );
}
