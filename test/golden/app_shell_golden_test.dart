import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/main.dart';

void main() {
  const tabs = {
    'Home': 'shell_home',
    'To-Dos': 'shell_todos',
    'Explore': 'shell_explore',
    'Profile': 'shell_profile',
  };

  for (final MapEntry(key: label, value: golden) in tabs.entries) {
    testWidgets('$label tab navigates and matches the dark-theme golden', (
      tester,
    ) async {
      await tester.pumpWidget(const GitsuneApp());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();

      // The label appears twice once the tab is active: the tab-bar item and
      // the screen's title, proving navigation landed on the right screen.
      expect(find.text(label), findsNWidgets(2));

      await expectLater(
        find.byType(GitsuneApp),
        matchesGoldenFile('goldens/$golden.png'),
      );
    });
  }
}
