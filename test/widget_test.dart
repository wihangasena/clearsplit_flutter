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
  });

  test('app state accepts ISO date strings from JSON', () {
    final data = AppData.fromJson({
      'me': 'user-you',
      'people': [
        {'id': 'user-you', 'name': 'You', 'avatar': ':)', 'color': '#2563EB'},
      ],
      'groups': <Map<String, dynamic>>[],
      'expenses': [
        {
          'id': 'e1',
          'title': 'Dinner',
          'amount': 20,
          'paidBy': 'user-you',
          'participants': ['user-you'],
          'category': 'Food',
          'date': '2026-06-10T16:12:06.9850178Z',
        },
      ],
      'grocery': <Map<String, dynamic>>[],
    });

    expect(data.expenses.single.date.year, 2026);
  });
}
