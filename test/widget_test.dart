import 'package:flutter_test/flutter_test.dart';
import 'package:routerelay/main.dart';

void main() {
  testWidgets('Map screen shows up smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RouteRelayApp());

    // Verify that the map screen is shown.
    expect(find.text('RouteRelay Map'), findsOneWidget);
  });
}
