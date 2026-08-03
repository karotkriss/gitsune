import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/todos/todos_screen.dart';
import 'package:gitsune/main.dart';

import '../support/fixture_todos_repository.dart';

void main() {
  late FixtureTodosRepository repository;

  setUp(() {
    repository = FixtureTodosRepository();
  });

  tearDown(() => repository.dispose());

  Future<void> pumpScreen(WidgetTester tester) async {
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
  }

  testWidgets('renders and reactively updates the repository stream', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(repository.refreshCount, 1);
    expect(find.byKey(const ValueKey('todo-row-102')), findsOneWidget);
    expect(find.byKey(const ValueKey('todo-row-101')), findsOneWidget);
    expect(find.byKey(const ValueKey('todo-row-88101')), findsOneWidget);

    repository.emit([fixtureTodos().first]);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo-row-102')), findsOneWidget);
    expect(find.byKey(const ValueKey('todo-row-101')), findsNothing);
    expect(find.byKey(const ValueKey('todo-row-88101')), findsNothing);
  });

  testWidgets('the shell To-Dos tab uses the supplied repository', (
    tester,
  ) async {
    await tester.pumpWidget(GitsuneApp(todosRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('To-Dos'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('To-Do List'), findsOneWidget);
    expect(find.byKey(const ValueKey('todo-row-102')), findsOneWidget);
  });

  testWidgets('swiping right marks done and offers undo', (tester) async {
    await pumpScreen(tester);

    await tester.drag(
      find.byKey(const ValueKey('todo-row-102')),
      const Offset(360, 0),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo-row-102')), findsNothing);
    expect(find.text('To-do marked as done.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo-row-102')), findsOneWidget);
  });

  testWidgets('swiping left snoozes and offers undo', (tester) async {
    await pumpScreen(tester);

    await tester.drag(
      find.byKey(const ValueKey('todo-row-101')),
      const Offset(-360, 0),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo-row-101')), findsNothing);
    expect(find.text('To-do snoozed.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo-row-101')), findsOneWidget);
  });

  testWidgets('filters the list by reason from the bottom sheet', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('todo-filter-button')));
    await tester.pumpAndSettle();

    expect(find.text('Filter by reason'), findsOneWidget);
    expect(find.text('Assigned'), findsOneWidget);
    expect(find.text('Review requested'), findsOneWidget);
    expect(find.text('Pipeline failed'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('todo-filter-assigned')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo-row-102')), findsNothing);
    expect(find.byKey(const ValueKey('todo-row-101')), findsOneWidget);
    expect(find.byKey(const ValueKey('todo-row-88101')), findsNothing);
    expect(find.text('Assigned'), findsOneWidget);
  });

  testWidgets('the visible done control uses the same undo path', (
    tester,
  ) async {
    await pumpScreen(tester);

    final firstRow = find.byKey(const ValueKey('todo-row-102'));
    await tester.tap(
      find.descendant(of: firstRow, matching: find.byTooltip('Mark as done')),
    );
    await tester.pumpAndSettle();

    expect(firstRow, findsNothing);
    expect(find.text('To-do marked as done.'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(firstRow, findsOneWidget);
  });
}
