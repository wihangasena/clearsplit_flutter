import 'package:supabase_flutter/supabase_flutter.dart';

// Fill these with your Supabase project values.
const String kSupabaseUrl = 'YOUR_SUPABASE_URL'; // e.g. https://xyz.supabase.co
const String kSupabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
    // Optionally set debug: true for development
    // debug: true,
  );
}

SupabaseClient supabaseClient() => Supabase.instance.client;
