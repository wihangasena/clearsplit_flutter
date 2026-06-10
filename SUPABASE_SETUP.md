# Supabase Setup Guide for ClearSplit

## Quick Setup Steps

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up
2. Create a new project
3. Wait for the project to initialize
4. Go to **Settings → API** to find your credentials:
   - Copy the **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - Copy the **Anon Key** (public key for client)
   - Copy the **Service Role Key** (for backend, keep secret!)

### 2. Configure Environment Variables

1. Copy the template:
```bash
cp .env.example .env.local
```

2. Edit `.env.local` and fill in your Supabase credentials:
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

### 3. Run Database Schema

1. Open [Supabase Dashboard](https://app.supabase.com)
2. Go to **SQL Editor**
3. Click **New Query**
4. Copy and paste the contents of `db/schema.sql`
5. Click **Run** to create all tables and security policies

### 4. Update Backend Configuration

Edit `backend/lib/supabase_client.dart` and replace:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
```

With your actual credentials from Supabase.

### 5. Install Dependencies

```bash
# Update backend dependencies
cd backend
dart pub get
cd ..

# Update frontend dependencies
flutter pub get
```

### 6. Update Backend Server

The backend needs to be updated to use Supabase. Example:

```dart
import 'package:clearsplit_backend/supabase_client.dart';

void main() async {
  await SupabaseConfig.initialize();
  final db = SupabaseDatabase(SupabaseConfig.getClient());
  
  // Use db.createExpense(), db.getPeopleForUser(), etc.
}
```

### 7. Run the App

```bash
# Terminal 1: Backend server
cd backend
dart run bin/server.dart

# Terminal 2: Flutter app
flutter run -d web-server --web-port=8080
```

## Database Schema Overview

### Tables

- **users** - User accounts (extends Supabase auth)
- **people** - Contacts/friends list
- **groups** - Expense groups
- **group_members** - Members of each group
- **expenses** - Expense records
- **expense_participants** - Who's involved in each expense
- **grocery_items** - Shopping list items

### Security

All tables have Row Level Security (RLS) enabled:
- Users can only see their own data
- Group members can see group expenses
- Sensitive operations are protected

## Authentication Flow

1. User signs up/logs in via Flutter app
2. Supabase issues JWT token
3. Token included in API requests
4. Backend verifies token with Supabase
5. RLS policies enforce data access

## Important Notes

⚠️ **Never commit `.env.local` or expose service role keys!**

✅ Add to `.gitignore`:
```
.env.local
.env
*.key
```

## Testing Supabase Connection

```bash
# Run this in backend directory
dart run bin/server.dart
# Should initialize Supabase client successfully
```

## Troubleshooting

### "Failed to connect to Supabase"
- Check `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env.local`
- Verify Supabase project is running
- Check internet connection

### "RLS policy violation"
- Ensure user is authenticated
- Check RLS policies in Supabase dashboard
- Verify `auth.uid()` matches user ID

### "Table not found"
- Run `db/schema.sql` in Supabase SQL Editor
- Check for SQL errors in execution output

## Next Steps

1. ✅ Create Supabase project
2. ✅ Configure environment variables
3. ✅ Run database schema
4. ✅ Update backend code
5. ✅ Install dependencies
6. ✅ Run and test

Happy expense splitting! 🎉
