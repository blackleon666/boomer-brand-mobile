import 'package:flutter_test/flutter_test.dart';
import 'package:boomer_brand_app/main.dart';

void main() {
  testWidgets('App starts and shows login', (WidgetTester tester) async {
    await tester.pumpWidget(const BoomerApp());
    await tester.pumpAndSettle();
    expect(find.text('BOOMER BRAND'), findsOneWidget);
  });
}