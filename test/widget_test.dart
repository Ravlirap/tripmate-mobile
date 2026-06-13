import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_ppb_app/main.dart';

void main() {
  testWidgets('App should render HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const TripMateApp());
    expect(find.text('TripMate'), findsOneWidget);
  });
}
