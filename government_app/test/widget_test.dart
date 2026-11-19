import 'package:flutter_test/flutter_test.dart';
import 'package:government_app/app/app.dart';

void main() {
  testWidgets('SwasthyaSetu login screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Health Officer'), findsOneWidget);
    expect(find.text('Health Worker'), findsOneWidget);
  });
}