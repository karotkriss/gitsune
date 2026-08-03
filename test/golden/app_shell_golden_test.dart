import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/main.dart';

void main() {
  const tabs = {
    'Home': ('Home', 'shell_home'),
    'To-Dos': ('To-Do List', 'shell_todos'),
    'Explore': ('Explore', 'shell_explore'),
    'Profile': ('Profile', 'shell_profile'),
  };

  for (final MapEntry(key: label, value: tab) in tabs.entries) {
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

      expect(
        find.text(tab.$1),
        tab.$1 == label ? findsNWidgets(2) : findsOneWidget,
      );

      await expectLater(
        find.byType(GitsuneApp),
        matchesGoldenFile('goldens/${tab.$2}.png'),
      );
    });
  }
}
