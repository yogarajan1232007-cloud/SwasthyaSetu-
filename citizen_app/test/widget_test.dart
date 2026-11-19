import 'package:flutter_test/flutter_test.dart';
import 'package:citizen_app/main.dart';

void main() {
  testWidgets('Citizen app displays login screen', (tester) async {
    await tester.pumpWidget(const CitizenApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('SwasthyaSetu'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });
}