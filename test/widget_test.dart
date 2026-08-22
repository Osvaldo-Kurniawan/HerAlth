import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/main.dart';

void main() {
  testWidgets('Smoke test - App renders initial screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HerAlthApp());

    // Verify that the title and placeholder text are displayed.
    expect(find.text('HerAlth'), findsWidgets);
    expect(find.text('Start developing the app here.'), findsOneWidget);
  });
}
