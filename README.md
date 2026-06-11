# clearsplit

Flutter expense-splitting app with a separate local backend for login and state storage.

## Run Locally

Start both the backend and Flutter web app:

```bash
npm run dev
```

Or start the backend first:

```bash
cd backend
dart run bin/server.dart
```

Then run the Flutter app:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

For Android emulator builds, the app uses `http://10.0.2.2:8081` automatically. For a physical device or a deployed API, pass the API URL at build/run time:

```bash
flutter run --dart-define=BACKEND_BASE_URL=http://YOUR_MACHINE_IP:8081
```

To connect the backend to a MongoDB cloud database, set `MONGO_URI` in your backend environment or `.env` file.

Example `.env` entry:

```text
MONGO_URI=mongodb+srv://<user>:<pass>@cluster0.example.mongodb.net/clearsplit?retryWrites=true&w=majority
MONGO_COLLECTION=app_states
```

The frontend still runs locally and talks to the backend over HTTP; the backend stores state in MongoDB when `MONGO_URI` is configured.

Demo users:

- `you@clearsplit.app`
- `alex@clearsplit.app`
- `maya@clearsplit.app`
- `jordan@clearsplit.app`

Password for all demo users: `demo123`

