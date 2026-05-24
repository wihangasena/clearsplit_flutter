import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clearsplit/main.dart';
import 'package:clearsplit/app_state.dart';

void main() {
  testWidgets('clearsplit app renders', (WidgetTester tester) async {
    final controller = AppController();
    await controller.initialized;

    await tester.pumpWidget(ClearSplitApp(controller: controller));
    await tester.pump();

    expect(find.text('clearsplit'), findsWidgets);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
  });
}
