import 'package:flutter_test/flutter_test.dart';
import 'package:greenhouse_monitor/main.dart';

void main() {
  testWidgets('Головний екран показує налаштування і кнопку входу',
      (tester) async {
    await tester.pumpWidget(const GreenhouseApp());

    expect(find.text('Розумна теплиця'), findsOneWidget);
    expect(find.text('Повільна мережа'), findsOneWidget);
    expect(find.text('Відкрити панель теплиці'), findsOneWidget);
  });
}
