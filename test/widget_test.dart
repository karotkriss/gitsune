import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/main.dart';

void main() {
  testWidgets('boots to an empty dark-themed screen', (tester) async {
    await tester.pumpWidget(const GitsuneApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme!.brightness, Brightness.dark);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
