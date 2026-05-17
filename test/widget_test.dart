import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:buddysplit_flutter/main.dart';
import 'package:buddysplit_flutter/app_state.dart';

void main() {
  testWidgets('BuddySplit app renders', (WidgetTester tester) async {
    final controller = AppController();
    await controller.initialized;

    await tester.pumpWidget(BuddySplitApp(controller: controller));
    await tester.pump();

    expect(find.text('BuddySplit'), findsWidgets);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
  });
}
