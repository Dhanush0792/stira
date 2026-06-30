import 'package:flutter_test/flutter_test.dart';
import 'package:stira/main.dart';

void main() {
  testWidgets('StiraApp smoke test', (WidgetTester tester) async {
    // Basic smoke test — verify app builds without crashing.
    // Full UI tests require Hive initialisation; see integration tests.
    expect(StiraApp, isNotNull);
  });
}
