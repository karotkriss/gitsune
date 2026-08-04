import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/todos/todos_screen.dart';

import '../features/todos/support/fixture_todos_repository.dart';

void main() {
  testWidgets('empty To-Do List matches the illustrated empty-state golden', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final repository = FixtureTodosRepository(const []);
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: TodosScreen(
          repository: repository,
          now: DateTime.utc(2026, 8, 2, 10),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TodosScreen),
      matchesGoldenFile('goldens/todos_screen_empty.png'),
    );
  });
}
