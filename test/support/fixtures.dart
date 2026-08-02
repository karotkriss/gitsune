import 'dart:convert';
import 'dart:io';

/// Loads recorded, scrubbed GitLab API JSON payloads from `test/fixtures/`.
class Fixtures {
  const Fixtures._();

  static dynamic json(String name) => jsonDecode(raw(name));

  static String raw(String name) =>
      File('test/fixtures/$name.json').readAsStringSync();
}
