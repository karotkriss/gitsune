import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// GitLab file-type glyphs from the vendored file-icons sprite.
///
/// Markup is copied verbatim from the matching `<symbol>` in
/// `design/assets/icons/gitlab-file-icons.svg` (npm `@gitlab/svgs`; license
/// text in `design/assets/icons/NOTICE-file-icons.md`). Unlike the monochrome
/// Pajamas glyphs in `gs_icons.dart`, file-type glyphs carry their own fill
/// colors and draw on a 24x24 grid, so [GsFileIcon] renders them untinted.
enum GsFileIconGlyph {
  dart(
    '<path d="M12.618 1.566a.978.978 0 0 0-.682.281l-.01.007-6.388 3.692 '
    '6.372 6.372v.004l7.658 7.659 '
    '1.46-2.63-5.264-12.64-2.457-2.457a.972.972 0 0 0-.69-.288z" '
    'fill="#66C3FA"></path><path d="M5.553 5.531l-3.69 '
    '6.383-.007.01a.967.967 0 0 0 .006 1.371l3.058 3.061 11.963 4.706 '
    '2.705-1.502-.073-.073-.019.002-7.5-7.512h-.009L5.553 5.53z" '
    'fill="#215896"></path><path d="M5.537 5.534l6.518 6.525h.01l7.501 '
    '7.51 2.856-.544.004-8.449-3.015-2.955c-.66-.647-1.675-1.064-2.695-1.'
    '202l.002-.032-11.18-.852z" fill="#235997"></path><path d="M5.545 '
    '5.542l6.522 6.522v.009l7.506 7.506-.546 2.855h-8.449l-2.954-3.017c-.'
    '647-.66-1.063-1.676-1.2-2.696l-.033.003-.846-11.182z" '
    'fill="#58B6F0"></path>',
  ),
  file(
    '<path d="M13 9h5.5L13 3.5V9M6 2h8l6 6v12a2 2 0 0 1-2 2H6a2 2 0 0 '
    '1-2-2V4c0-1.11.89-2 2-2m5 2H6v16h12v-9h-7V4z" fill="#42a5f5"></path>',
  ),
  git(
    '<path d="M2.6 10.59L8.38 4.8l1.69 1.7c-.24.85.15 1.78.93 '
    '2.23v5.54c-.6.34-1 .99-1 1.73a2 2 0 0 0 2 2 2 2 0 0 0 '
    '2-2c0-.74-.4-1.39-1-1.73V9.41l2.07 2.09c-.07.15-.07.32-.07.5a2 2 0 0'
    ' 0 2 2 2 2 0 0 0 2-2 2 2 0 0 0-2-2c-.18 0-.35 0-.5.07L13.93 7.5a1.98'
    ' 1.98 0 0 0-1.15-2.34c-.43-.16-.88-.2-1.28-.09L9.8 '
    '3.38l.79-.78c.78-.79 2.04-.79 2.82 0l7.99 7.99c.79.78.79 2.04 0 '
    '2.82l-7.99 7.99c-.78.79-2.04.79-2.82 0L2.6 13.41c-.79-.78-.79-2.04 '
    '0-2.82z" fill="#e64a19"></path>',
  ),
  image(
    '<path d="M12.976 9.072h5.368l-5.368-5.367v5.367M6.144 '
    '2.241h7.808l5.856 5.855v11.711a1.952 1.952 0 0 1-1.952 '
    '1.952H6.145a1.951 1.951 0 0 1-1.952-1.952V4.192c0-1.083.868-1.951 '
    '1.952-1.951m0 17.567h11.71V12l-3.903 3.904L12 13.952l-5.856 '
    '5.856M8.096 9.073a1.952 1.952 0 0 0-1.952 1.952 1.952 1.952 0 0 0 '
    '1.952 1.951 1.952 1.952 0 0 0 1.952-1.951 1.952 1.952 0 0 '
    '0-1.952-1.952z" fill="#26a69a"></path>',
  ),
  json(
    '<path d="M5.759 3.975h1.783V5.76H5.759v4.458A1.783 1.783 0 0 1 3.975'
    ' 12a1.783 1.783 0 0 1 1.784 1.783v4.459h1.783v1.783H5.759c-.954-.24-'
    '1.784-.803-1.784-1.783v-3.567a1.783 1.783 0 0 '
    '0-1.783-1.783H1.3v-1.783h.892a1.783 1.783 0 0 0 '
    '1.783-1.784V5.76A1.783 1.783 0 0 1 5.76 3.975m12.483 0a1.783 1.783 0'
    ' 0 1 1.783 1.784v3.566a1.783 1.783 0 0 0 1.783 '
    '1.784h.892v1.783h-.892a1.783 1.783 0 0 0-1.783 1.783v3.567a1.783 '
    '1.783 0 0 1-1.783 1.783h-1.784v-1.783h1.784v-4.459A1.783 1.783 0 0 1'
    ' 20.025 12a1.783 1.783 0 0 1-1.783-1.783V5.759h-1.784V3.975h1.784M12'
    ' 14.675a.892.892 0 0 1 .892.892.892.892 0 0 1-.892.892.892.892 0 0 '
    '1-.891-.892.892.892 0 0 1 .891-.892m-3.566 0a.892.892 0 0 1 '
    '.891.892.892.892 0 0 1-.891.892.892.892 0 0 1-.892-.892.892.892 0 0 '
    '1 .892-.892m7.133 0a.892.892 0 0 1 .891.892.892.892 0 0 '
    '1-.891.892.892.892 0 0 1-.892-.892.892.892 0 0 1 .892-.892z" '
    'fill="#fbc02d"></path>',
  ),
  lock(
    '<path d="M12 17.5a2 2 0 0 0 2-2 2 2 0 0 0-2-2 2 2 0 0 0-2 2 2 2 0 0 '
    '0 2 2m6-9a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-10a2 2 0 0'
    ' 1 2-2h1v-2a5 5 0 0 1 5-5 5 5 0 0 1 5 5v2h1m-6-5a3 3 0 0 0-3 '
    '3v2h6v-2a3 3 0 0 0-3-3z" fill="#ffd54f"></path>',
  ),
  markdown(
    '<path d="M2.25 15.75v-8h2l3 3 3-3h2v8h-2v-5.17l-3 '
    '3-3-3v5.17h-2m14-8h3v4h2.5l-4 4.5-4-4.5h2.5z" fill="#42a5f5"></path>',
  ),
  readme(
    '<path d="M13 9h-2V7h2m0 10h-2v-6h2m-1-9A10 10 0 0 0 2 12a10 10 0 0 0'
    ' 10 10 10 10 0 0 0 10-10A10 10 0 0 0 12 2z" fill="#42a5f5"></path>',
  ),
  yaml(
    '<path d="M13 9h5.5L13 3.5V9M6 2h8l6 6v12c0 1.1-.9 2-2 2H6c-1.1 '
    '0-2-.9-2-2V4c0-1.1.9-2 2-2m12 16v-2H9v2h9m-4-4v-2H6v2z" '
    'fill="#FF5252"></path>',
  );

  const GsFileIconGlyph(this.markup);

  /// Inner SVG markup on the sprite's 24x24 grid.
  final String markup;
}

/// Resolves the glyph for a file entry the way GitLab's file tree does:
/// well-known file names first, then the extension, then the generic
/// [GsFileIconGlyph.file].
GsFileIconGlyph fileIconGlyphFor(String fileName) {
  final name = fileName.toLowerCase();
  if (name == 'readme' || name == 'readme.md') return GsFileIconGlyph.readme;
  if (name.startsWith('.git')) return GsFileIconGlyph.git;
  final dot = name.lastIndexOf('.');
  final extension = dot < 0 ? '' : name.substring(dot + 1);
  return switch (extension) {
    'dart' => GsFileIconGlyph.dart,
    'json' => GsFileIconGlyph.json,
    'lock' => GsFileIconGlyph.lock,
    'md' || 'markdown' => GsFileIconGlyph.markdown,
    'yaml' || 'yml' => GsFileIconGlyph.yaml,
    'png' ||
    'jpg' ||
    'jpeg' ||
    'gif' ||
    'webp' ||
    'svg' ||
    'ico' => GsFileIconGlyph.image,
    _ => GsFileIconGlyph.file,
  };
}

/// Renders a [GsFileIconGlyph] at [size], keeping the sprite's own colors.
class GsFileIcon extends StatelessWidget {
  const GsFileIcon(this.glyph, {super.key, this.size = 16});

  final GsFileIconGlyph glyph;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '${glyph.markup}'
      '</svg>',
      width: size,
      height: size,
    );
  }
}
