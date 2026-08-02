import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the core-versus-feature boundary: `core/` is shared
/// infrastructure and must never depend on `features/`, only the reverse.
void main() {
  test('core never imports features', () {
    final coreDir = Directory('lib/core');
    final violations = <String>[];

    for (final entity in coreDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('import') &&
            trimmed.contains("package:gitsune/features/")) {
          violations.add('${entity.path}: $trimmed');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'core/ must not import features/:\n${violations.join('\n')}',
    );
  });
}
