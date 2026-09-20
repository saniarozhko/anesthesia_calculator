import 'package:flutter_test/flutter_test.dart';
import 'package:anesthesia_calculator/main.dart';

void main() {
testWidgets('Калькулятор реаниматолога запускается', (
WidgetTester tester,
) async {
await tester.pumpWidget(
const AnesthesiaCalculatorApp(),
);

expect(
  find.text('Калькулятор'),
  findsOneWidget,
);

});
}
