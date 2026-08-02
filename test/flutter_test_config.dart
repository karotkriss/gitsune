import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global `flutter test` setup, auto-loaded for every test under `test/`.
///
/// Golden tests render every glyph with the bundled Ahem font
/// (`test/golden/fonts/Ahem.ttf`) instead of whatever fonts the host machine
/// happens to have installed, so golden pixels are identical on every
/// machine that runs the suite.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() async {
    final bytes = await File('test/golden/fonts/Ahem.ttf').readAsBytes();
    final data = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length);
    for (final family in const ['Roboto', '.SF UI Text', '.SF UI Display']) {
      await (FontLoader(family)..addFont(Future.value(data))).load();
    }
  });

  await testMain();
}
