import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/loopback_http_overrides.dart';

/// Global `flutter test` setup, auto-loaded for every test under `test/`.
///
/// Enforces the E16.3 no-live-instance guarantee for every test: plain-Dart
/// `test()` cases get no binding-level HttpClient mock, so [LoopbackHttpOverrides]
/// is installed as `HttpOverrides.global` here to block any connection off
/// loopback. Widget tests replace this with flutter_test's stricter
/// all-blocking mock during binding init; the ones that need the loopback fake
/// server opt back in with the same [LoopbackHttpOverrides], never a raw
/// pass-through.
///
/// Golden tests render every glyph with the bundled Ahem font
/// (`test/golden/fonts/Ahem.ttf`) instead of whatever fonts the host machine
/// happens to have installed, so golden pixels are identical on every
/// machine that runs the suite.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  HttpOverrides.global = LoopbackHttpOverrides();
  setUpAll(() async {
    final bytes = await File('test/golden/fonts/Ahem.ttf').readAsBytes();
    final data = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length);
    for (final family in const [
      'Roboto',
      'CupertinoSystemText',
      'CupertinoSystemDisplay',
    ]) {
      await (FontLoader(family)..addFont(Future.value(data))).load();
    }
  });

  await testMain();
}
