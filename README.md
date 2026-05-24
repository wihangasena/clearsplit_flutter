# clearsplit

Flutter expense-splitting app with a separate local backend for login and state storage.

## Run Locally

Start the backend first:

```bash
cd backend
dart run bin/server.dart
```

Then run the Flutter app:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

Demo users:

- `you@clearsplit.app`
- `alex@clearsplit.app`
- `maya@clearsplit.app`
- `jordan@clearsplit.app`

Password for all demo users: `demo123`

