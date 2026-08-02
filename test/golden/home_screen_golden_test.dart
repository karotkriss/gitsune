import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/main.dart';

void main() {
  testWidgets('empty home screen matches the dark-theme golden', (
    tester,
  ) async {
    await tester.pumpWidget(const GitsuneApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GitsuneApp),
      matchesGoldenFile('goldens/home_screen_empty.png'),
    );
  });
}
