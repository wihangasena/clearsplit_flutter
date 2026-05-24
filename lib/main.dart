import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_shell.dart';
import 'app_state.dart';
import 'services/supabase_client.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase. Fill in `lib/services/supabase_client.dart` with your keys.
  await initializeSupabase();

  final controller = AppController();
  await controller.initialized;
  runApp(ClearSplitApp(controller: controller));
}

class ClearSplitApp extends StatelessWidget {
  const ClearSplitApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F766E),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF0F766E),
        secondary: const Color(0xFFF97316),
        tertiary: const Color(0xFF8B5CF6),
        error: const Color(0xFFDC2626),
        surface: const Color(0xFFFFFFFF),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'clearsplit',
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        textTheme: GoogleFonts.spaceGroteskTextTheme(baseTheme.textTheme),
      ),
      home: AuthGate(controller: controller),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.controller});

  final AppController controller;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final dynamic _authSub;

  @override
  void initState() {
    super.initState();
    // onAuthStateChange returns a GotrueSubscription. Keep it so we can unsubscribe later.
    _authSub = Supabase.instance.client.auth.onAuthStateChange((event, session) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    try {
      _authSub.unsubscribe();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return LoginScreen(onSignedIn: () {
        setState(() {});
      });
    }
    return AppBootstrap(controller: widget.controller);
  }
}
