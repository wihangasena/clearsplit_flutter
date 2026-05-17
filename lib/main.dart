import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_shell.dart';
import 'app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.initialized;
  runApp(BuddySplitApp(controller: controller));
}

class BuddySplitApp extends StatelessWidget {
  const BuddySplitApp({super.key, required this.controller});

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
      title: 'BuddySplit',
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        textTheme: GoogleFonts.spaceGroteskTextTheme(baseTheme.textTheme),
      ),
      home: AppBootstrap(controller: controller),
    );
  }
}
