import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/syntax/language_detection.dart';

void main() {
  test('detects language from a common extension', () {
    expect(detectLanguageId('lib/main.dart'), 'dart');
    expect(detectLanguageId('src/app.tsx'), 'typescript');
    expect(detectLanguageId('scripts/build.sh'), 'bash');
    expect(detectLanguageId('README.md'), 'markdown');
  });

  test('extension matching is case-insensitive', () {
    expect(detectLanguageId('Main.DART'), 'dart');
  });

  test('matches well-known filenames with no extension', () {
    expect(detectLanguageId('Dockerfile'), 'dockerfile');
    expect(detectLanguageId('path/to/Makefile'), 'makefile');
  });

  test('falls back to plaintext for an unknown extension', () {
    expect(detectLanguageId('data.xyz123'), plainTextLanguageId);
  });

  test('falls back to plaintext for a file with no extension', () {
    expect(detectLanguageId('LICENSE'), plainTextLanguageId);
  });

  test('falls back to plaintext for a dotfile with no true extension', () {
    expect(detectLanguageId('.gitignore'), plainTextLanguageId);
  });
}
