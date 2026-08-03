import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/icons/gs_file_icons.dart';

void main() {
  test('file names resolve to their GitLab file-type glyphs', () {
    expect(fileIconGlyphFor('README.md'), GsFileIconGlyph.readme);
    expect(fileIconGlyphFor('.gitignore'), GsFileIconGlyph.git);
    expect(fileIconGlyphFor('main.dart'), GsFileIconGlyph.dart);
    expect(fileIconGlyphFor('package.json'), GsFileIconGlyph.json);
    expect(fileIconGlyphFor('pubspec.lock'), GsFileIconGlyph.lock);
    expect(fileIconGlyphFor('notes.md'), GsFileIconGlyph.markdown);
    expect(fileIconGlyphFor('pubspec.yaml'), GsFileIconGlyph.yaml);
    expect(fileIconGlyphFor('ci.yml'), GsFileIconGlyph.yaml);
    expect(fileIconGlyphFor('cover.PNG'), GsFileIconGlyph.image);
    expect(fileIconGlyphFor('Makefile'), GsFileIconGlyph.file);
  });
}
