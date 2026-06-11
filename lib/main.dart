import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'app_state.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = AppController();
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
      ),
      home: SessionGate(controller: controller),
    );
  }
}

class SessionGate extends StatelessWidget {
  const SessionGate({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return controller.isSignedIn
            ? AppBootstrap(controller: controller)
            : LoginScreen(controller: controller);
      },
    );
  }
}
